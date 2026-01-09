import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  String appVersion = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "${info.version}+${info.buildNumber}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          "About Swan",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontFamily: 'Quicksand',
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            // Logo or App Icon (replace with your own asset)
            Center(
              child: CircleAvatar(
                radius: 52,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                child: Icon(
                  CupertinoIcons.app,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: Text(
                "Swan",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "A modern, responsive + scalable social media app inspired by Pinterest.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                  fontFamily: 'Quicksand',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(thickness: 1, color: isDark ? Colors.grey[900] : Colors.grey),
            const SizedBox(height: 12),

            _featureIconTile(
              icon: CupertinoIcons.lock,
              label: "Secure Authentication",
              description: "Sign-up and login using Firebase Auth for robust security."
            ),
            _featureIconTile(
              icon: CupertinoIcons.photo_on_rectangle,
              label: "Upload & Share Posts",
              description: "Share images, add descriptions, and express yourself."
            ),
            _featureIconTile(
              icon: CupertinoIcons.bubble_left_bubble_right,
              label: "Realtime Feed Updates",
              description: "Supabase powers lightning-fast, live social feeds."
            ),
            _featureIconTile(
              icon: CupertinoIcons.heart_fill,
              label: "Expressive Media Interactions",
              description: "React with emoji, like, comment, and interact just like Pinterest."
            ),
            _featureIconTile(
              icon: CupertinoIcons.device_phone_portrait,
              label: "Cross-Platform",
              description: "Enjoy a smooth experience on both Android & iOS devices."
            ),
            _featureIconTile(
              icon: CupertinoIcons.paintbrush,
              label: "Dynamic Theming",
              description: "Beautiful, automatically adapting UI with Light, Dark, and System themes."
            ),
            const SizedBox(height: 18),

            Divider(thickness: 1, color: isDark ? Colors.grey[900] : Colors.grey),
            const SizedBox(height: 12),

            Text(
              "Tech Stack",
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            _techChipRow([
              "Flutter",
              "GetX",
              "Firebase Auth",
              "Supabase RTDB",
              "Image Picker",
              "Cupertino Icons",
              "Emoji Support"
            ]),
            const SizedBox(height: 24),

            Text(
              "Open Source • Fast • Stunning UI",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                "Version: $appVersion",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontFamily: 'Quicksand'
                ),
              ),
            ),
            const SizedBox(height: 8),

            Center(
              child: Text(
                "GitHub: dhimanLove/Swan",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureIconTile({required IconData icon, required String label, required String description}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, size: 32, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(description, style: theme.textTheme.bodySmall),
      horizontalTitleGap: 16,
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
    );
  }

  Widget _techChipRow(List<String> chips) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8,
      children: chips.map((text) => Chip(
        label: Text(text, style: theme.textTheme.bodySmall),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
      )).toList(),
    );
  }
}
