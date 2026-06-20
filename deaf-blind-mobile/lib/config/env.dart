/// Environment configuration — injected at build time via --dart-define.
///
/// Android emulator → host machine is 10.0.2.2 (NOT localhost)
/// iOS Simulator   → host machine is localhost
/// Physical device → use your Mac's LAN IP, e.g. 192.168.1.x
///
/// Usage:
///   flutter run --dart-define=BACKEND_URL=http://10.0.2.2:9000   (Android emu)
///   flutter run --dart-define=BACKEND_URL=http://localhost:9000    (iOS sim)
///   flutter run --dart-define=BACKEND_URL=http://192.168.1.x:9000 (real device)
class Env {
  /// Injected at build time. Default covers Android emulator.
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://10.0.2.2:9000',
  );

  static const String apiPrefix = '/api/v1';

  static const String backendProd =
      String.fromEnvironment('BACKEND_URL_PROD', defaultValue: 'https://deaf-blind-api-prod-xxxxx.a.run.app');
}
