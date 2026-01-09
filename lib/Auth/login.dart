
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinterest/components/googlebutton.dart';
import 'package:pinterest/controller/Auth_controllers/login_ctrl.dart';
import 'package:pinterest/Auth/signup.dart';
import 'package:pinterest/components/pptheme.dart';
import 'package:pinterest/components/textfields.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    final scrh = MediaQuery.of(context).size.height;
    final scrw = MediaQuery.of(context).size.width;

    final isDark = Get.isDarkMode;
    final theme = isDark ? PpTheme.darkTheme : PpTheme.lightTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          "Login",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'Assets/oldage.png',
                  height: scrh * 0.26,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  "Welcome Back",
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 28),

                // Email + Password Fields
                AuthTextFields(
                  emailController: controller.loginEmailController,
                  passwordController: controller.loginPasswordController,
                ),
                const SizedBox(height: 24),

                // Login Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 23, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LOGIN BUTTON
                      SizedBox(
                        width: scrw * 0.4,
                        height: 56,
                        child: Hero(
                          tag: "login",
                          child: Obx(() {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed:
                                  controller.isLoading.value
                                      ? null
                                      : () =>
                                          controller.loginWithEmail(context),
                              child:
                                  controller.isLoading.value
                                      ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // GOOGLE BUTTON (EXACT SAME DECORATION)
                      const GoogleLoginButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Navigate to Sign Up
                TextButton(
                  onPressed: () => Get.to(() => const Signup()),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: "Sign Up",
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
