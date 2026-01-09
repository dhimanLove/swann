import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class AuthTextFields extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? usernameController;
  final TextEditingController? phoneController;
  final TextEditingController? otpController;
  final bool showUsernameField;
  final bool isOtpMode;
  final bool otpSent;

  const AuthTextFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.usernameController,
    this.phoneController,
    this.otpController,
    this.showUsernameField = false,
    this.isOtpMode = false,
    this.otpSent = false,
  });

  @override
  State<AuthTextFields> createState() => _AuthTextFieldsState();
}

class _AuthTextFieldsState extends State<AuthTextFields> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final double scrh = MediaQuery.of(context).size.height;

    // Theme-based colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final backgroundColor =
        isDark
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.systemGrey5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showUsernameField && widget.usernameController != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: CupertinoTextField(
              controller: widget.usernameController,
              placeholder: 'Username',
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: scrh * 0.015,
              ),
              style: TextStyle(color: textColor, fontFamily: "Chillax"),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        if (widget.isOtpMode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: CupertinoTextField(
              controller: widget.phoneController,
              placeholder: 'Phone Number',
              keyboardType: TextInputType.phone,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: scrh * 0.015,
              ),
              style: TextStyle(color: textColor, fontFamily: "Chillax"),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        if (widget.isOtpMode && widget.otpSent)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: OtpTextField(
              numberOfFields: 6,
              showFieldAsBox: true,
              borderRadius: BorderRadius.circular(12),
              focusedBorderColor: backgroundColor,
              enabledBorderColor: backgroundColor,
              textStyle: TextStyle(color: textColor, fontFamily: "Chillax"),
              onCodeChanged: (value) {
                if (widget.otpController != null) {
                  widget.otpController!.text = value;
                }
              },
              onSubmit: (value) {
                if (widget.otpController != null) {
                  widget.otpController!.text = value;
                }
              },
            ),
          ),
        if (!widget.isOtpMode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: CupertinoTextField(
              controller: widget.emailController,
              placeholder: 'Email',
              keyboardType: TextInputType.emailAddress,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: scrh * 0.015,
              ),
              style: TextStyle(color: textColor, fontFamily: "Chillax"),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        if (!widget.isOtpMode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                CupertinoTextField(
                  controller: widget.passwordController,
                  placeholder: 'Password',
                  obscureText: _obscurePassword,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: scrh * 0.015,
                  ),
                  style: TextStyle(color: textColor, fontFamily: "Chillax"),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                    child: Icon(
                      _obscurePassword
                          ? CupertinoIcons.eye
                          : CupertinoIcons.eye_slash,
                      color:
                          isDark
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.systemGrey2,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
