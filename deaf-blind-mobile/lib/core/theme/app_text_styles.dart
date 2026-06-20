import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Montserrat typography scale matching UnaaMobile's AppTextStyles. Used by
/// every screen except the Deaf School home tab (which keeps Baloo2/Nunito
/// via [AppTheme.baloo]/[AppTheme.nunito]).
abstract final class AppTextStyles {
  static TextStyle h1 = GoogleFonts.montserrat(
    fontSize: 26,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle h2 = GoogleFonts.montserrat(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle h3 = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle bodyLarge = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle labelLarge = GoogleFonts.montserrat(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle labelMedium = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle labelSmall = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  /// Flexible Montserrat style, mirroring [AppTheme.baloo]/[AppTheme.nunito]'s
  /// signature so call sites can swap fonts without restructuring args.
  static TextStyle style({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.montserrat(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color ?? AppColors.textPrimary,
        height: height,
      );
}
