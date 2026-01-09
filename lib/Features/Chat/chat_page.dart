import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinterest/Features/Chat/chat_ctrl.dart';
import 'package:pinterest/Features/Chat/chat_repo.dart';
import 'package:pinterest/Features/Chat/widgets/chat_bubble.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final roomId = args['roomId'];
    final title = args['title'];

    final theme = Theme.of(context);
    final ctrl = Get.put(
      ChatController(ChatRepository(Supabase.instance.client)),
      tag: roomId,
    )..init(roomId);

    // Set initial title if available
    if (title != null) {
      ctrl.otherUserEmail.value = title;
      ctrl.isLoadingHeader.value = false;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, theme, ctrl),
      body: Column(
        children: [
          Expanded(child: _buildMessages(context, theme, ctrl)),
          Obx(() => _buildInput(theme, ctrl)),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    ChatController ctrl,
  ) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      elevation: 0,
      leading: IconButton(
        icon: Icon(CupertinoIcons.back, color: theme.colorScheme.onSurface),
        onPressed: Get.back,
      ),
      title: Obx(() {
        if (ctrl.isLoadingHeader.value) {
          return Text(
            'Loading...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          );
        }
        final email = ctrl.otherUserEmail.value ?? 'User';
        return Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor:
                    theme.brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE0E0E0),
                child: Text(
                  email[0].toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email.split('@')[0],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        IconButton(
          icon: Icon(Icons.phone, color: theme.colorScheme.onSurface, size: 25),
          onPressed: () => _comingSoon(theme),
        ),
        IconButton(
          icon: Icon(
            CupertinoIcons.ellipsis_vertical,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => _showOptions(theme, ctrl),
        ),
      ],
    );
  }

  Widget _buildMessages(
    BuildContext context,
    ThemeData theme,
    ChatController ctrl,
  ) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ctrl.messagesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Center(
            child: CupertinoActivityIndicator(
              radius: 14,
              color: theme.colorScheme.primary,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading messages',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.chat_bubble,
                  size: 64,
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        final myId = Supabase.instance.client.auth.currentUser!.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ctrl.scrollController.hasClients) {
            ctrl.scrollController.animateTo(
              ctrl.scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return ListView.builder(
          controller: ctrl.scrollController,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
          ),
          itemCount: messages.length,
          itemBuilder: (_, i) {
            final msg = messages[i];
            return MessageBubble(
              id: msg['id'].toString(),
              text: msg['content'] ?? '',
              isMe: msg['user_id'] == myId,
              reaction: msg['reaction'],
              onLongPress: () => _showReactions(theme, ctrl, msg),
              onTapReaction: () => _showReactions(theme, ctrl, msg),
            );
          },
        );
      },
    );
  }

  Widget _buildInput(ThemeData theme, ChatController ctrl) {
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _iconButton(
              theme,
              CupertinoIcons.add,
              bg,
              () => _showAttach(theme, ctrl),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctrl.textController,
                        enabled: !ctrl.isSending.value,
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText:
                              ctrl.isSending.value ? 'Sending...' : 'Message',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => ctrl.sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.smiley,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        size: 22,
                      ),
                      onPressed: () => _showEmoji(theme, ctrl),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: ctrl.isSending.value ? null : ctrl.sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                    ctrl.isSending.value
                        ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                        : Icon(
                          CupertinoIcons.arrow_up,
                          color: theme.colorScheme.onPrimary,
                          size: 20,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(
    ThemeData theme,
    IconData icon,
    Color bg,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 18, color: theme.colorScheme.onSurface),
      ),
    );
  }

  void _showReactions(ThemeData theme, ChatController ctrl, Map msg) {
    final emojis = ['👍', '❤️', '😂', '🔥', '😢', '👏'];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('React to message', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  emojis
                      .map(
                        (e) => _emojiTile(theme, e, () {
                          Get.back();
                          ctrl.reactToMessage(
                            messageId: msg['id'].toString(),
                            emoji: e,
                          );
                        }),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmoji(ThemeData theme, ChatController ctrl) {
    final emojis = [
      '😀',
      '😃',
      '😄',
      '😁',
      '😆',
      '😅',
      '😂',
      '🤣',
      '😊',
      '😇',
      '🙂',
      '🙃',
      '😉',
      '😌',
      '😍',
      '🥰',
      '😘',
      '😗',
      '😙',
      '😚',
      '😋',
      '😛',
      '😝',
      '😜',
      '🤪',
      '🤨',
      '🧐',
      '🤓',
      '😎',
      '🤩',
      '🥳',
      '😏',
      '👍',
      '👎',
      '👌',
      '✌️',
      '🤞',
      '🤟',
      '🤘',
      '🤙',
      '👏',
      '🙌',
      '👐',
      '🤲',
      '🤝',
      '🙏',
      '✍️',
      '💪',
      '❤️',
      '🧡',
      '💛',
      '💚',
      '💙',
      '💜',
      '🖤',
      '🤍',
      '💯',
      '💢',
      '💥',
      '💫',
      '💦',
      '💨',
      '🕊️',
      '🦋',
      '🔥',
      '✨',
      '🌟',
      '⭐',
      '🌈',
      '☀️',
      '🌙',
      '⚡',
    ];

    List<String> selectedEmojis = [];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Text('Pick emojis', style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: emojis.length,
                    itemBuilder: (_, i) {
                      final emoji = emojis[i];
                      final isSelected = selectedEmojis.contains(emoji);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedEmojis.remove(emoji);
                            } else {
                              selectedEmojis.add(emoji);
                            }

                            // Update TextField dynamically
                            ctrl.textController.text = selectedEmojis.join();
                            ctrl
                                .textController
                                .selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: ctrl.textController.text.length,
                              ),
                            );
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary.withValues(
                                      alpha: 0.3,
                                    )
                                    : theme.brightness == Brightness.dark
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _emojiTile(ThemeData theme, String emoji, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
      ),
    );
  }

  void _showAttach(ThemeData theme, ChatController ctrl) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send attachment', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _listTile(
              theme,
              CupertinoIcons.photo,
              'Photo from Gallery',
              () async {
                Get.back();
                await _pickImage(ImageSource.gallery);
              },
            ),
            _listTile(theme, CupertinoIcons.camera, 'Take Photo', () async {
              Get.back();
              await _pickImage(ImageSource.camera);
            }),
            _listTile(theme, CupertinoIcons.doc, 'Document', () {
              Get.back();
              _comingSoon(theme);
            }),
          ],
        ),
      ),
    );
  }

  Widget _listTile(
    ThemeData theme,
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(text, style: theme.textTheme.bodyMedium),
      onTap: onTap,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image != null) {
        _comingSoon(Get.theme);
        // TODO: Upload to Supabase Storage
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image',
        backgroundColor: Get.theme.colorScheme.surface,
        colorText: Get.theme.colorScheme.onSurface,
      );
    }
  }

  void _showOptions(ThemeData theme, ChatController ctrl) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chat Options', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _listTile(theme, CupertinoIcons.search, 'Search in Chat', () {
              Get.back();
              _comingSoon(theme);
            }),
            _listTile(
              theme,
              CupertinoIcons.volume_mute,
              'Mute Notifications',
              () {
                Get.back();
                _comingSoon(theme);
              },
            ),
            _listTile(theme, CupertinoIcons.clear, 'Clear Chat', () {
              Get.back();
              _confirmClear(theme);
            }),
          ],
        ),
      ),
    );
  }

  void _confirmClear(ThemeData theme) {
    Get.dialog(
      CupertinoAlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Delete all messages?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: Get.back,
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear'),
            onPressed: () {
              Get.back();
              _comingSoon(theme);
            },
          ),
        ],
      ),
    );
  }

  void _comingSoon(ThemeData theme) {
    final colorBg =
        theme.snackBarTheme.backgroundColor ?? theme.colorScheme.surface;
    final colorText =
        theme.snackBarTheme.contentTextStyle?.color ??
        theme.colorScheme.onSurface;

    Get.snackbar(
      'Coming Soon',
      'This feature will be available soon',
      snackPosition: SnackPosition.TOP,
      backgroundColor: colorBg,
      colorText: colorText,
      icon: Icon(Icons.watch_later, color: theme.colorScheme.primary, size: 28),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      borderRadius: 16,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.elasticInOut,
      overlayBlur: 5,
      overlayColor: Colors.black12,
      animationDuration: const Duration(milliseconds: 600),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      snackStyle: SnackStyle.FLOATING,
    );
  }
}
