import 'landmark_models.dart';

/// §1/§2/§7 On-device hand tracking (MediaPipe Hands via platform channel).
/// Emits landmark frames from the camera stream.
abstract class HandTracker {
  Stream<HandLandmarks> get landmarks;
  Future<void> start();
  Future<void> stop();
}
