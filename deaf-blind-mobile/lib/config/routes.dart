import 'package:go_router/go_router.dart';

import '../features/deaf_school/presentation/deaf_school_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const DeafSchoolShell(),
    ),
  ],
);
