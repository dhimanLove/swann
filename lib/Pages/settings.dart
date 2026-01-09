import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinterest/Pages/onboarding.dart';
import 'package:pinterest/controller/themecontrolller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final themeController = Get.find<ThemeController>();
  bool notificationsEnabled = true;
  bool isClearingCache = false;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool("notifications_enabled") ?? true;
    });
  }

  Future<void> handleClearCache() async {
    if (isClearingCache) return;
    setState(() => isClearingCache = true);

    try {
      var tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
      await Future.delayed(const Duration(milliseconds: 500));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Cache cleared successfully",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to clear cache: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isClearingCache = false);
    }
  }

  Future<void> handleNotificationsToggle(bool val) async {
    setState(() => notificationsEnabled = val);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("notifications_enabled", val);
  }

  void showThemeDialog(ThemeController controller) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text(
              "Choose App Theme",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 23),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _themeOptionTile(
                  icon: Icons.wb_sunny,
                  label: "Light Mode",
                  color: Colors.amber,
                  selected: controller.themeMode == ThemeMode.light,
                  onTap: () {
                    controller.setTheme(ThemeMode.light);
                    Navigator.of(context).pop();
                  },
                ),
                _themeOptionTile(
                  icon: Icons.nights_stay,
                  label: "Dark Mode",
                  color: Colors.blueGrey,
                  selected: controller.themeMode == ThemeMode.dark,
                  onTap: () {
                    controller.setTheme(ThemeMode.dark);
                    Navigator.of(context).pop();
                  },
                ),
                _themeOptionTile(
                  icon: Icons.settings,
                  label: "System Default",
                  color: Theme.of(context).colorScheme.secondary,
                  selected: controller.themeMode == ThemeMode.system,
                  onTap: () {
                    controller.setTheme(ThemeMode.system);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
    );
  }

  Widget _themeOptionTile({
    required IconData icon,
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(label),
      trailing: selected ? Icon(Icons.check_circle, color: color) : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      selected: selected,
      selectedTileColor: color.withOpacity(.1),
    );
  }

  void showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text(
                  "Select Language",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _languageTile("English", "🇬🇧"),
                      _languageTile("Hindi", "🇮🇳"),
                      _languageTile("French", "🇫🇷"),
                      _languageTile("Spanish", "🇪🇸"),
                      _languageTile("German", "🇩🇪"),
                      _languageTile("Japanese", "🇯🇵"),
                      _languageTile("Chinese", "🇨🇳"),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _languageTile(String name, String emoji) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      onTap: () {
        Get.back();
        Get.updateLocale(Locale(name.toLowerCase()));
        showCupertinoDialog(
          context: context,
          builder:
              (_) => CupertinoAlertDialog(
                title: Text("Language Updated"),
                content: Text("Language has been changed to $name"),
                actions: [
                  CupertinoDialogAction(
                    child: const Text("OK"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
        );
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void showAboutDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text("About Swan"),
            content: const Text(
              "Swan is a modern Pinterest-inspired social media app with secure login, realtime posts (Supabase), images, emoji reactions, and adaptive theming.",
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              centerTitle: true,
              title: Text(
                "Settings",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Quicksand',
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: theme.iconTheme.color,
                  size: 22,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Account", theme),
                    sectionCard([
                      settingsTile(
                        icon: Icons.security,
                        label: "Privacy & Security",
                        onTap: () {},
                        theme: theme,
                      ),
                      settingsTile(
                        icon: Icons.cleaning_services,
                        label: "Clear Cache",
                        trailing:
                            isClearingCache
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CupertinoActivityIndicator(
                                    animating: true,
                                  ),
                                )
                                : Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: theme.hintColor,
                                ),
                        onTap: handleClearCache,
                        theme: theme,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    sectionLabel("Preferences", theme),
                    sectionCard([
                      GetBuilder<ThemeController>(
                        builder:
                            (controller) => settingsTile(
                              icon: Icons.color_lens,
                              label: "Appearance",
                              onTap: () => showThemeDialog(controller),
                              theme: theme,
                            ),
                      ),
                      cupertinoSwitchTile(
                        label: "Notifications",
                        value: notificationsEnabled,
                        onChanged: handleNotificationsToggle,
                        theme: theme,
                        icon: Icons.notifications_active,
                      ),
                      settingsTile(
                        icon: Icons.language,
                        label: "Language",
                        onTap: showLanguagePicker,
                        theme: theme,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    sectionLabel("App", theme),
                    sectionCard([
                      settingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: "Privacy Policy",
                        onTap: () {},
                        theme: theme,
                      ),
                      settingsTile(
                        icon: Icons.article_outlined,
                        label: "Terms of Service",
                        onTap: () {},
                        theme: theme,
                      ),
                      settingsTile(
                        icon: Icons.info_outline,
                        label: "About",
                        onTap: showAboutDialog,
                        theme: theme,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: theme.colorScheme.error,
                          size: 26,
                        ),
                        title: Text(
                          "Logout",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: showLogoutDialog,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Common setting list tile with icon
  ListTile settingsTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 24,
        color: theme.colorScheme.onSurfaceVariant, // softer, not too bright
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface, // natural text color
        ),
      ),
      trailing:
          trailing ??
          Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      visualDensity: VisualDensity.compact, // tighter look
    );
  }

  /// Cupertino Switch tile with label, icon
  Widget cupertinoSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
    IconData icon = Icons.notifications,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: theme.colorScheme.primary, // highlight only here
          ),
        ],
      ),
    );
  }

  /// Section label
  Widget sectionLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget sectionCard(List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1.5,
      color: Theme.of(context).cardColor,
      shadowColor: Colors.black12,
      child: Column(children: children),
    );
  }

  void showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              CupertinoDialogAction(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text("Logout"),
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  Navigator.of(context).pop();
                  Get.offAll(() => const Onboarding());
                },
              ),
            ],
          ),
    );
  }
}
