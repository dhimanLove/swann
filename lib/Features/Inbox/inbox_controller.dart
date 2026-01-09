import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'inbox_repository.dart';

class InboxController extends GetxController {
  final InboxRepository repository;
  final SupabaseClient supabase;

  InboxController({required this.repository, required this.supabase});

  final isLoading = true.obs;
  final users = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;
  final isSearching = false.obs;
  final searchResults = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get filteredUsers {
    if (searchQuery.value.isNotEmpty) {
      return searchResults;
    }
    return users;
  }

  @override
  void onInit() {
    super.onInit();
    loadUsers();

    // Debounce search to avoid too many API calls
    debounce(searchQuery, (query) {
      if (query.isNotEmpty) {
        performSearch(query);
      } else {
        searchResults.clear();
      }
    }, time: const Duration(milliseconds: 500));
  }

  Future<void> performSearch(String query) async {
    isLoading.value = true;
    try {
      searchResults.value = await repository.searchUsers(query);
    } catch (e) {
      // Handle error silently or show user-friendly message
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    try {
      users.value = await repository.fetchOtherUsers();
    } catch (e) {
      // Handle error silently or show user-friendly message
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startChat(Map<String, dynamic> user) async {
    final result = await repository.getOrCreateRoom(user['id']);

    Get.toNamed(
      '/chat',
      arguments: {
        'roomId': result['room_id'],
        'title': result['other_user_email'],
      },
    );
  }
}
