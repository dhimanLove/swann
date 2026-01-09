import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'inbox_controller.dart';
import 'inbox_repository.dart';

class InboxBinding extends Bindings {
  @override
  void dependencies() {
    final supabase = Supabase.instance.client;
    Get.put(InboxController(
      repository: InboxRepository(supabase),
      supabase: supabase,
    ));
  }
}
