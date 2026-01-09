import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CupertinoSocialDrawer extends StatefulWidget {
  const CupertinoSocialDrawer({super.key});

  @override
  State<CupertinoSocialDrawer> createState() => _CupertinoSocialDrawerState();
}

class _CupertinoSocialDrawerState extends State<CupertinoSocialDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void openDrawer() => _controller.forward();
  void closeDrawer() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    bool isDark = Get.isDarkMode;

    return Stack(
      children: [
        CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text("Cupertino Social Drawer"),
            trailing: GestureDetector(
              onTap: openDrawer,
              child: const Icon(CupertinoIcons.bars),
            ),
          ),
          child: Center(
            child: Text(
              "Swipe or tap menu icon to open drawer",
              style: TextStyle(
                  color: isDark ? CupertinoColors.white : CupertinoColors.black),
            ),
          ),
        ),

        SlideTransition(
          position: _animation,
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              color: isDark
                  ? CupertinoColors.darkBackgroundGray
                  : CupertinoColors.systemGrey6,
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, offset: Offset(3, 0))
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                              "https://i.pravatar.cc/150?img=3"),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("John Doe",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? CupertinoColors.white
                                        : CupertinoColors.black)),
                            Text("@johndoe",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? CupertinoColors.systemGrey
                                        : CupertinoColors.systemGrey2)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const Divider(),

                  // Social Links
                  drawerItem(CupertinoIcons.home, "Home", isDark, context),
                  drawerItem(CupertinoIcons.chat_bubble_text, "Messages", isDark, context),
                  drawerItem(CupertinoIcons.bell, "Notifications", isDark, context),
                  drawerItem(CupertinoIcons.settings, "Settings", isDark, context),
                  const Spacer(),

                  // Logout
                  drawerItem(CupertinoIcons.arrow_right_circle, "Logout", isDark, context),
                ],
              ),
            ),
          ),
        ),

        // Tap outside to close
        if (_controller.isCompleted)
          GestureDetector(
            onTap: closeDrawer,
            child: Container(color: Colors.black26),
          ),
      ],
    );
  }

  Widget drawerItem(IconData icon, String title, bool isDark, BuildContext context) {
    return GestureDetector(
      onTap: () {
        closeDrawer();
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text("You tapped on $title"),
            actions: [
              CupertinoDialogAction(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                  // Add any action logic here
                },
              ),
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: isDark
                    ? CupertinoColors.white
                    : CupertinoColors.black),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? CupertinoColors.white
                      : CupertinoColors.black),
            ),
          ],
        ),
      ),
    );
  }
}
