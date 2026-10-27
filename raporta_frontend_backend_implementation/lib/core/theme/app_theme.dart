import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final generated = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );

    // Light mode uses exact brand colors
    // Dark mode uses generated so some tones like navy don't disappear with dark background

    final scheme = brightness == Brightness.light
        ? generated.copyWith(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            error: AppColors.error,
          )
        : generated;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(48),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}
