import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pinterest/components/bottomnav.dart';


class SignUpController extends GetxController {
  final supabaseClient = Supabase.instance.client;
  final signupUsernameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  RxBool isLoading = false.obs;

  // Future<void> signInAnonymously() async {
  //   final supabase = Supabase.instance.client;
  //   final session = supabase.auth.currentSession;
  //   // Already signed in (anon or real user)
  //   if (session != null) return;
  //   await supabase.auth.signInAnonymously();
  // }

  Future<void> signup(BuildContext context) async {
    final email = signupEmailController.text.trim();
    final password = signupPasswordController.text;
    final username = signupUsernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: const Text("Signup Failed"),
              content: const Text("All fields must be filled."),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Get.back(),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
      return;
    }

    try {
      isLoading.value = true;

      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => const CupertinoAlertDialog(
              content: CupertinoActivityIndicator(
                radius: 15,
                color: CupertinoColors.white,
              ),
            ),
      );

      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': username},
      );

      if (response.user != null) {
        try {
          await supabaseClient.from('profiles').insert({
            'id': response.user!.id,
            'email': email,
            'display_name': username,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          debugPrint('Error creating profile: $e');
          // Optional: Show a non-blocking error or reliable retrying could be added here
        }

        Get.back(); // Close loading dialog
        Get.offAll(() => const GoogleNav());
      } else {
        showCupertinoDialog(
          context: context,
          builder:
              (_) => CupertinoAlertDialog(
                title: const Text("Signup Failed"),
                content: const Text("$e"),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () => Get.back(),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      Get.back();

      String errorMessage = "$e";

      if (e.toString().contains("User already registered") ||
          e.toString().contains("duplicate key")) {
        errorMessage = "This email is already registered.";
      } else if (e.toString().contains("Invalid login credentials")) {
        errorMessage = "Incorrect email or password.";
      } else if (e.toString().contains("network")) {
        errorMessage = "Please check your internet connection.";
      }

      showCupertinoDialog(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: const Text("Signup Failed"),
              content: Text(errorMessage),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Get.back(),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    signupUsernameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    super.onClose();
  }
}
