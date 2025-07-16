import 'package:flutter/material.dart';
import 'package:people_management/utils/app_colors.dart';
import 'package:people_management/utils/app_styles.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppStyles.inputTextStyle,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppStyles.subHeadingStyle,
        filled: true,
        fillColor: AppColors.cardColor,
        prefixIcon:
            prefixIcon != null
                ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: prefixIcon,
                )
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primaryPurple,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
      ),
    );
  }
}
