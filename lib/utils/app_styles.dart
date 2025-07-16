import 'package:flutter/material.dart';
import 'package:people_management/utils/app_colors.dart';

class AppStyles {
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 16,
    color: AppColors.hintColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.cardColor,
  );

  static const TextStyle linkTextStyle = TextStyle(
    fontSize: 14,
    color: AppColors.linkColor,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle inputTextStyle = TextStyle(
    fontSize: 16,
    color: AppColors.textColor,
  );

  static const TextStyle rememberMeStyle = TextStyle(
    fontSize: 14,
    color: AppColors.textColor,
  );
}
