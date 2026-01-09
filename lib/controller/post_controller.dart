import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
 
class PostController extends GetxController {
  File? selectedImage;
  final descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        selectedImage = File(pickedImage.path);
        update();
      }
    } catch (e) {
      Get.dialog(
        CupertinoAlertDialog(
          title: const Text("Error"),
          content: Text("Image picking failed: $e"),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      );
    }
  }

  Future<void> postImage() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      Get.dialog(
        const CupertinoAlertDialog(
          title: Text("Not Allowed"),
          content: Text("Please create an account first."),
        ),
      );
      return;
    }

    final desc = descriptionController.text.trim();

    if (selectedImage == null || desc.isEmpty) {
      Get.dialog(
        const CupertinoAlertDialog(
          title: Text("Error"),
          content: Text("Please select an image and add a description!"),
        ),
      );
      return;
    }

    Get.dialog(
      const CupertinoAlertDialog(
        title: Text("Uploading"),
        content: Padding(
          padding: EdgeInsets.only(top: 16),
          child: CupertinoActivityIndicator(radius: 15),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final imageName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await selectedImage!.readAsBytes();
      final storage = Supabase.instance.client.storage;

      await storage
          .from('interest')
          .uploadBinary(
            imageName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final imageUrl = storage.from('interest').getPublicUrl(imageName);

      await Supabase.instance.client.from('interest').insert({
        'image_url': imageUrl,
        'description': desc,
        'created_at': DateTime.now().toIso8601String(),
      });

      Get.back(); // close loading

      Get.dialog(
        const CupertinoAlertDialog(
          title: Text("Uploaded"),
          content: Text("Post uploaded successfully!"),
        ),
      );

      selectedImage = null;
      descriptionController.clear();
      update();
    } catch (e) {
      Get.back(); // close loading

      Get.dialog(
        CupertinoAlertDialog(
          title: const Text("Upload Failed"),
          content: Text("Error occurred: ${e.toString()}"),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      );
    }
  }
}
