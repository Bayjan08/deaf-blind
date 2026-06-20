import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_colors.dart';


/// §7 AI Gesture Camera Screen.
///
/// Supports two recognition modes from [hand_tracker.html]:
///   1. Static quick-gesture (8 words): payload `{ type:"gesture", label, landmarks }`
///      → POST /translation/ai/interpret-gesture (Gemini)
///   2. Slovo RSL clip (1000 words): payload `{ type:"clip", frames:[32 base64 JPEGs] }`
///      → POST /translation/ai/recognize-clip (ONNX MViTv2-small-32)
///
/// Both paths add the resulting word to the captured-chips row and speak it
/// aloud via flutter_tts.
class GestureCameraScreen extends StatefulWidget {
  const GestureCameraScreen({super.key});

  @override
  State<GestureCameraScreen> createState() => _GestureCameraScreenState();
}

class _GestureCameraScreenState extends State<GestureCameraScreen> {
  // ── captured gestures ──────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _captured = [];

  // ── UI state ───────────────────────────────────────────────────────────────
  bool _isClipProcessing = false;
  bool _isMakingSentence = false;
  String? _sentenceText;
  String? _error;

  // ── services ───────────────────────────────────────────────────────────────
  final _api = ApiClient();
  final _tts = FlutterTts();

  InAppWebViewController? _webController;
  bool _cameraGranted = false;
  bool _cameraDenied = false;

  @override
  void initState() {
    super.initState();
    _initTts();
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

  Future<void> _initTts() async {
    await _tts.setLanguage('ru-RU');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  // ── Route incoming JS payload ──────────────────────────────────────────────
  Future<void> _onGesturePayload(String jsonStr) async {
    late Map<String, dynamic> payload;
    try {
      payload = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    if (payload['type'] == 'clip') {
      final frames = (payload['frames'] as List?)?.cast<String>() ?? [];
      if (frames.isNotEmpty) await _onClip(frames);
    }
  }

  // ── 32 JPEG frames → Slovo MViTv2 ONNX → Russian word ──────────────────────
  Future<void> _onClip(List<String> frames) async {
    HapticFeedback.heavyImpact();

    setState(() {
      _isClipProcessing = true;
      _sentenceText = null;
      _error = null;
    });

    try {
      final res = await _api.dio.post<Map<String, dynamic>>(
        '/translation/ai/recognize-clip',
        data: {'frames': frames},
      );
      final word = (res.data?['text'] as String?)?.trim() ?? '';

      if (mounted) {
        if (word.isEmpty) {
          setState(() {
            _isClipProcessing = false;
            _error = 'Жест не распознан — повторите';
          });
        } else {
          setState(() {
            _captured.add({'label': word, 'aiWord': word});
            _isClipProcessing = false;
          });
          await _speak(word);
          // Let the WebView show the result on its pill
          _webController?.evaluateJavascript(
            source: "window.clipDone && clipDone(${jsonEncode(word)})",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isClipProcessing = false;
          _error = 'Ошибка: ${e.toString().split('\n').first}';
        });
      }
    }
  }

  // ── Make sentence (Gemini) ─────────────────────────────────────────────────
  Future<void> _makeSentence() async {
    if (_captured.isEmpty) return;
    final labels = _captured.map((e) => e['label'] as String).toList();

    setState(() {
      _isMakingSentence = true;
      _sentenceText = null;
      _error = null;
    });

    try {
      final res = await _api.dio.post<Map<String, dynamic>>(
        '/translation/ai/interpret-sequence',
        data: {'labels': labels},
      );
      final sentence =
          (res.data?['text'] as String?)?.trim() ?? labels.join(' ');
      if (mounted) {
        setState(() {
          _sentenceText = sentence;
          _isMakingSentence = false;
        });
        await _speak(sentence);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gemini: ${e.toString().split('\n').first}';
          _isMakingSentence = false;
        });
      }
    }
  }

  void _removeCapture(int i) => setState(() {
        _captured.removeAt(i);
        _sentenceText = null;
      });

  void _clear() => setState(() {
        _captured.clear();
        _sentenceText = null;
        _error = null;
      });

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('AI Переводчик жестов',
            style: AppTheme.baloo(color: Colors.white, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded),
            onPressed: () =>
                _webController?.evaluateJavascript(source: 'switchCamera()'),
            tooltip: 'Сменить камеру',
          ),
          if (_captured.isNotEmpty)
            IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _clear),
        ],
      ),
      body: Column(
        children: [
          Expanded(flex: 6, child: _buildWebView()),
          Expanded(flex: 4, child: _buildControls()),
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
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        useHybridComposition: true,
      ),
      onWebViewCreated: (ctrl) {
        _webController = ctrl;
        ctrl.addJavaScriptHandler(
          handlerName: 'GestureChannel',
          callback: (args) {
            if (args.isNotEmpty) _onGesturePayload(args[0].toString());
          },
        );
      },
      onPermissionRequest: (_, request) async => PermissionResponse(
        resources: request.resources,
        action: PermissionResponseAction.GRANT,
      ),
      onConsoleMessage: (_, msg) => debugPrint('[WV] ${msg.message}'),
    );
  }

  Widget _buildControls() {
    final busy = _isClipProcessing || _isMakingSentence;

    return Container(
      color: DesignColors.bg,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status line
          Row(
            children: [
              if (_isClipProcessing) ...[
                const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFFFF9800))),
                const SizedBox(width: 8),
                Text('🧠 Распознаю жест РЖЯ...',
                    style: AppTheme.nunito(
                        fontSize: 11, color: const Color(0xFFFF9800))),
              ] else
                Text(
                  _captured.isEmpty
                      ? '✋ Покажите жест — запись начнётся автоматически'
                      : '🎙 Слово добавлено и произнесено',
                  style: AppTheme.nunito(
                      fontSize: 11, color: DesignColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Captured word chips
          if (_captured.isNotEmpty)
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _captured.asMap().entries.map((e) {
                  final aiWord = e.value['aiWord'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InputChip(
                      label: Text(aiWord,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                      onDeleted: () => _removeCapture(e.key),
                      onPressed: () => _speak(aiWord),
                      backgroundColor: DesignColors.purpleSoft,
                      deleteIconColor: DesignColors.purple,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }).toList(),
              ),
            ),

          const Spacer(),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_captured.length < 2 || busy) ? null : _makeSentence,
                  icon: _isMakingSentence
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text('Составить фразу',
                      style: AppTheme.baloo(color: Colors.white, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C3AE8),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: DesignColors.purpleSoft,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: _sentenceText != null
                    ? () => _speak(_sentenceText!)
                    : (_captured.isNotEmpty
                        ? () => _speak(_captured.last['aiWord'] as String)
                        : null),
                icon: const Icon(Icons.volume_up_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: DesignColors.purpleSoft,
                  foregroundColor: DesignColors.purple,
                ),
                tooltip: 'Повторить',
              ),
            ],
          ),

          // AI sentence result
          if (_sentenceText != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _speak(_sentenceText!),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignColors.purpleSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: DesignColors.purple.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 16, color: Color(0xFF6C3AE8)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _sentenceText!,
                        style: AppTheme.baloo(
                            fontSize: 18, color: DesignColors.purple),
                      ),
                    ),
                    const Icon(Icons.volume_up_rounded,
                        size: 16, color: Color(0xFF6C3AE8)),
                  ],
                ),
              ),
            ),
          ],

          // Error
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(_error!,
                style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}
