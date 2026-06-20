import 'landmark_models.dart';

/// §1/§2/§7 KEYSTONE: classifies landmark frames into fixed-vocabulary labels
/// (TFLite, on-device). Sends only the label to the backend -> low latency.
abstract class GestureClassifier {
  /// Returns (label, confidence) for a landmark frame. Stub.
  Future<({String label, double confidence})> classify(HandLandmarks frame);
}
