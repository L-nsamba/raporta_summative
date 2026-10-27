import 'package:flutter/material.dart';

import 'app_colors.dart';

// No colour on the main styles, so light and dark themes control it.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle body = TextStyle(fontSize: 14);
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}
