/// Hand-landmark data model produced by the on-device tracker.
class HandLandmarks {
  HandLandmarks(this.points);

  /// Flattened (x,y,z) triplets per hand keypoint (MediaPipe Hands = 21 points).
  final List<double> points;
}
