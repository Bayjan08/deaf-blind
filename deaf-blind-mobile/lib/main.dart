import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'config/env.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isPhysicalDevice = false;
  String deviceLabel = 'unknown';

  if (!kIsWeb && Platform.isAndroid) {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      isPhysicalDevice = androidInfo.isPhysicalDevice;
      deviceLabel = 'Android ${isPhysicalDevice ? "physical" : "emulator"} — ${androidInfo.model}';
    } catch (e) {
      deviceLabel = 'Android (device info error: $e)';
    }
  } else if (!kIsWeb && Platform.isIOS) {
    try {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      isPhysicalDevice = iosInfo.isPhysicalDevice;
      deviceLabel = 'iOS ${isPhysicalDevice ? "physical" : "simulator"} — ${iosInfo.utsname.machine}';
    } catch (e) {
      deviceLabel = 'iOS (device info error: $e)';
    }
  }

  Env.init(isPhysicalDevice: isPhysicalDevice);

  debugPrint('🌐 [ENV] device=$deviceLabel');
  debugPrint('🌐 [ENV] isPhysicalDevice=$isPhysicalDevice');
  debugPrint('🌐 [ENV] baseUrl=${Env.baseUrl}');

  runApp(const ProviderScope(child: DeafBlindApp()));
}
