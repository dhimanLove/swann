import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pinterest/Features/Inbox/inbox_page.dart';
import 'package:pinterest/Pages/homescreen.dart';
import 'package:pinterest/Pages/post.dart';
import 'package:pinterest/Features/Profile/profile_page.dart';
import 'package:pinterest/Pages/search.dart';

class GoogleNav extends StatefulWidget {
  const GoogleNav({super.key});

  @override
  State<GoogleNav> createState() => _GoogleNavState();
}

class _GoogleNavState extends State<GoogleNav> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    HomePage(),
    InboxPage(),
    PostScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth >= 600;

        return Scaffold(
          extendBody: !isWideScreen,
          body: Row(
            children: [
              if (isWideScreen)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  extended: true,
                  onDestinationSelected: _onItemTapped,
                  backgroundColor: theme.colorScheme.surface,
                  labelType: NavigationRailLabelType.none,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(CupertinoIcons.home),
                      ),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(CupertinoIcons.chat_bubble),
                      ),
                      label: Text('Messages'),
                    ),
                    NavigationRailDestination(
                      icon: Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(CupertinoIcons.add_circled),
                      ),
                      label: Text('Post'),
                    ),
                    NavigationRailDestination(
                      icon: Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(CupertinoIcons.search),
                      ),
                      label: Text('Search'),
                    ),
                    NavigationRailDestination(
                      icon: Padding(
                        padding: EdgeInsets.only(right: 12, bottom: 4),
                        child: Icon(CupertinoIcons.person),
                      ),
                      label: Text('Profile'),
                    ),
                  ],
                ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: _pages,
                ),
              ),
            ],
          ),

          bottomNavigationBar: isWideScreen ? null : _buildBottomNav(context),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: GNav(
          selectedIndex: _selectedIndex,
          gap: 8,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          tabBackgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          activeColor: theme.colorScheme.primary,
          color: theme.iconTheme.color,
          iconSize: 24,
          onTabChange: _onItemTapped,
          tabs: const [
            GButton(icon: CupertinoIcons.home),
            GButton(icon: CupertinoIcons.chat_bubble),
            GButton(icon: CupertinoIcons.add_circled),
            GButton(icon: CupertinoIcons.search),
            GButton(icon: CupertinoIcons.person),
          ],
        ),
      ),
    );
  }
}
