import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pinterest/Auth/authgate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pinterest/components/pptheme.dart';
import 'package:pinterest/controller/themecontrolller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await GetStorage.init();
  Get.put(ThemeController());

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Swan',
          theme: PpTheme.lightTheme,
          darkTheme: PpTheme.darkTheme,
          themeMode: controller.themeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}
