import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinterest/controller/Auth_controllers/signup_ctrl.dart';

import 'package:pinterest/Auth/login.dart';

import 'package:pinterest/components/pptheme.dart';
import 'package:pinterest/components/textfields.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    final SignUpController controller = Get.put(SignUpController());
    final scrh = MediaQuery.of(context).size.height;
    final scrw = MediaQuery.of(context).size.width;

    final isDark = Get.isDarkMode;
    final theme = isDark ? PpTheme.darkTheme : PpTheme.lightTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        automaticallyImplyLeading: false,
        title: Text("Sign Up", style: theme.appBarTheme.titleTextStyle),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'Assets/otter.png',
                  height: scrh * 0.26,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  "Create your account",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // CupertinoButton(
                //   padding: EdgeInsets.zero,
                //   onPressed: () => Get.offAll(() => const GoogleNav()),
                //   child: RichText(
                //     text: TextSpan(
                //       style: TextStyle(
                //         fontSize: 16,
                //         color: theme.colorScheme.onSurface.withOpacity(0.7),
                //       ),
                //       children: const [
                //         TextSpan(text: "Continue as "),
                //         TextSpan(
                //           text: "Anonymous",
                //           style: TextStyle(
                //             fontFamily: "Chillax",
                //             color: CupertinoColors.activeBlue,
                //             fontWeight: FontWeight.w600,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                const SizedBox(height: 28),
                AuthTextFields(
                  usernameController: controller.signupUsernameController,
                  emailController: controller.signupEmailController,
                  passwordController: controller.signupPasswordController,
                  showUsernameField: true,
                ),
                const SizedBox(height: 24),
                Hero(
                  tag: "login",
                  child: SizedBox(
                    width: scrw * 0.4,
                    child: Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed:
                            controller.isLoading.value
                                ? null
                                : () => controller.signup(context),
                        child:
                            controller.isLoading.value
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  "Sign Up",
                                  // style handled by theme
                                ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed:
                      () => Get.to(
                        () => const Login(),
                        transition: Transition.cupertino,
                      ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      children: [
                        const TextSpan(text: "Already have an account? "),
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            // fontFamily: "Chillax", // Removed hardcoded font
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
