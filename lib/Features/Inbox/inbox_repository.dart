import 'package:supabase_flutter/supabase_flutter.dart';

class InboxRepository {
  final SupabaseClient _supabase;

  InboxRepository(this._supabase);

  Future<List<Map<String, dynamic>>> fetchOtherUsers() async {
    try {
      final myId = _supabase.auth.currentUser?.id;
      if (myId == null) return [];

      // Get all rooms where current user is participant
      final myRooms = await _supabase
          .from('room_participants')
          .select('room_id')
          .eq('user_id', myId);

      if (myRooms.isEmpty) return [];

      final roomIds = myRooms.map((r) => r['room_id'] as int).toList();

      // Get all participants in these rooms with their profiles
      final allParticipants = await _supabase
          .from('room_participants')
          .select('room_id, user_id, profiles(id, email)')
          .inFilter('room_id', roomIds)
          .neq('user_id', myId);

      final users = <Map<String, dynamic>>[];
      final processedUserIds = <String>{};

      for (final participant in allParticipants) {
        final roomId = participant['room_id'] as int;
        final userId = participant['user_id'] as String;

        // Skip if we've already processed this user (avoid duplicates)
        if (processedUserIds.contains(userId)) continue;
        processedUserIds.add(userId);

        // Get profile - it might be nested or we need to fetch it
        final profileData = participant['profiles'] as Map<String, dynamic>?;
        String email = '';

        if (profileData != null) {
          email = profileData['email'] as String? ?? '';
        } else {
          // Fallback: fetch profile separately if join didn't work
          final profile = await _supabase
              .from('profiles')
              .select('email')
              .eq('id', userId)
              .maybeSingle();
          email = profile?['email'] as String? ?? '';
        }

        // Get last message for this room
        final lastMessage = await _supabase
            .from('messages')
            .select('content, created_at')
            .eq('room_id', roomId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        // For now, set unread_count to 0 (can be improved with read receipts)
        const unreadCount = 0;

        users.add({
          'id': userId,
          'email': email,
          'last_message': lastMessage?['content'] ?? 'Start a conversation',
          'time': lastMessage?['created_at'] ?? DateTime.now().toIso8601String(),
          'unread_count': unreadCount,
        });
      }

      // Sort by last message time descending
      users.sort(
        (a, b) => DateTime.parse(b['time'] as String)
            .compareTo(DateTime.parse(a['time'] as String)),
      );

      return users;
    } catch (e) {
      return [];
    }
  }

  /// Search all users by email (for starting new chats)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final myId = _supabase.auth.currentUser?.id;
      if (myId == null) return [];

      if (query.trim().isEmpty) return [];

      final response = await _supabase
          .from('profiles')
          .select('id, email')
          .neq('id', myId)
          .ilike('email', '%$query%') // Case-insensitive search
          .limit(20);

      return List<Map<String, dynamic>>.from(response).map((user) {
        return {
          'id': user['id'] as String,
          'email': user['email'] as String? ?? '',
          'last_message': 'New Connection',
          'time': DateTime.now().toIso8601String(),
          'unread_count': 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get or create room in a single operation
  Future<Map<String, dynamic>> getOrCreateRoom(String otherUserId) async {
    try {
      final myId = _supabase.auth.currentUser?.id;
      if (myId == null) {
        throw Exception('User not authenticated');
      }

      // Try RPC first (fastest)
      try {
        final result = await _supabase.rpc(
          'get_or_create_direct_room',
          params: {'user_id_1': myId, 'user_id_2': otherUserId},
        );

        if (result != null && result is Map) {
          return {
            'room_id': result['room_id'].toString(),
            'other_user_email': result['other_user_email'] as String,
          };
        }
      } catch (e) {
        // RPC might not exist, fallback to manual method
      }

      // Fallback to manual method
      return await _getOrCreateRoomFallback(otherUserId);
    } catch (e) {
      rethrow;
    }
  }

  /// Fallback method
  Future<Map<String, dynamic>> _getOrCreateRoomFallback(
    String otherUserId,
  ) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) {
      throw Exception('User not authenticated');
    }

    // Get other user's email first
    final otherUser = await _supabase
        .from('profiles')
        .select('email')
        .eq('id', otherUserId)
        .single();

    final otherUserEmail = otherUser['email'] as String? ?? '';

    // Find existing room
    final myRooms = await _supabase
        .from('room_participants')
        .select('room_id')
        .eq('user_id', myId);

    if (myRooms.isNotEmpty) {
      final roomIds = myRooms.map((r) => r['room_id'] as int).toList();

      final sharedRooms = await _supabase
          .from('room_participants')
          .select('room_id')
          .eq('user_id', otherUserId)
          .inFilter('room_id', roomIds);

      for (final room in sharedRooms) {
        final roomId = room['room_id'] as int;
        final participants = await _supabase
            .from('room_participants')
            .select('user_id')
            .eq('room_id', roomId);

        if (participants.length == 2) {
          return {
            'room_id': roomId.toString(),
            'other_user_email': otherUserEmail,
          };
        }
      }
    }

    // Create new room
    final room = await _supabase.from('rooms').insert({}).select().single();
    final roomId = room['id'] as int;

    await _supabase.from('room_participants').insert([
      {'room_id': roomId, 'user_id': myId},
      {'room_id': roomId, 'user_id': otherUserId},
    ]);

    return {'room_id': roomId.toString(), 'other_user_email': otherUserEmail};
  }
}
