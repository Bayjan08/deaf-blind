import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Face-landmark data model produced by the on-device face tracker.
///
/// Mirrors [HandLandmarks] in `landmark_models.dart` but for MediaPipe Face
/// Mesh (468 keypoints) instead of Hands (21).
class FaceLandmarks {
  FaceLandmarks(this.points);

  /// Flattened (x, y, z) triplets per mesh keypoint (468 points => length 1404).
  final List<double> points;

  bool get isValid => points.length >= 468 * 3;

  Offset operator [](int index) =>
      Offset(points[index * 3], points[index * 3 + 1]);
}

/// Geometric mouth features, all normalized by interocular distance so they are
/// scale-invariant (independent of how close the face is to the camera).
///
/// These are the only mouth data ever sent to the backend — never the image.
class MouthMetrics {
  const MouthMetrics({
    required this.lipGap,
    required this.mouthWidth,
    required this.rounding,
    required this.jawOpen,
    required this.lipClosure,
  });

  final double lipGap; // vertical inner-lip opening
  final double mouthWidth; // corner-to-corner width
  final double rounding; // width / gap — high = spread, low = rounded
  final double jawOpen; // upper-lip-to-chin distance
  final double lipClosure; // 1 = lips pressed shut, 0 = wide open

  Map<String, double> toJson() => {
        'lipGap': lipGap,
        'mouthWidth': mouthWidth,
        'rounding': rounding,
        'jawOpen': jawOpen,
        'lipClosure': lipClosure,
      };
}

// MediaPipe Face Mesh canonical indices used for the mouth metrics.
const int _eyeOuterL = 33;
const int _eyeOuterR = 263;
const int _lipInnerTop = 13;
const int _lipInnerBottom = 14;
const int _mouthCornerL = 61;
const int _mouthCornerR = 291;
const int _chin = 152;

double _dist(Offset a, Offset b) {
  final dx = a.dx - b.dx;
  final dy = a.dy - b.dy;
  return math.sqrt(dx * dx + dy * dy);
}

/// Derives [MouthMetrics] from a face-mesh frame. Returns null when the frame
/// is incomplete or the eyes can't be located (so we can't normalize).
MouthMetrics? mouthMetricsFrom(FaceLandmarks f) {
  if (!f.isValid) return null;
  final interocular = _dist(f[_eyeOuterL], f[_eyeOuterR]);
  if (interocular <= 1e-3) return null;

  final lipGap = _dist(f[_lipInnerTop], f[_lipInnerBottom]) / interocular;
  final mouthWidth = _dist(f[_mouthCornerL], f[_mouthCornerR]) / interocular;
  final jawOpen = _dist(f[_lipInnerTop], f[_chin]) / interocular;
  final rounding = mouthWidth / math.max(lipGap, 0.02);
  final lipClosure = (1.0 - (lipGap / 0.12)).clamp(0.0, 1.0);

  return MouthMetrics(
    lipGap: lipGap,
    mouthWidth: mouthWidth,
    rounding: rounding,
    jawOpen: jawOpen,
    lipClosure: lipClosure,
  );
}
