import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1B2A6B); // navy: buttons, headers
  static const Color accent = Color(
    0xFF3B82F6,
  ); // bright blue: links, highlights
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF3F4F6); // cards, grey panels
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFD1D5DB);
  static const Color error = Color(0xFFC41E3A);
  static const Color success = Color(0xFF4C9A2A);

  // Report status colours, used by status_badge.dart
  static const Color statusPending = Color(0xFFB45309);
  static const Color statusUnderReview = Color(0xFF1D4ED8);
  static const Color statusForwarded = Color(0xFF6D28D9);
  static const Color statusInProgress = Color(0xFFC2410C);
  static const Color statusResolved = Color(0xFF15803D);
  static const Color statusDeclined = Color(0xFFB91C1C);
}
