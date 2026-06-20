import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../ai_translator/presentation/screens/ai_translator_screen.dart';
import '../models/music_note.dart';

class NoteOverlay extends StatelessWidget {
  const NoteOverlay({
    super.key,
    required this.note,
    required this.onDismiss,
  });

  final MusicNote note;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: note.color,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(3, (i) => _Ring(delay: i * 0.5)),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        note.name,
                        style: AppTheme.baloo(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: note.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Нота «${note.name}»',
                style: AppTheme.baloo(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Вибрация: ${note.desc}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Нажми, чтобы вернуться',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatefulWidget {
  const _Ring({required this.delay});

  final double delay;

  @override
  State<_Ring> createState() => _RingState();
}

class _RingState extends State<_Ring> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Transform.scale(
          scale: 0.4 + t * 1.1,
          child: Opacity(
            opacity: (1 - t) * 0.55,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TranslatorOverlay extends StatelessWidget {
  const TranslatorOverlay({
    super.key,
    required this.onClose,
    this.onGestureToText,
  });

  final VoidCallback onClose;
  final VoidCallback? onGestureToText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: const Color(0x73141228),
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E4EE),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [
                            DesignColors.fabGradientStart,
                            DesignColors.fabGradientEnd,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.translate_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ИИ-переводчик',
                            style: AppTheme.baloo(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Жесты ↔ речь ↔ текст',
                            style: TextStyle(
                              fontSize: 12,
                              color: DesignColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F2F8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF7A7F9A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _TranslatorOption(
                  bg: const Color(0xFFF6F4FF),
                  border: const Color(0xFFE7E2FF),
                  iconBg: DesignColors.purple,
                  icon: Icons.mic_rounded,
                  title: 'Голос → жесты',
                  subtitle: 'Говорите — аватар покажет жесты',
                  onTap: () {
                    onClose();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AiTranslatorScreen(initialMode: 0),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _TranslatorOption(
                  bg: const Color(0xFFFFF4EE),
                  border: const Color(0xFFFFE2D2),
                  iconBg: DesignColors.orange,
                  icon: Icons.videocam_rounded,
                  title: 'Жесты → текст',
                  subtitle: 'Камера распознаёт ваши жесты',
                  onTap: onGestureToText,
                ),
                const SizedBox(height: 10),
                _TranslatorOption(
                  bg: const Color(0xFFEEFBF4),
                  border: const Color(0xFFD2F2E0),
                  iconBg: DesignColors.green,
                  icon: Icons.text_fields_rounded,
                  title: 'Ввести текст',
                  subtitle: 'Напечатайте — переведём в жесты',
                  onTap: () {
                    onClose();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AiTranslatorScreen(initialMode: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TranslatorOption extends StatelessWidget {
  const _TranslatorOption({
    required this.bg,
    required this.border,
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final Color bg;
  final Color border;
  final Color iconBg;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: DesignColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
