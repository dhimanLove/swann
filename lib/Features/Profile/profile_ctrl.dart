import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pinterest/Pages/onboarding.dart';


class _ProfileConsts {
  static const String bucketName = 'profile_pics';
  static const String profilePicsTable = 'profile_pics';
  static const String userMetaNameKey = 'name';
  static const String userMetaAvatarKey = 'avatar_url';
}

class ProfileController extends GetxController {
  Future<void> ensureAnonymousSession() async {
    final session = supabaseClient.auth.currentSession;

    if (session == null) {
      await supabaseClient.auth.signInAnonymously();
    }
  }

  final SupabaseClient supabaseClient = Supabase.instance.client;

  final Rx<User?> user = Rx<User?>(null);
  final RxString name = 'No Name'.obs;
  final RxString avatarUrl = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isUploading = false.obs;

  final ImagePicker picker = ImagePicker();

  StreamSubscription<AuthState>? _authSub;
  bool _pickLock = false;

  @override
  void onInit() {
    super.onInit();
    ensureAnonymousSession().then((_) {
      _listenAuthChanges();
      fetchUser();
    });
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  void _listenAuthChanges() {
    // If user signs out in another part of the app or token expires,
    // keep this screen in sync.
    _authSub = supabaseClient.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session == null) {
        // no session = logged out
        Get.offAll(() => const Onboarding());
      } else {
        // refresh user data
        fetchUser();
      }
    });
  }

  Future<void> fetchUser() async {
    try {
      final authUser = supabaseClient.auth.currentUser;
      if (authUser == null) {
        Get.offAll(() => const Onboarding());
        return;
      }
      user.value = authUser;

      // Defensive reads from user metadata
      final metadata = authUser.userMetadata ?? {};
      name.value =
          (metadata[_ProfileConsts.userMetaNameKey] as String?)
                      ?.trim()
                      .isNotEmpty ==
                  true
              ? metadata[_ProfileConsts.userMetaNameKey] as String
              : 'No Name';

      avatarUrl.value =
          (metadata[_ProfileConsts.userMetaAvatarKey] as String?)?.trim() ?? '';
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = "Failed to load profile.";
    }
  }

  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
      Get.offAll(() => const Onboarding());
    } catch (e) {
      Get.snackbar(
        "Sign out failed",
        "Please try again.",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> pickImage(BuildContext context) async {
    if (_pickLock) return;
    _pickLock = true;

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        _pickLock = false;
        return;
      }

      final imageFile = File(pickedFile.path);

      await showCupertinoDialog(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: const Text("Confirm Profile Picture"),
              content: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(imageFile, height: 150, fit: BoxFit.cover),
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text("Upload"),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await uploadImage(imageFile);
                  },
                ),
              ],
            ),
      );
    } finally {
      // release debounce lock after dialog completes
      _pickLock = false;
    }
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      isUploading.value = true;

      // Safer, more unique file name (userId + timestamp)
      final uid = supabaseClient.auth.currentUser?.id ?? 'anon';
      final fileName =
          "profile_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Upload to storage
      final res = await supabaseClient.storage
          .from(_ProfileConsts.bucketName)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );
      if (res.isEmpty) {
        throw "Upload failed — empty response.";
      }

      final publicUrl = supabaseClient.storage
          .from(_ProfileConsts.bucketName)
          .getPublicUrl(fileName);

      // Update auth metadata
      avatarUrl.value = publicUrl;
      await supabaseClient.auth.updateUser(
        UserAttributes(data: {_ProfileConsts.userMetaAvatarKey: publicUrl}),
      );

      // Persist record
      await supabaseClient.from(_ProfileConsts.profilePicsTable).insert({
        'user_id': supabaseClient.auth.currentUser?.id,
        'image_url': publicUrl,
        'uploaded_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        "Success",
        "Profile picture updated!",
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.dialog(
        CupertinoAlertDialog(
          title: const Text("Upload Failed"),
          content: Text("Error: $e"),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      );
    } finally {
      isUploading.value = false;
    }
  }
}
