import 'package:get/get.dart';
import 'package:pinterest/Features/Inbox/inbox_page.dart';
import 'package:pinterest/Features/Chat/chat_page.dart';
import 'package:pinterest/Pages/onboarding.dart';
import 'package:pinterest/Auth/login.dart';
import 'package:pinterest/Auth/signup.dart';

import 'package:pinterest/Features/Inbox/inbox_binding.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String inbox = '/inbox';
  static const String chat = '/chat';

  static final List<GetPage> pages = [
    GetPage(name: onboarding, page: () => const Onboarding()),
    GetPage(name: login, page: () => const Login()),
    GetPage(name: signup, page: () => const Signup()),
    GetPage(
      name: inbox,
      page: () => const InboxPage(),
      binding: InboxBinding(),
    ),
    GetPage(name: chat, page: () => const ChatScreen()),
  ];
}
