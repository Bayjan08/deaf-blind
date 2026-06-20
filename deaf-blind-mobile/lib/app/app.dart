import 'package:flutter/material.dart';

import '../config/routes.dart';
import '../core/theme/app_theme.dart';

/// Root app widget. Wires the router and theme.
class DeafBlindApp extends StatelessWidget {
  const DeafBlindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Deaf-Blind School',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
