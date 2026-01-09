// lib/Features/Chat/chat_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepository {
  final SupabaseClient _supabase;

  ChatRepository(this._supabase);

  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<String> getOtherUserEmail(String roomId) async {
    final myId = currentUserId;
    if (myId == null) {
      throw Exception('Not authenticated');
    }

    final participants = await _supabase
        .from('room_participants')
        .select('user_id')
        .eq('room_id', roomId);

    if (participants.isEmpty) {
      throw Exception('No participants found in this room');
    }

    final otherUser = participants.firstWhere(
      (p) => p['user_id'] != myId,
      orElse: () => throw Exception('No other user found'),
    );

    final profile =
        await _supabase
            .from('profiles')
            .select('email')
            .eq('id', otherUser['user_id'])
            .single();

    return profile['email'] as String;
  }

  Stream<List<Map<String, dynamic>>> messagesStream(String roomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .map((data) {
          return data.map((item) => Map<String, dynamic>.from(item)).toList();
        });
  }

  Future<void> sendMessage(String roomId, String content) async {
    final myId = currentUserId;
    if (myId == null) {
      throw Exception('Not authenticated');
    }

    await _supabase.from('messages').insert({
      'room_id': roomId,
      'content': content,
      'user_id': myId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    await _supabase
        .from('messages')
        .update({'reaction': emoji})
        .eq('id', messageId);
  }
}
