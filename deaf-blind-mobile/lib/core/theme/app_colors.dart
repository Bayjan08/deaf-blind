import 'package:flutter/material.dart';

/// Unaa-style neutral palette. Used by every screen except the Deaf School
/// home tab, which keeps [DesignColors] (lib/core/theme/design_colors.dart)
/// so its look stays exactly as designed.
abstract final class AppColors {
  // Primary
  static const Color primary = Color(0xFF000000);
  static const Color buttonPrimary = Color(0xFF000000);
  static const Color primaryLight = Color(0xFF1A1A1A);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF5F5F5);

  // Text
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Grey scale
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF2563EB);

  // Shadows
  static const Color shadowLight = Color(0x14000000);
  static const Color shadowMedium = Color(0x1A000000);
}

/// Shadow presets matching UnaaMobile's AppShadows scale.
abstract final class AppShadows {
  static final light = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 3,
      spreadRadius: 2,
      offset: const Offset(0, 2),
    ),
  ];

  static final medium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      spreadRadius: 1,
      offset: const Offset(0, 4),
    ),
  ];

  static final heavy = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];
}
