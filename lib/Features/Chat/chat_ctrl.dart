// lib/features/chat/chat_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinterest/Features/Chat/chat_repo.dart';

class ChatController extends GetxController {
  final ChatRepository repo;

  ChatController(this.repo);

  final otherUserEmail = RxnString();
  final isLoadingHeader = true.obs;
  final headerError = RxnString();

  final isSending = false.obs;
  final sendError = RxnString();

  final textController = TextEditingController();
  final scrollController = ScrollController();

  late final String roomId;
  late final Stream<List<Map<String, dynamic>>> messagesStream;

  void init(String roomId) {
    this.roomId = roomId;
    
    // Initialize messages stream immediately (non-blocking)
    messagesStream = repo.messagesStream(roomId);
    
    // Load header in background without blocking
    _loadHeader();
  }

  Future<void> _loadHeader() async {
    isLoadingHeader.value = true;
    headerError.value = null;
    try {
      final email = await repo.getOtherUserEmail(roomId);
      otherUserEmail.value = email;
    } catch (e) {
      headerError.value = e.toString();
    } finally {
      isLoadingHeader.value = false;
    }
  }

  Future<void> retryHeader() => _loadHeader();

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || isSending.value) return;

    isSending.value = true;
    sendError.value = null;
    textController.clear();

    try {
      await repo.sendMessage(roomId, text);
    } catch (e) {
      sendError.value = e.toString();
      textController.text = text;
      Get.snackbar(
        'Send Failed',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> reactToMessage({
    required String messageId,
    required String emoji,
  }) async {
    try {
      await repo.addReaction(messageId: messageId, emoji: emoji);
    } catch (_) {
      // optional: show error snackbar
    }
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}