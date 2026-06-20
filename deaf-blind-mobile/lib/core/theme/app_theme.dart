import 'package:flutter/material.dart';

/// App theme. High-contrast / large-touch defaults suit accessibility needs.
class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      );
}
