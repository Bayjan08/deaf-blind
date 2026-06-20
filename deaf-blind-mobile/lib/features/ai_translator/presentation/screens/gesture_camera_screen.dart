import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_client.dart';

// Gesture label → Russian meaning (must match backend vocabulary.py)
const _kMeaning = {
  'hello': 'Привет',
  'yes'  : 'Да',
  'no'   : 'Нет',
  'stop' : 'Стоп',
  'good' : 'Хорошо',
  'bad'  : 'Плохо',
  'help' : 'Помощь',
  'thanks': 'Спасибо',
};

/// §7 Gesture camera screen.
/// A WebView loads assets/html/hand_tracker.html which runs MediaPipe Hands
/// (21 finger joints, cyan dots + skeleton) in JavaScript. When the user
/// holds a gesture for ~1.5 s the JS sends a label through the
/// [GestureChannel] JavaScript handler back to Flutter.
class GestureCameraScreen extends StatefulWidget {
  const GestureCameraScreen({super.key});

  @override
  State<GestureCameraScreen> createState() => _GestureCameraScreenState();
}

class _GestureCameraScreenState extends State<GestureCameraScreen> {
  // ── captured gesture labels ─────────────────────────────────────────────
  final List<String> _capturedLabels = [];
  String? _lastGestureKey; // shows the most-recently detected label in the strip

  // ── translation state ───────────────────────────────────────────────────
  String? _translatedText;
  bool _isTranslating = false;
  String? _translationError;

  // ── WebView ─────────────────────────────────────────────────────────────
  // ignore: unused_field — kept for future JS calls (e.g. reset gesture state)
  InAppWebViewController? _webController;
  bool _cameraGranted = false;
  bool _cameraDenied = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() {
      _cameraGranted = status.isGranted;
      _cameraDenied = !status.isGranted;
    });
  }

  // ── JS → Flutter: gesture received ──────────────────────────────────────
  void _onGestureDetected(String key) {
    HapticFeedback.mediumImpact();
    setState(() {
      _lastGestureKey = key;
      _capturedLabels.add(key);
      _translatedText = null;
      _translationError = null;
    });
  }

  void _removeLabel(int i) => setState(() {
        _capturedLabels.removeAt(i);
        _translatedText = null;
      });

  void _clear() => setState(() {
        _capturedLabels.clear();
        _translatedText = null;
        _translationError = null;
        _lastGestureKey = null;
      });

  Future<void> _translate() async {
    if (_capturedLabels.isEmpty) return;
    setState(() {
      _isTranslating = true;
      _translationError = null;
    });
    try {
      final text =
          await TranslationClient(ApiClient()).signToText(_capturedLabels);
      if (mounted) setState(() => _translatedText = text);
    } catch (_) {
      if (mounted) {
        setState(() => _translationError =
            'Бэкенд недоступен. Запустите сервер.');
      }
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  void _toggleCamera() {
    _webController?.evaluateJavascript(source: 'switchCamera();');
  }

  void _toggleMirror() {
    _webController?.evaluateJavascript(source: 'toggleMirror();');
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Распознавание жестов',
            style: AppTextStyles.style(color: Colors.white, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded),
            onPressed: _toggleCamera,
            tooltip: 'Переключить камеру',
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: _toggleMirror,
            tooltip: 'Отразить зеркально',
          ),
          if (_capturedLabels.isNotEmpty)
            IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _clear),
        ],
      ),
      body: Column(
        children: [
          // ── WebView (camera + MediaPipe overlay) ──────────────────────
          Expanded(
            flex: 6,
            child: _buildWebView(),
          ),
          // ── Captured labels + translate UI ────────────────────────────
          Expanded(
            flex: 4,
            child: _buildControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    if (_cameraDenied) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_rounded, size: 32, color: Colors.white70),
              const SizedBox(height: 8),
              const Text(
                'Camera permission is required for gesture recognition.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: openAppSettings,
                child: const Text('Open settings'),
              ),
            ],
          ),
        ),
      );
    }
    if (!_cameraGranted) {
      return const Center(child: CircularProgressIndicator());
    }
    return InAppWebView(
      initialFile: 'assets/html/hand_tracker.html',
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,   // camera auto-starts
        allowsInlineMediaPlayback: true,
        transparentBackground: false,
        useHybridComposition: true,                 // smoother Android rendering
        useShouldOverrideUrlLoading: false,
      ),
      onWebViewCreated: (controller) {
        _webController = controller;
        // Register JS → Dart handler.
        // HTML calls: window.flutter_inappwebview.callHandler('GestureChannel', key)
        controller.addJavaScriptHandler(
          handlerName: 'GestureChannel',
          callback: (args) {
            if (args.isNotEmpty && args[0] is String) {
              _onGestureDetected(args[0] as String);
            }
          },
        );
      },
      onPermissionRequest: (controller, request) async {
        // Grant camera (and mic, if requested) automatically.
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      onConsoleMessage: (_, msg) {
        // Mirror JS console to Dart debug output so errors are visible.
        debugPrint('[WebView] ${msg.message}');
      },
    );
  }

  Widget _buildControls() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status / last detected gesture
          Text(
            _lastGestureKey != null
                ? '✅  Захвачено: ${_kMeaning[_lastGestureKey] ?? _lastGestureKey}'
                : '📡  Удерживайте жест — он добавится автоматически',
            style: AppTextStyles.style(
                fontSize: 11, color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Captured label chips (scrollable row)
          if (_capturedLabels.isNotEmpty)
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _capturedLabels.asMap().entries.map((e) {
                  final label = _kMeaning[e.value] ?? e.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InputChip(
                      label: Text(label,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                      onDeleted: () => _removeLabel(e.key),
                      backgroundColor: AppColors.grey100,
                      deleteIconColor: AppColors.primary,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }).toList(),
              ),
            ),
          const Spacer(),
          // Translate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_capturedLabels.isEmpty || _isTranslating)
                  ? null
                  : _translate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.grey100,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _isTranslating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(
                      'Перевести'
                      '${_capturedLabels.isNotEmpty ? " (${_capturedLabels.length})" : ""}',
                      style:
                          AppTextStyles.style(color: Colors.white, fontSize: 15)),
            ),
          ),
          // Translation result
          if (_translatedText != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _translatedText!,
                style: AppTextStyles.style(
                    fontSize: 20, color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (_translationError != null) ...[
            const SizedBox(height: 8),
            Text(_translationError!,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
