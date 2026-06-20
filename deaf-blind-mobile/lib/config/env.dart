import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Environment configuration — injected at build time via --dart-define.
///
/// How each device reaches the LOCAL backend (uvicorn on the Mac, port 9000):
///   Android emulator → 10.0.2.2      (special host alias inside the emulator)
///   iOS Simulator    → 127.0.0.1     (simulator shares the Mac's network stack)
///   Physical iPhone  → Mac LAN IP    (e.g. 192.168.0.140) + SAME WiFi network
///
/// The backend MUST be started bound to all interfaces so the phone can reach it:
///   uvicorn main:app --reload --host 0.0.0.0 --port 9000
///
/// Override at build time (works on any device / any network):
///   flutter run --dart-define=BACKEND_URL=http://192.168.0.140:9000
class Env {
  /// Your Mac's current LAN IP. Update this if your WiFi network/IP changes
  /// (check with: `ipconfig getifaddr en0`).
  static const String _macLanIp = '192.168.0.140';

  static String _resolvedBaseUrl = const String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://$_macLanIp:9000',
  );

  static bool _isPhysicalDevice = false;

  static String get baseUrl => _resolvedBaseUrl;

  static void init({required bool isPhysicalDevice}) {
    _isPhysicalDevice = isPhysicalDevice;
    const injected = String.fromEnvironment('BACKEND_URL');
    if (injected.isNotEmpty) {
      _resolvedBaseUrl = injected;
      return;
    }
    // No override — pick the right host automatically for the running device.
    if (isPhysicalDevice) {
      // Physical iPhone/Android: localhost would mean the phone itself.
      // Must hit the Mac over the LAN (phone + Mac on the same WiFi).
      _resolvedBaseUrl = 'http://$_macLanIp:9000';
    } else if (!kIsWeb && Platform.isAndroid) {
      // Android emulator: the host Mac is reachable via 10.0.2.2.
      _resolvedBaseUrl = 'http://10.0.2.2:9000';
    } else {
      // iOS Simulator / macOS: shares the Mac's network — localhost is the Mac.
      _resolvedBaseUrl = 'http://127.0.0.1:9000';
    }
  }

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

    if (!kIsWeb && Platform.isAndroid && !_isPhysicalDevice) {
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
