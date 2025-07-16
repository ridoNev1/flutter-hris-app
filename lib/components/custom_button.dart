import 'package:flutter/material.dart';
import 'package:people_management/utils/app_colors.dart';
import 'package:people_management/utils/app_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.primaryPurple,
    this.textColor = AppColors.cardColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          shadowColor: AppColors.primaryPurple.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 10)],
            Text(
              text,
              style: AppStyles.buttonTextStyle.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
