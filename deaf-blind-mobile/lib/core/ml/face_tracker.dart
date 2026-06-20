import 'face_landmark_models.dart';

/// §4 On-device face-mesh tracking (MediaPipe Face Landmarker via ML Kit).
/// Emits landmark frames from the front-camera stream.
///
/// Mirrors the [HandTracker] abstraction in `hand_tracker.dart`. The concrete
/// implementation ([MlkitFaceTracker]) keeps all camera/ML-Kit code in one
/// place so the rest of the feature depends only on this interface.
abstract class FaceTracker {
  Stream<FaceLandmarks> get landmarks;
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
}
