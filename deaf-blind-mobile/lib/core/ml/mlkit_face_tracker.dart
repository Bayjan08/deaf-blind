import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';

import 'face_landmark_models.dart';
import 'face_tracker.dart';

/// Front-camera Face Mesh tracker backed by Google ML Kit (pure Dart — no
/// platform-channel native code). This is the in-Dart analogue of the
/// never-built hand-tracker native side.
///
/// NOTE: ML Kit Face Mesh is **Android-only**; on other platforms [start]
/// no-ops and the stream simply stays empty (the feature degrades to the
/// reference-only view).
class MlkitFaceTracker implements FaceTracker {
  MlkitFaceTracker();

  final _controller = StreamController<FaceLandmarks>.broadcast();
  final _detector = FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);

  CameraController? _camera;
  bool _busy = false;
  bool _running = false;

  /// Exposed so the UI can render the live preview.
  CameraController? get cameraController => _camera;

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  @override
  Stream<FaceLandmarks> get landmarks => _controller.stream;

  @override
  Future<void> start() async {
    if (_running || !isSupported) return;
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    final camera = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    await camera.initialize();
    _camera = camera;
    _running = true;
    await camera.startImageStream(_onFrame);
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_busy || !_running) return;
    _busy = true;
    try {
      final input = _toInputImage(image);
      if (input != null) {
        final meshes = await _detector.processImage(input);
        if (meshes.isNotEmpty) {
          _controller.add(_flatten(meshes.first));
        }
      }
    } catch (e) {
      debugPrint('FaceMesh frame error: $e');
    } finally {
      _busy = false;
    }
  }

  FaceLandmarks _flatten(FaceMesh mesh) {
    final flat = <double>[];
    for (final p in mesh.points) {
      flat
        ..add(p.x.toDouble())
        ..add(p.y.toDouble())
        ..add(p.z.toDouble());
    }
    return FaceLandmarks(flat);
  }

  InputImage? _toInputImage(CameraImage image) {
    final camera = _camera;
    if (camera == null) return null;

    final rotation = InputImageRotationValue.fromRawValue(
      camera.description.sensorOrientation,
    );
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rotation == null || format == null || image.planes.isEmpty) return null;

    return InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  @override
  Future<void> stop() async {
    _running = false;
    final camera = _camera;
    if (camera != null && camera.value.isStreamingImages) {
      await camera.stopImageStream();
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _camera?.dispose();
    _camera = null;
    await _detector.close();
    await _controller.close();
  }
}
