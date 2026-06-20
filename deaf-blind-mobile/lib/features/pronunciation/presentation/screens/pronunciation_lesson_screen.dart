import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/ml/mouth_metrics.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_colors.dart';
import '../../domain/models/lesson_phase.dart';
import '../providers/pronunciation_provider.dart';
import '../widgets/mouth_compare.dart';

/// §4.3 Camera mouth-shape practice for single letters. Visual-first comparison
/// for deaf/HoH *sighted* learners (the haptic cue is the only blind-accessible
/// part). Mouth tracking runs as MediaPipe Face Mesh inside a WebView — the same
/// approach as the hand-gesture tracker — so it works on Android and iOS.
class PronunciationLessonScreen extends ConsumerStatefulWidget {
  const PronunciationLessonScreen({
    super.key,
    required this.onBack,
    this.lessonKey = 'А',
  });

  final VoidCallback onBack;
  final String lessonKey;

  @override
  ConsumerState<PronunciationLessonScreen> createState() =>
      _PronunciationLessonScreenState();
}

class _PronunciationLessonScreenState
    extends ConsumerState<PronunciationLessonScreen> {
  // v1 alphabet scope — must match backend visemes.LETTER_VISEMES.
  static const _letters = ['А', 'О', 'У', 'И', 'Ы', 'Э', 'М', 'Б', 'П', 'Ф', 'В'];

  InAppWebViewController? _web;
  String _selected = 'А';
  bool _cameraGranted = false;
  bool _cameraDenied = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.lessonKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pronunciationControllerProvider).load(_selected);
    });
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

  void _selectLetter(String letter) {
    setState(() => _selected = letter);
    ref.read(pronunciationControllerProvider).load(letter);
  }

  void _onMouthFrame(dynamic raw) {
    final controller = ref.read(pronunciationControllerProvider);
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      if (data['face'] == true && data['metrics'] is Map) {
        controller.onFrame(
          MouthMetrics.fromJson(
            (data['metrics'] as Map).cast<String, dynamic>(),
          ),
        );
      } else {
        controller.onFrame(null);
      }
    } catch (_) {
      controller.onFrame(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(pronunciationControllerProvider);
    return Scaffold(
      backgroundColor: DesignColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onBack: widget.onBack,
              onFlip: () => _web?.evaluateJavascript(source: 'switchCamera();'),
            ),
            const _DisclaimerBanner(),
            _LetterStrip(letters: _letters, selected: _selected, onTap: _selectLetter),
            Expanded(flex: 5, child: _webView()),
            Expanded(flex: 5, child: _bottom(c)),
          ],
        ),
      ),
    );
  }

  Widget _webView() {
    if (_cameraDenied) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            color: DesignColors.bg,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_off_rounded, size: 32, color: DesignColors.textMuted),
                  const SizedBox(height: 8),
                  Text(
                    'Camera permission is required for pronunciation practice.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: DesignColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: openAppSettings,
                    child: const Text('Open settings'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (!_cameraGranted) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InAppWebView(
          initialFile: 'assets/html/mouth_tracker.html',
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            useHybridComposition: true,
          ),
          onWebViewCreated: (controller) {
            _web = controller;
            controller.addJavaScriptHandler(
              handlerName: 'MouthChannel',
              callback: (args) {
                if (args.isNotEmpty) _onMouthFrame(args[0]);
              },
            );
          },
          onPermissionRequest: (controller, request) async => PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT,
          ),
          onConsoleMessage: (_, msg) => debugPrint('[MouthWebView] ${msg.message}'),
        ),
      ),
    );
  }

  Widget _bottom(PronunciationController c) {
    switch (c.phase) {
      case LessonPhase.loading:
        return const Center(child: CircularProgressIndicator());
      case LessonPhase.error:
        return _ErrorView(message: c.error ?? 'Something went wrong', onRetry: c.retry);
      case LessonPhase.reviewing:
        return const Center(child: CircularProgressIndicator());
      case LessonPhase.result:
        return _ResultView(controller: c);
      case LessonPhase.calibrating:
      case LessonPhase.ready:
      case LessonPhase.cueing:
      case LessonPhase.recording:
        return _PracticeView(controller: c);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onFlip});
  final VoidCallback onBack;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: DesignColors.textDark),
          ),
          Expanded(
            child: Text(
              'Pronunciation',
              style: AppTheme.baloo(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: onFlip,
            icon: const Icon(Icons.flip_camera_ios_rounded, color: DesignColors.textMuted),
            tooltip: 'Switch camera',
          ),
        ],
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: DesignColors.orangeSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined, size: 16, color: DesignColors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Visual practice for deaf/HoH sighted learners. '
              'The rhythm buzz works without sight.',
              style: TextStyle(
                fontSize: 11,
                color: DesignColors.textMuted,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterStrip extends StatelessWidget {
  const _LetterStrip({
    required this.letters,
    required this.selected,
    required this.onTap,
  });

  final List<String> letters;
  final String selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: letters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final letter = letters[i];
          final active = letter == selected;
          return GestureDetector(
            onTap: () => onTap(letter),
            child: Container(
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? DesignColors.purple : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: DesignColors.purpleSoft),
              ),
              child: Text(
                letter,
                style: AppTheme.baloo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : DesignColors.textDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PracticeView extends StatelessWidget {
  const _PracticeView({required this.controller});
  final PronunciationController controller;

  @override
  Widget build(BuildContext context) {
    final lesson = controller.lesson!;
    final recording = controller.phase == LessonPhase.recording;
    final liveCues = controller.liveComparison?.cues ?? const <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Say "${lesson.word}"  ${lesson.phoneme}',
            style: AppTheme.baloo(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            lesson.instructions,
            style: TextStyle(
              fontSize: 13,
              color: DesignColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          // Live, on-screen directional cues while the user speaks.
          if (!controller.faceDetected)
            _LiveHint(text: 'Center your face in the camera', color: DesignColors.textMuted)
          else if (liveCues.isEmpty)
            _LiveHint(text: '✓ Great shape — hold it!', color: DesignColors.green)
          else
            ...liveCues.map((cue) => _LiveHint(text: cue, color: DesignColors.purple)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: recording ? null : controller.playCue,
            icon: const Icon(Icons.vibration_rounded),
            label: Text(controller.phase == LessonPhase.cueing
                ? 'Feel the rhythm…'
                : 'Feel the rhythm'),
            style: OutlinedButton.styleFrom(
              foregroundColor: DesignColors.purple,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: recording ? controller.finishAttempt : controller.startRecording,
            style: FilledButton.styleFrom(
              backgroundColor: recording ? DesignColors.redLive : DesignColors.purple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(
              recording ? 'Stop' : 'Try',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveHint extends StatelessWidget {
  const _LiveHint({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(Icons.adjust_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.controller});
  final PronunciationController controller;

  @override
  Widget build(BuildContext context) {
    final lesson = controller.lesson!;
    final feedbackText = controller.serverFeedback?.feedbackText ??
        (controller.score >= 0.8
            ? "Nicely done — that's very close!"
            : 'Good try — keep adjusting:');
    final cues = controller.serverFeedback?.cues ??
        controller.resultComparison?.cues ??
        const <String>[];
    final aiFeedback = controller.serverFeedback?.aiFeedbackText;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MouthCompare(
            target: lesson.targetMidpoints,
            attempt: controller.capturedMetrics,
          ),
          const SizedBox(height: 16),
          Text(
            feedbackText,
            style: AppTheme.baloo(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...cues.map(
            (cue) => _LiveHint(text: cue, color: DesignColors.purple),
          ),
          if (aiFeedback != null && aiFeedback.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignColors.purpleSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.graphic_eq_rounded, size: 18, color: DesignColors.purple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      aiFeedback,
                      style: TextStyle(
                        fontSize: 13,
                        color: DesignColors.textDark,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: controller.tryAgain,
            style: FilledButton.styleFrom(
              backgroundColor: DesignColors.purple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text(
              'Try again',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 36, color: DesignColors.orange),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: DesignColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: DesignColors.purple),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
