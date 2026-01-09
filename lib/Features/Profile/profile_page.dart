// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinterest/Features/Profile/edit_profile_page.dart';
import 'package:pinterest/Pages/settings.dart';
import 'package:pinterest/Features/Profile/profile_ctrl.dart';

import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(
        () => Stack(
          children: [
            // Header gradient uses primary + secondary for better match
            Container(height: size.height * 0.35),

            // Main content scroll
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Top bar: title + settings icon
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Your Profile",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          height: size.height * 0.05,
                          width: size.width * 0.11,
                          child: IconButton(
                            onPressed: () => Get.to(const SettingsScreen()),
                            icon: Icon(
                              CupertinoIcons.settings_solid,
                              color: theme.colorScheme.onPrimary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Avatar + name card floating over header
                  SizedBox(height: size.height * 0.02),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Card area
                      Container(
                        margin: EdgeInsets.only(
                          top: size.height * 0.08,
                          left: 20,
                          right: 20,
                          bottom: 24,
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
                        decoration: BoxDecoration(
                          color:
                              theme.cardTheme.color ??
                              theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Name + email
                            Text(
                              controller.name.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontSize: 22,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.user.value?.email ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // (reserved for stats row / extra info)
                            const SizedBox(height: 28),

                            if (controller.errorMessage.value.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  controller.errorMessage.value,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),

                            // Buttons row
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: size.height * 0.055,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color:
                                              theme.dividerTheme.color ??
                                              theme.dividerColor,
                                          width: 1.1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        foregroundColor:
                                            theme.colorScheme.onSurface,
                                      ),
                                      onPressed:
                                          () => Get.to(
                                            () => const EditProfileScreen(),
                                          ),
                                      child: Text(
                                        "Edit Profile",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: size.height * 0.055,
                                    child: Obx(() {
                                      final isFollowing =
                                          false.obs; // your logic
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                          backgroundColor:
                                              isFollowing.value
                                                  ? theme.colorScheme.secondary
                                                  : theme
                                                          .elevatedButtonTheme
                                                          .style
                                                          ?.backgroundColor
                                                          ?.resolve({}) ??
                                                      theme.colorScheme.primary,
                                          foregroundColor:
                                              theme.colorScheme.onPrimary,
                                        ),
                                        onPressed:
                                            () =>
                                                isFollowing.value =
                                                    !isFollowing.value,
                                        child: Text(
                                          isFollowing.value
                                              ? "Following"
                                              : "Follow",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Avatar
                      Semantics(
                        label: 'Profile picture. Double tap to change.',
                        button: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.pickImage(context),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    theme.cardTheme.color ??
                                    theme.colorScheme.surface,
                                width: 4,
                              ),
                            ),
                            child: ClipOval(
                              child: _Avatar(
                                url: controller.avatarUrl.value,
                                size: 110,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (controller.isUploading.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CupertinoActivityIndicator(radius: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Avatar widget with cached image + graceful placeholders
class _Avatar extends StatelessWidget {
  final String url;
  final double size;
  const _Avatar({required this.url, this.size = 100});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // tune placeholder to your PpTheme surfaces
    final placeholderColor = theme.canvasColor;
    final iconColor =
        theme.iconTheme.color?.withOpacity(0.6) ??
        theme.colorScheme.onSurface.withOpacity(0.6);

    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: placeholderColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        CupertinoIcons.person_fill,
        color: iconColor,
        size: size * 0.5,
      ),
    );

    if (url.isEmpty) return placeholder;

    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder:
          (context, _) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator.adaptive(strokeWidth: 2.4),
            ),
          ),
      errorWidget: (context, _, __) => placeholder,
    );
  }
}
