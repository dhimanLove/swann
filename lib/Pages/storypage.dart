import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Storycontroller extends GetxController {
  File? selectedImage;
  final descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      selectedImage = File(pickedImage.path);
      update();
    }
  }

  Future<void> postImage() async {
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

    showCupertinoDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder:
          (_) => const CupertinoAlertDialog(
            title: Text("Uploading"),
            content: Padding(
              padding: EdgeInsets.only(top: 16),
              child: CupertinoActivityIndicator(radius: 15),
            ),
          ),
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

      Get.back();

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
      Get.back();

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

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Storycontroller());
    final theme = Theme.of(context);
    final scrh = MediaQuery.of(context).size.height;
    final scrw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GetBuilder<Storycontroller>(
        builder: (_) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                elevation: 0,
                backgroundColor: theme.scaffoldBackgroundColor,
                title: const Text('Create Pin'),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(scrw * 0.05),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: controller.pickImage,
                        child: Container(
                          height: scrh * 0.3,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade700),
                          ),
                          child:
                              controller.selectedImage == null
                                  ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.photo,
                                        size: scrw * 0.1,
                                        color: theme.iconTheme.color
                                            ?.withOpacity(0.6),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Tap to select an image',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.grey),
                                      ),
                                    ],
                                  )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.file(
                                      controller.selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: controller.descriptionController,
                        maxLines: 3,
                        maxLength: 100,
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: theme.cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.5,
                            ),
                          ),
                          hintText: 'Add a description',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      CupertinoButton.filled(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        onPressed: controller.postImage,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.cloud_upload),
                            SizedBox(width: 8),
                            Text('Save Pin'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
