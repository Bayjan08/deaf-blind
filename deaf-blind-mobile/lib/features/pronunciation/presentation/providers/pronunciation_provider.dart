import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/ml/mouth_comparator.dart';
import '../../../../core/ml/mouth_metrics.dart';
import '../../../../core/network/api_client.dart';
import '../../data/pronunciation_remote_source.dart';
import '../../data/pronunciation_repository.dart';
import '../../domain/models/articulation_lesson.dart';
import '../../domain/models/lesson_phase.dart';

final pronunciationApiClientProvider = Provider<ApiClient>((_) => ApiClient());

final pronunciationRepositoryProvider = Provider<PronunciationRepository>((ref) {
  return PronunciationRepository(
    PronunciationRemoteSource(ref.watch(pronunciationApiClientProvider)),
  );
});

final pronunciationControllerProvider =
    ChangeNotifierProvider.autoDispose<PronunciationController>((ref) {
  return PronunciationController(ref.watch(pronunciationRepositoryProvider));
});

/// Drives the letter mouth-shape lesson:
/// loading -> ready -> cueing -> recording -> reviewing -> result.
///
/// Mouth metrics arrive frame-by-frame from the WebView ([onFrame]); the camera
/// itself lives in `mouth_tracker.html`. The mouth shape judges the attempt; an
/// optional audio clip is recorded only for a teacher to review later.
class PronunciationController extends ChangeNotifier {
  PronunciationController(this._repo);

  final PronunciationRepository _repo;
  final HapticService _haptics = const VibrationHapticService();
  final MouthComparator _comparator = const MouthComparator();
  final AudioRecorder _recorder = AudioRecorder();

  static const _recordingWindow = Duration(milliseconds: 2500);

  Timer? _recordTimer;
  String _lessonKey = 'А';

  LessonPhase _phase = LessonPhase.loading;
  ArticulationLesson? _lesson;
  String? _error;

  MouthMetrics? _liveMetrics;
  MouthComparison? _liveComparison; // live, on-screen cues while speaking

  MouthMetrics? _bestMetrics;
  double _bestScore = -1;

  MouthComparison? _resultComparison;
  AttemptFeedback? _serverFeedback;
  String? _audioPath;

  // ---- exposed state ----
  LessonPhase get phase => _phase;
  ArticulationLesson? get lesson => _lesson;
  String? get error => _error;
  bool get faceDetected => _liveMetrics != null;
  MouthMetrics? get liveMetrics => _liveMetrics;
  MouthComparison? get liveComparison => _liveComparison;
  MouthMetrics? get capturedMetrics => _bestMetrics;
  MouthComparison? get resultComparison => _resultComparison;
  AttemptFeedback? get serverFeedback => _serverFeedback;
  double get score => _resultComparison?.coarseScore ?? 0;

  Future<void> load(String key) async {
    _lessonKey = key;
    _setPhase(LessonPhase.loading);
    try {
      _lesson = await _repo.lesson(key);
      _setPhase(LessonPhase.ready);
    } catch (e) {
      _fail('Could not load the lesson: $e');
    }
  }

  /// Called by the screen for every metrics frame posted from the WebView.
  void onFrame(MouthMetrics? m) {
    _liveMetrics = m;
    final lesson = _lesson;
    if (m != null && lesson != null) {
      _liveComparison = _comparator.compare(m, lesson.targetMetrics);
      if (_phase == LessonPhase.recording && _liveComparison!.coarseScore > _bestScore) {
        _bestScore = _liveComparison!.coarseScore;
        _bestMetrics = m;
      }
    } else {
      _liveComparison = null;
    }
    notifyListeners();
  }

  Future<void> playCue() async {
    final lesson = _lesson;
    if (lesson == null || _phase == LessonPhase.cueing) return;
    _setPhase(LessonPhase.cueing);
    await _haptics.playPattern(lesson.stressPattern);
    if (_phase == LessonPhase.cueing) _setPhase(LessonPhase.ready);
  }

  Future<void> startRecording() async {
    if (_lesson == null || _phase == LessonPhase.recording) return;
    _bestMetrics = null;
    _bestScore = -1;
    _resultComparison = null;
    _serverFeedback = null;
    _audioPath = null;
    await _startAudio();
    _setPhase(LessonPhase.recording);
    _recordTimer = Timer(_recordingWindow, finishAttempt);
  }

  Future<void> finishAttempt() async {
    _recordTimer?.cancel();
    final lesson = _lesson;
    if (lesson == null || _phase != LessonPhase.recording) return;

    _audioPath = await _stopAudio();

    final best = _bestMetrics ?? _liveMetrics;
    if (best == null) {
      _fail('No mouth detected during the attempt. Face the camera and retry.');
      return;
    }
    _bestMetrics = best;
    _resultComparison = _comparator.compare(best, lesson.targetMetrics);
    _setPhase(LessonPhase.reviewing);

    try {
      _serverFeedback = await _repo.submitAttempt(
        targetViseme: lesson.viseme,
        metrics: best.toJson(),
        audioPath: _audioPath,
      );
    } catch (e) {
      debugPrint('Attempt submit failed: $e'); // keep on-device cues
    }
    _setPhase(LessonPhase.result);
  }

  void tryAgain() {
    _resultComparison = null;
    _serverFeedback = null;
    _setPhase(LessonPhase.ready);
  }

  Future<void> _startAudio() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/pron_attempt.wav';
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: path,
        );
      }
    } catch (e) {
      debugPrint('Audio start failed (continuing without audio): $e');
    }
  }

  Future<String?> _stopAudio() async {
    try {
      if (await _recorder.isRecording()) return await _recorder.stop();
    } catch (e) {
      debugPrint('Audio stop failed: $e');
    }
    return null;
  }

  void _setPhase(LessonPhase p) {
    _phase = p;
    if (p != LessonPhase.error) _error = null;
    notifyListeners();
  }

  void _fail(String message) {
    _error = message;
    _phase = LessonPhase.error;
    notifyListeners();
  }

  void retry() => load(_lessonKey);

  @override
  void dispose() {
    _recordTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
