import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_colors.dart';

/// Live front-camera preview box. Falls back to an explanatory placeholder when
/// face tracking isn't available (ML Kit Face Mesh is Android-only).
class CameraPreviewBox extends StatelessWidget {
  const CameraPreviewBox({
    super.key,
    required this.controller,
    required this.supported,
    this.overlayColor,
  });

  final CameraController? controller;
  final bool supported;
  final Color? overlayColor;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: DesignColors.darkBg,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (supported && c != null && c.value.isInitialized)
                CameraPreview(c)
              else
                _Placeholder(supported: supported),
              if (overlayColor != null)
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: overlayColor!, width: 4),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.supported});
  final bool supported;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          supported
              ? 'Starting camera…'
              : 'Mouth tracking needs an Android device.\nYou can still watch the target shape.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

/// Calibration step: capture a neutral (relaxed) face so attempts are scored
/// against the learner's own face geometry. Stored on-device only.
class CalibrationView extends StatelessWidget {
  const CalibrationView({
    super.key,
    required this.controller,
    required this.supported,
    required this.faceDetected,
    required this.onCalibrate,
  });

  final CameraController? controller;
  final bool supported;
  final bool faceDetected;
  final VoidCallback onCalibrate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick setup',
          style: AppTheme.baloo(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Relax your face and look at the camera, then tap Calibrate.',
          style: TextStyle(
            fontSize: 14,
            color: DesignColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        CameraPreviewBox(
          controller: controller,
          supported: supported,
          overlayColor: faceDetected ? DesignColors.green : DesignColors.orange,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: (faceDetected || !supported) ? onCalibrate : null,
          style: FilledButton.styleFrom(
            backgroundColor: DesignColors.purple,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            supported
                ? (faceDetected ? 'Calibrate' : 'Looking for your face…')
                : 'Continue',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
