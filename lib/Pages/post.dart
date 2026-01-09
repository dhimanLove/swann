import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinterest/controller/post_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return CupertinoPageScaffold(
        // navigationBar: CupertinoNavigationBar(
        // middle: Text(
        //  "Create Pin",
        //  style: TextStyle(
        //   fontFamily: 'Quicksand',
        //   fontSize: 28,
        //   fontWeight: FontWeight.w400,
        //   color: isDark ? Colors.white : Colors.black,
        //   letterSpacing: 2,
        //  ),
        // ),
        // ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("Assets/lod.png", height: 100, width: 100),
                const SizedBox(height: 20),
                const Text(
                  "Create an account first",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 10),
                const Text(
                  "You need to be logged in to post images.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  borderRadius: BorderRadius.circular(12),

                  onPressed: () => Get.toNamed('/login'),
                  child: const Text("Login / Sign up"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final controller = Get.put(PostController());
    final theme = Theme.of(context);
    final scrh = MediaQuery.of(context).size.height;
    final scrw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GetBuilder<PostController>(
        builder:
            (_) => CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  elevation: 0,
                  title: Text(
                    "Post media",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Quicksand',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(scrw * 0.05),
                    child: Column(
                      children: [
                        SizedBox(height: scrh * 0.06),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          CupertinoIcons.photo,
                                          size: scrw * 0.1,
                                          color: theme.iconTheme.color 
                                              ?.withOpacity(0.6), // fixed here
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
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        controller.selectedImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: controller.descriptionController,
                          maxLines: 3,
                          maxLength: 300,
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
            ),
      ),
    );
  }
}
