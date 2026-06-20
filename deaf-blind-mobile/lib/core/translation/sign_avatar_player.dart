import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/design_colors.dart';
import '../theme/app_theme.dart';

class SignAvatarPlayer extends StatefulWidget {
  const SignAvatarPlayer({super.key, required this.animationIds});

  final List<int> animationIds;

  @override
  State<SignAvatarPlayer> createState() => _SignAvatarPlayerState();
}

class _SignAvatarPlayerState extends State<SignAvatarPlayer> {
  int _currentIndex = -1;
  Timer? _timer;

  static const Map<int, String> _vocab = {
    1: "привет",
    2: "я",
    3: "хотеть",
    4: "кушать",
    5: "спасибо",
    6: "пожалуйста",
    7: "ты",
    8: "школа",
    9: "видео",
    10: "урок",
  };

  @override
  void initState() {
    super.initState();
    if (widget.animationIds.isNotEmpty) {
      _startPlaying();
    }
  }

  @override
  void didUpdateWidget(SignAvatarPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationIds != oldWidget.animationIds) {
      _timer?.cancel();
      _currentIndex = -1;
      if (widget.animationIds.isNotEmpty) {
        _startPlaying();
      } else {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPlaying() {
    setState(() {
      _currentIndex = 0;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) return;
      if (_currentIndex < widget.animationIds.length - 1) {
        setState(() {
          _currentIndex++;
        });
      } else {
        setState(() {
          _currentIndex = -1; // Finished
        });
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeId = _currentIndex >= 0 && _currentIndex < widget.animationIds.length
        ? widget.animationIds[_currentIndex]
        : null;
    final activeWord = activeId != null ? (_vocab[activeId] ?? "...") : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar Image with pulsing background when active
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeWord != null
                      ? DesignColors.purpleSoft
                      : DesignColors.bg,
                  border: Border.all(
                    color: activeWord != null
                        ? DesignColors.purple.withValues(alpha: 0.2)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/avatar.png',
                width: 110,
                height: 110,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Active Gesture Label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: activeWord != null
                ? Container(
                    key: ValueKey(activeWord),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          DesignColors.purple,
                          DesignColors.purpleLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: DesignColors.purple.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      activeWord.toUpperCase(),
                      style: AppTheme.baloo(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : Text(
                    widget.animationIds.isEmpty
                        ? "Жду текст для показа жестов"
                        : "Показ завершен",
                    key: ValueKey(widget.animationIds.isEmpty ? "empty" : "done"),
                    style: TextStyle(
                      fontSize: 14,
                      color: DesignColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          if (widget.animationIds.isNotEmpty && activeWord == null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _startPlaying,
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: const Text("Повторить жесты"),
            ),
          ],
        ],
      ),
    );
  }
}
