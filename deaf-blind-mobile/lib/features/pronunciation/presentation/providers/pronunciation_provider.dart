import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/ml/face_landmark_models.dart';
import '../../../../core/ml/mlkit_face_tracker.dart';
import '../../../../core/ml/mouth_comparator.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/local_storage.dart';
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

final localStorageProvider = Provider<LocalStorage>((_) => SharedPrefsLocalStorage());

final pronunciationControllerProvider =
    ChangeNotifierProvider.autoDispose<PronunciationController>((ref) {
  return PronunciationController(
    ref.watch(pronunciationRepositoryProvider),
    ref.watch(localStorageProvider),
  );
});

/// Drives the camera mouth-shape lesson flow:
/// loading -> calibrating -> ready -> cueing -> recording -> reviewing -> result.
class PronunciationController extends ChangeNotifier {
  PronunciationController(this._repo, this._storage);

  final PronunciationRepository _repo;
  final LocalStorage _storage;
  final MlkitFaceTracker _tracker = MlkitFaceTracker();
  final HapticService _haptics = const VibrationHapticService();
  final MouthComparator _comparator = const MouthComparator();

  static const _recordingWindow = Duration(milliseconds: 2500);
  static const _neutralKey = 'pron_neutral_metrics';

  StreamSubscription<FaceLandmarks>? _sub;
  Timer? _recordTimer;

  LessonPhase _phase = LessonPhase.loading;
  ArticulationLesson? _lesson;
  String? _error;

  FaceLandmarks? _liveFace;
  MouthMetrics? _liveMetrics;

  FaceLandmarks? _bestFace;
  MouthMetrics? _bestMetrics;
  double _bestScore = -1;

  MouthComparison? _localComparison;
  AttemptFeedback? _serverFeedback;

  // ---- exposed state ----
  LessonPhase get phase => _phase;
  ArticulationLesson? get lesson => _lesson;
  String? get error => _error;
  MlkitFaceTracker get tracker => _tracker;
  bool get trackingSupported => _tracker.isSupported;
  FaceLandmarks? get liveFace => _liveFace;
  FaceLandmarks? get capturedFace => _bestFace;
  MouthMetrics? get capturedMetrics => _bestMetrics;
  MouthComparison? get localComparison => _localComparison;
  AttemptFeedback? get serverFeedback => _serverFeedback;
  double get score => _localComparison?.coarseScore ?? 0;

  Future<void> load(String key) async {
    _setPhase(LessonPhase.loading);
    try {
      _lesson = await _repo.lesson(key);
      await _tracker.start();
      _sub = _tracker.landmarks.listen(_onFrame);
      // Skip calibration if we already have a stored neutral baseline.
      final hasBaseline = (await _storage.read(_neutralKey)) != null;
      _setPhase(hasBaseline ? LessonPhase.ready : LessonPhase.calibrating);
    } catch (e) {
      _fail('Could not load the lesson: $e');
    }
  }

  void _onFrame(FaceLandmarks face) {
    _liveFace = face;
    _liveMetrics = mouthMetricsFrom(face);
    if (_phase == LessonPhase.recording && _liveMetrics != null) {
      _trackBest(face, _liveMetrics!);
    }
    notifyListeners();
  }

  void _trackBest(FaceLandmarks face, MouthMetrics m) {
    final lesson = _lesson;
    if (lesson == null) return;
    final score = _comparator.compare(m, lesson.targetMetrics).coarseScore;
    if (score > _bestScore) {
      _bestScore = score;
      _bestFace = face;
      _bestMetrics = m;
    }
  }

  /// Stores the neutral-face baseline on-device only (never sent to backend).
  Future<void> calibrate() async {
    final m = _liveMetrics;
    if (m == null) {
      _fail('Face not detected — make sure your face is centered and lit.');
      return;
    }
    await _storage.write(_neutralKey, jsonEncode(m.toJson()));
    _setPhase(LessonPhase.ready);
  }

  Future<void> playCue() async {
    final lesson = _lesson;
    if (lesson == null || _phase == LessonPhase.cueing) return;
    _setPhase(LessonPhase.cueing);
    await _haptics.playPattern(lesson.stressPattern);
    if (_phase == LessonPhase.cueing) _setPhase(LessonPhase.ready);
  }

  void startRecording() {
    if (_lesson == null) return;
    _bestFace = null;
    _bestMetrics = null;
    _bestScore = -1;
    _localComparison = null;
    _serverFeedback = null;
    _setPhase(LessonPhase.recording);
    _recordTimer = Timer(_recordingWindow, finishAttempt);
  }

  Future<void> finishAttempt() async {
    _recordTimer?.cancel();
    final lesson = _lesson;
    final best = _bestMetrics;
    if (lesson == null) return;
    if (best == null) {
      _fail('No mouth detected during the attempt. Try again, facing the camera.');
      return;
    }

    _localComparison = _comparator.compare(best, lesson.targetMetrics);
    _setPhase(LessonPhase.reviewing);

    try {
      _serverFeedback = await _repo.submitAttempt(
        targetViseme: lesson.viseme,
        metrics: best.toJson(),
      );
    } catch (e) {
      // Backend is for storage/progress; keep on-device cues if it fails.
      debugPrint('Attempt submit failed: $e');
    }
    _setPhase(LessonPhase.result);
  }

  void tryAgain() {
    _localComparison = null;
    _serverFeedback = null;
    _setPhase(LessonPhase.ready);
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

  @override
  void dispose() {
    _recordTimer?.cancel();
    _sub?.cancel();
    _tracker.dispose();
    super.dispose();
  }
}
