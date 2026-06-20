import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/routes.dart';
import '../core/theme/app_theme.dart';

/// Root app widget. Wires the router and theme.
class DeafBlindApp extends ConsumerWidget {
  const DeafBlindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Deaf-Blind School',
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
