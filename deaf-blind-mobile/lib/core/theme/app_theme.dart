import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_colors.dart';

/// App theme matching the Deaf School HTML design.
class AppTheme {
  static TextStyle baloo({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.baloo2(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w700,
        color: color ?? DesignColors.textDark,
        height: height,
      );

  static TextStyle nunito({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w800,
        color: color ?? DesignColors.textDark,
        height: height,
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: DesignColors.bg,
        fontFamily: GoogleFonts.nunito().fontFamily,
        colorScheme: const ColorScheme.light(
          primary: DesignColors.purple,
          surface: DesignColors.bg,
        ),
      );
}
