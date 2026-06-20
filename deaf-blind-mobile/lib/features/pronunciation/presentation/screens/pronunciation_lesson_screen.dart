import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_colors.dart';
import '../../domain/models/lesson_phase.dart';
import '../providers/pronunciation_provider.dart';
import '../widgets/calibration_view.dart';
import '../widgets/mouth_compare.dart';

/// §4.3 Camera mouth-shape practice. Visual-first comparison for deaf/HoH
/// *sighted* learners (the haptic cue is the only blind-accessible part).
class PronunciationLessonScreen extends ConsumerStatefulWidget {
  const PronunciationLessonScreen({
    super.key,
    required this.onBack,
    this.lessonKey = 'AA',
  });

  final VoidCallback onBack;
  final String lessonKey;

  @override
  ConsumerState<PronunciationLessonScreen> createState() =>
      _PronunciationLessonScreenState();
}

class _PronunciationLessonScreenState
    extends ConsumerState<PronunciationLessonScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pronunciationControllerProvider).load(widget.lessonKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(pronunciationControllerProvider);
    return Scaffold(
      backgroundColor: DesignColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: widget.onBack),
            const _DisclaimerBanner(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: _body(c),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(PronunciationController c) {
    switch (c.phase) {
      case LessonPhase.loading:
        return const Center(child: CircularProgressIndicator());
      case LessonPhase.error:
        return _ErrorView(message: c.error ?? 'Something went wrong', onRetry: () {
          ref.read(pronunciationControllerProvider).load(widget.lessonKey);
        });
      case LessonPhase.calibrating:
        return SingleChildScrollView(
          child: CalibrationView(
            controller: c.tracker.cameraController,
            supported: c.trackingSupported,
            faceDetected: c.liveFace != null,
            onCalibrate: c.calibrate,
          ),
        );
      case LessonPhase.reviewing:
        return const Center(child: CircularProgressIndicator());
      case LessonPhase.result:
        return _ResultView(controller: c);
      case LessonPhase.ready:
      case LessonPhase.cueing:
      case LessonPhase.recording:
        return _PracticeView(controller: c);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              'Visual practice for deaf/hard-of-hearing sighted learners. '
              'The rhythm buzz works without sight.',
              style: TextStyle(
                fontSize: 11.5,
                color: DesignColors.textMuted,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Say "${lesson.word}"  ${lesson.phoneme}',
            style: AppTheme.baloo(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            lesson.instructions,
            style: TextStyle(
              fontSize: 14,
              color: DesignColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          CameraPreviewBox(
            controller: controller.tracker.cameraController,
            supported: controller.trackingSupported,
            overlayColor: recording
                ? DesignColors.redLive
                : (controller.liveFace != null
                    ? DesignColors.green
                    : DesignColors.textDim),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: recording ? null : controller.playCue,
            icon: const Icon(Icons.vibration_rounded),
            label: Text(
              controller.phase == LessonPhase.cueing
                  ? 'Feel the rhythm…'
                  : 'Feel the rhythm',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: DesignColors.purple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: recording
                ? controller.finishAttempt
                : controller.startRecording,
            style: FilledButton.styleFrom(
              backgroundColor:
                  recording ? DesignColors.redLive : DesignColors.purple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              recording ? 'Stop' : 'Start attempt',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
        controller.localComparison?.cues ??
        const <String>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MouthCompare(
            target: lesson.targetMidpoints,
            attempt: controller.capturedMetrics,
          ),
          const SizedBox(height: 20),
          Text(
            feedbackText,
            style: AppTheme.baloo(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...cues.map(
            (cue) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.adjust_rounded,
                      size: 18, color: DesignColors.purple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cue,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: DesignColors.textDark,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: controller.tryAgain,
            style: FilledButton.styleFrom(
              backgroundColor: DesignColors.purple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 40, color: DesignColors.orange),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: DesignColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(backgroundColor: DesignColors.purple),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
