import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'inbox_controller.dart';
import 'inbox_repository.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use Get.find() to get the controller from binding, or create if not found
    InboxController controller;
    try {
      controller = Get.find<InboxController>();
    } catch (e) {
      // Controller not found, initialize it (for direct usage without routing)
      final supabase = Supabase.instance.client;
      controller = Get.put(InboxController(
        repository: InboxRepository(supabase),
        supabase: supabase,
      ));
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => _buildAppBar(isDark, controller)),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                if (controller.filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          controller.searchQuery.value.isEmpty
                              ? Icons.chat_bubble_outline
                              : Icons.search_off,
                          size: 48,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchQuery.value.isEmpty
                              ? "No messages yet\nTap search to find people"
                              : "No users found",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 6),
                  itemCount: controller.filteredUsers.length,
                  separatorBuilder:
                      (_, __) => Divider(
                        height: 0.5,
                        indent: 88,
                        color:
                            isDark
                                ? const Color(0xFF2C2C2E)
                                : const Color(0xFFE5E5EA),
                      ),
                  itemBuilder:
                      (context, index) => _buildChatItem(
                        context,
                        controller.filteredUsers[index],
                        controller,
                        isDark,
                      ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark, InboxController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child:
          controller.isSearching.value
              ? _buildSearchBar(isDark, controller)
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                    ),
                  ),
                  Row(
                    children: [
                      _actionButton(
                        Icons.search,
                        isDark,
                        () => controller.isSearching.value = true,
                      ),
                      const SizedBox(width: 12),
                      _actionButton(Icons.edit_outlined, isDark, () {}),
                    ],
                  ),
                ],
              ),
    );
  }

  Widget _buildSearchBar(bool isDark, InboxController controller) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              autofocus: true,
              onChanged: (val) => controller.searchQuery.value = val,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey : Colors.black45,
                  size: 20,
                ),
                hintText: 'Search email...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey : Colors.black45,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                isDense: true,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            controller.isSearching.value = false;
            controller.searchQuery.value = '';
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.blue,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context,
    Map<String, dynamic> user,
    InboxController controller,
    bool isDark,
  ) {
    final String name = (user['email'] ?? 'User').split('@')[0];
    final String fullName = _formatName(name);
    final String lastMsg = user['last_message'] ?? 'Start a conversation';
    final String time = _formatChatTime(user['time']);
    final int unreadCount = user['unread_count'] ?? 0;

    return InkWell(
      onTap: () => controller.startChat(user),
      splashColor: Colors.transparent,
      highlightColor:
          isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _Avatar(name: fullName),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fullName,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight:
                                unreadCount > 0
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                            color:
                                unreadCount > 0
                                    ? (isDark ? Colors.white : Colors.black)
                                    : const Color(0xFF8E8E93),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatName(String name) {
    if (name.isEmpty) return 'User';
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  String _formatChatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();

      if (DateUtils.isSameDay(date, now)) {
        return DateFormat('h:mm a').format(date).toLowerCase();
      }
      if (now.difference(date).inDays < 7) {
        return DateFormat('EEE').format(date);
      }
      return DateFormat('dd/MM/yy').format(date);
    } catch (_) {
      return '';
    }
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF007AFF),
      const Color(0xFF34C759),
      const Color(0xFFFF9500),
      const Color(0xFFFF2D55),
      const Color(0xFF5856D6),
      const Color(0xFFAF52DE),
    ];

    final color = colors[name.hashCode % colors.length];

    return CircleAvatar(
      radius: 26,
      backgroundColor: color.withOpacity(0.18),
      child: Text(
        name.isNotEmpty ? name[0] : '?',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
