import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

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

  /// Override LiveKit URL from backend (e.g. ws://10.0.2.2:7880 on Android emulator).
  static const String livekitUrlOverride = String.fromEnvironment(
    'LIVEKIT_URL',
    defaultValue: '',
  );

  /// Dev identity — use different values on two devices when testing.
  static const String userId = String.fromEnvironment(
    'USER_ID',
    defaultValue: 'user-a',
  );

  static const String displayName = String.fromEnvironment(
    'USER_NAME',
    defaultValue: 'User A',
  );

  static String resolveLivekitUrl(String fromBackend) {
    if (livekitUrlOverride.isNotEmpty) return livekitUrlOverride;

    final backendUri = Uri.tryParse(baseUrl);
    final livekitUri = Uri.tryParse(fromBackend);
    if (backendUri == null || livekitUri == null) return fromBackend;

    // Use the same host as BACKEND_URL so LiveKit is reachable from the device
    // (physical iPhone cannot use localhost; Android emulator needs 10.0.2.2).
    final backendHost = backendUri.host;
    if (backendHost.isNotEmpty &&
        backendHost != 'localhost' &&
        backendHost != '127.0.0.1') {
      return livekitUri.replace(host: backendHost).toString();
    }

    if (!kIsWeb && Platform.isAndroid) {
      return fromBackend
          .replaceAll('localhost', '10.0.2.2')
          .replaceAll('127.0.0.1', '10.0.2.2');
    }

    // iOS/macOS: prefer IPv4 loopback — WebSocket/WebRTC can fail on ::1.
    return fromBackend
        .replaceAll('localhost', '127.0.0.1')
        .replaceAll('[::1]', '127.0.0.1');
  }
}
