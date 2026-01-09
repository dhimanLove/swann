import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pinterest/components/bottomnav.dart';

class LoginController extends GetxController {
  final supabaseClient = Supabase.instance.client;

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> loginWithEmail(BuildContext context) async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showDialog(
        context,
        "Login Failed",
        "Email and password cannot be empty.",
      );
      return;
    }

    try {
      isLoading.value = true;

      final res = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        // Ensure profile exists
        try {
          final user = res.user!;
          final displayName = user.userMetadata?['name'] ?? email.split('@')[0];

          await supabaseClient.from('profiles').upsert({
            'id': user.id,
            'email': email,
            'display_name': displayName,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'id');
        } catch (e) {
          debugPrint('Error syncing profile: $e');
        }

        Get.offAll(() => const GoogleNav());
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        _showDialog(context, "Login Failed", e.message);
      }
    } catch (_) {
      if (context.mounted) {
        _showDialog(
          context,
          "Login Failed",
          "Something went wrong. Try again.",
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  
                  //  IMPORTANT: remove focus first
                  // FocusManager.instance.primaryFocus?.unfocus();

                  Get.back();
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    super.onClose();
  }
}
