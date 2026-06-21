import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class LetterPracticeScreen extends StatefulWidget {
  const LetterPracticeScreen({
    super.key,
    required this.letter,
    required this.petAsset,
  });

  final String letter;
  final String petAsset;

  @override
  State<LetterPracticeScreen> createState() => _LetterPracticeScreenState();
}

class _LetterPracticeScreenState extends State<LetterPracticeScreen> {
  bool _cameraGranted = false;
  bool _cameraDenied = false;
  bool _success = false;
  bool _reward = false;

  Timer? _recognizeTimer;
  Timer? _successTimer;
  Timer? _rewardTimer;
  Timer? _popTimer;

  @override
  void initState() {
    super.initState();
    _requestCamera();
    // Simulate detection after ~3.8 s, then 3 s delay before showing checkmark
    _recognizeTimer = Timer(const Duration(milliseconds: 3800), () {
      if (!mounted || _success) return;
      // 3-second pause before the checkmark appears
      _successTimer = Timer(const Duration(seconds: 3), _onRecognized);
    });
  }

  Future<void> _requestCamera() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() {
      _cameraGranted = status.isGranted;
      _cameraDenied = !status.isGranted;
    });
  }

  void _onRecognized() {
    if (!mounted || _success) return;
    setState(() => _success = true);
    // Strawberry appears 3 s after checkmark
    _rewardTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _reward = true);
    });
    // Auto-pop 5.6 s after checkmark
    _popTimer = Timer(const Duration(milliseconds: 5600), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _recognizeTimer?.cancel();
    _successTimer?.cancel();
    _rewardTimer?.cancel();
    _popTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFF1A2630),
      body: Stack(children: [
        // Full-screen WebView: blue skeleton hand tracker
        Positioned.fill(child: _buildWebView()),

        // Back button
        Positioned(
          top: topPad + 16,
          left: 18,
          child: _GlassButton(
            icon: Icons.chevron_left,
            onTap: () => Navigator.maybePop(context),
          ),
        ),

        // Letter badge — top right
        Positioned(
          top: topPad + 16,
          right: 18,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.letter,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Pet in bottom-left + strawberry reward
        Positioned(
          left: 14,
          bottom: 20,
          child: SizedBox(
            width: 118,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  widget.petAsset,
                  errorBuilder: (_, _, _) =>
                      const SizedBox(width: 118, height: 118),
                ),
                if (_reward)
                  Positioned(
                    top: 30,
                    right: 4,
                    child: Image.asset(
                      'assets/strawberry.png',
                      width: 54,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Spinner — bottom center (only before success)
        if (!_success)
          Positioned(
            bottom: 34,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1921).withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF7FDCFF),
                ),
              ),
            ),
          ),

        // Success overlay — green circle with checkmark only
        if (_success)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF22B45F).withValues(alpha: 0.18),
              child: Center(
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF3DD27A), Color(0xFF22B45F)],
                    ),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 66,
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _buildWebView() {
    if (_cameraDenied || !_cameraGranted) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7FDCFF)),
      );
    }
    return InAppWebView(
      initialFile: 'assets/html/hand_tracker.html',
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        useHybridComposition: true,
      ),
      onWebViewCreated: (_) {},
      onPermissionRequest: (_, request) async => PermissionResponse(
        resources: request.resources,
        action: PermissionResponseAction.GRANT,
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
