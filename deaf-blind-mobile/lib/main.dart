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
  if (!kIsWeb && Platform.isAndroid) {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      isPhysicalDevice = androidInfo.isPhysicalDevice;
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }
  }

  Env.init(isPhysicalDevice: isPhysicalDevice);

  runApp(const ProviderScope(child: DeafBlindApp()));
}
