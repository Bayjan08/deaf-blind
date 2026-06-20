/// Geometric mouth features, normalized by interocular distance (scale-invariant).
///
/// Computed on-device by MediaPipe Face Mesh running in the WebView
/// (`assets/html/mouth_tracker.html`) and delivered to Flutter as JSON. These
/// are the only mouth data ever sent to the backend — never the camera image.
class MouthMetrics {
  const MouthMetrics({
    required this.lipGap,
    required this.mouthWidth,
    required this.rounding,
    required this.jawOpen,
    required this.lipClosure,
  });

  final double lipGap;
  final double mouthWidth;
  final double rounding;
  final double jawOpen;
  final double lipClosure;

  Map<String, double> toJson() => {
        'lipGap': lipGap,
        'mouthWidth': mouthWidth,
        'rounding': rounding,
        'jawOpen': jawOpen,
        'lipClosure': lipClosure,
      };

  factory MouthMetrics.fromJson(Map<String, dynamic> json) {
    double f(String k) => (json[k] as num?)?.toDouble() ?? 0.0;
    return MouthMetrics(
      lipGap: f('lipGap'),
      mouthWidth: f('mouthWidth'),
      rounding: f('rounding'),
      jawOpen: f('jawOpen'),
      lipClosure: f('lipClosure'),
    );
  }
}
