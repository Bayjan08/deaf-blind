import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Russian gloss word -> bundled sign image in assets/images/signs/.
///
/// Mirrors deaf-blind-backend/app/services/translation_engine/sign_assets.py
/// — keep both lists in sync if the vocabulary changes.
const Map<String, String> signAssetByWord = {
  'привет': 'hello',
  'спасибо': 'thank_you',
  'пожалуйста': 'please',
  'стоп': 'stop',
  'да': 'yes',
  'нет': 'no',
  'ты': 'you',
  'я': 'me',
  'хотеть': 'want',
  'кушать': 'eat',
  'вода': 'water',
  'туалет': 'toilet',
  'помощь': 'help',
  'ещё': 'more',
  'нравится': 'like',
  'друзья': 'friends',
  'играть': 'play',
  'что': 'what',
  'когда': 'when',
  'где': 'where',
  'кто': 'who',
  'почему': 'why',
  'нельзя': 'dont',
  'готово': 'all_done',
  'голодный': 'hungry',
};

/// Plays a sentence's sign-gesture words one by one, each as its real PNG
/// from assets/images/signs/, so a whole spoken sentence becomes a readable
/// gesture-by-gesture flow rather than an abstract id.
class SignGestureFlowPlayer extends StatefulWidget {
  const SignGestureFlowPlayer({super.key, required this.words});

  final List<String> words;

  @override
  State<SignGestureFlowPlayer> createState() => _SignGestureFlowPlayerState();
}

class _SignGestureFlowPlayerState extends State<SignGestureFlowPlayer> {
  int _currentIndex = -1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.words.isNotEmpty) _startPlaying();
  }

  @override
  void didUpdateWidget(SignGestureFlowPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.words != oldWidget.words) {
      _timer?.cancel();
      _currentIndex = -1;
      if (widget.words.isNotEmpty) {
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

  // Haptic cue every time the flow starts — deaf-blind users can feel that a
  // sentence is about to be shown even if they can't see or hear it.
  Future<void> _vibrateStart() async {
    if (await Vibration.hasVibrator() != true) return;
    await Vibration.vibrate(duration: 200);
  }

  void _startPlaying() {
    _vibrateStart();
    setState(() => _currentIndex = 0);
    _timer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (!mounted) return;
      if (_currentIndex < widget.words.length - 1) {
        setState(() => _currentIndex++);
      } else {
        setState(() => _currentIndex = -1);
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeWord = _currentIndex >= 0 && _currentIndex < widget.words.length
        ? widget.words[_currentIndex]
        : null;
    final asset = activeWord != null ? signAssetByWord[activeWord] : null;

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
          if (widget.words.isNotEmpty) ...[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: List.generate(widget.words.length, (i) {
                final isActive = i == _currentIndex;
                final isDone = _currentIndex == -1 || i < _currentIndex;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.grey100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.words[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? Colors.white
                          : (isDone ? AppColors.textPrimary : AppColors.textSecondary),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
          ],
          SizedBox(
            width: 150,
            height: 150,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: asset != null
                  ? Padding(
                      key: ValueKey(asset),
                      padding: const EdgeInsets.all(20),
                      child: Image.asset('assets/images/signs/$asset.png', fit: BoxFit.contain),
                    )
                  : const SizedBox(key: ValueKey('empty')),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: activeWord != null
                ? Container(
                    key: ValueKey(activeWord),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      activeWord.toUpperCase(),
                      style: AppTextStyles.style(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  )
                : Text(
                    widget.words.isEmpty ? 'Жду речь для показа жестов' : 'Показ завершён',
                    key: ValueKey(widget.words.isEmpty ? 'empty' : 'done'),
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
          ),
          if (widget.words.isNotEmpty && activeWord == null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _startPlaying,
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: const Text('Повторить жесты'),
            ),
          ],
        ],
      ),
    );
  }
}
