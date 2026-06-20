import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_colors.dart';
import '../models/music_note.dart';
import '../widgets/design_widgets.dart';

// ─── MUSIC NOTES ─────────────────────────────────────────────────────────────

class MusicNotesScreen extends StatelessWidget {
  const MusicNotesScreen({
    super.key,
    required this.onBack,
    required this.onNoteTap,
    required this.onGame,
  });

  final VoidCallback onBack;
  final ValueChanged<MusicNote> onNoteTap;
  final VoidCallback onGame;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DesignBackButton(onTap: onBack),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Музыка через вибрацию',
                  style: AppTheme.baloo(fontSize: 22, fontWeight: FontWeight.w700, height: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Каждая нота — это свой цвет и своя вибрация. Нажми на ноту, чтобы почувствовать её.',
            style: TextStyle(
              fontSize: 14,
              color: DesignColors.textMuted,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: musicNotes.length,
            itemBuilder: (_, i) {
              final note = musicNotes[i];
              return GestureDetector(
                onTap: () => onNoteTap(note),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: note.bg,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: note.color.withValues(alpha: 0.4),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: note.color,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              note.name,
                              style: AppTheme.baloo(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              note.desc,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
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
            },
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: onGame,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                color: DesignColors.textDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Игра: угадай ноту',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MusicNoteDetailScreen extends StatelessWidget {
  const MusicNoteDetailScreen({
    super.key,
    required this.note,
    required this.onBack,
    required this.onNext,
  });

  final MusicNote note;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final next = nextNoteAfter(note.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      color: note.color,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DesignBackButton(onTap: onBack, light: true),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Нота «${note.name}»',
                  style: AppTheme.baloo(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Center(child: _MusicNoteVibrationView(note: note)),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'Вибрация: ${note.desc}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onNext,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: DesignColors.textDark.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.skip_next_rounded, color: note.color, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Следующая нота: ${next.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: note.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicNoteVibrationView extends StatelessWidget {
  const _MusicNoteVibrationView({required this.note});

  final MusicNote note;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _NotePulseRing(delay: 0),
          _NotePulseRing(delay: 0.5),
          _NotePulseRing(delay: 1.0),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DesignColors.textDark.withValues(alpha: 0.25),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              note.name,
              style: AppTheme.baloo(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: note.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotePulseRing extends StatefulWidget {
  const _NotePulseRing({required this.delay});

  final double delay;

  @override
  State<_NotePulseRing> createState() => _NotePulseRingState();
}

class _NotePulseRingState extends State<_NotePulseRing>
    with SingleTickerProviderStateMixin {
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
      builder: (_, _) {
        final t = _controller.value;
        return Transform.scale(
          scale: 0.4 + t * 1.1,
          child: Opacity(
            opacity: (1 - t) * 0.55,
            child: Container(
              width: 220,
              height: 220,
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

// ─── MUSIC GAME ──────────────────────────────────────────────────────────────

class MusicGameScreen extends StatelessWidget {
  const MusicGameScreen({
    super.key,
    required this.onBack,
    required this.questionIndex,
    required this.question,
    required this.gamePick,
    required this.onPick,
    required this.onNext,
  });

  final VoidCallback onBack;
  final int questionIndex;
  final MusicQuizQuestion question;
  final String? gamePick;
  final ValueChanged<String> onPick;
  final VoidCallback onNext;

  bool get answered => gamePick != null;
  bool get isCorrect => gamePick == question.correctId;
  bool get isLastQuestion => questionIndex >= musicQuizQuestions.length - 1;

  @override
  Widget build(BuildContext context) {
    final correctNote = noteById(question.correctId)!;
    final bg = !answered
        ? DesignColors.bg
        : isCorrect
            ? const Color(0xFFEAF8F1)
            : const Color(0xFFFFF0EE);
    final ring = !answered
        ? correctNote.color.withValues(alpha: 0.45)
        : isCorrect
            ? const Color(0x803DD68C)
            : const Color(0x80FF7A66);
    final center = !answered ? correctNote.color : isCorrect ? const Color(0xFF3DD68C) : const Color(0xFFFF7A66);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DesignBackButton(onTap: onBack),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Угадай ноту',
                    style: AppTheme.baloo(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${questionIndex + 1}/${musicQuizQuestions.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: DesignColors.purple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const Center(
              child: Text(
                'Почувствуй вибрацию',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6E7390),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(child: _VibrationCircle(ring: ring, center: center)),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'Какая это нота?',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6E7390),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              itemCount: question.optionIds.length,
              itemBuilder: (_, i) {
                final id = question.optionIds[i];
                final n = noteById(id)!;
                final picked = gamePick == id;
                final isCorrectOption = id == question.correctId;

                Color border;
                if (!answered) {
                  border = const Color(0xFFF1F2F8);
                } else if (isCorrectOption) {
                  border = DesignColors.green;
                } else if (picked) {
                  border = const Color(0xFFFF7A66);
                } else {
                  border = const Color(0xFFF1F2F8);
                }

                return GestureDetector(
                  onTap: answered ? null : () => onPick(id),
                  child: Opacity(
                    opacity: answered && !picked && !isCorrectOption ? 0.55 : 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: DesignColors.textDark.withValues(alpha: 0.12),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: n.color,
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              n.name,
                              style: AppTheme.baloo(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                          ),
                          if (answered && isCorrectOption)
                            const Icon(Icons.check_rounded, color: DesignColors.green, size: 22),
                          if (answered && picked && !isCorrectOption)
                            const Icon(Icons.close_rounded, color: Color(0xFFFF7A66), size: 22),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (answered) ...[
              const SizedBox(height: 18),
              Center(
                child: Text(
                  isCorrect
                      ? 'Верно — это «${correctNote.name}»!'
                      : 'Неверно. Правильный ответ — «${correctNote.name}».',
                  textAlign: TextAlign.center,
                  style: AppTheme.baloo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isCorrect ? DesignColors.green : const Color(0xFFFF7A66),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: onNext,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  decoration: BoxDecoration(
                    color: isLastQuestion ? DesignColors.textDark : DesignColors.purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isLastQuestion ? Icons.flag_rounded : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isLastQuestion ? 'Завершить' : 'Следующий вопрос',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VibrationCircle extends StatelessWidget {
  const _VibrationCircle({required this.ring, required this.center});

  final Color ring;
  final Color center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _AnimatedRing(color: ring, delay: 0),
          _AnimatedRing(color: ring, delay: 0.6),
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              color: center,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DesignColors.textDark.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }
}

class _AnimatedRing extends StatefulWidget {
  const _AnimatedRing({required this.color, required this.delay});

  final Color color;
  final double delay;

  @override
  State<_AnimatedRing> createState() => _AnimatedRingState();
}

class _AnimatedRingState extends State<_AnimatedRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _c.repeat();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        return Transform.scale(
          scale: 0.4 + t * 1.1,
          child: Opacity(
            opacity: (1 - t) * 0.55,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: widget.color, width: 4),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── PRONUNCIATION ───────────────────────────────────────────────────────────

class PronunciationScreen extends StatelessWidget {
  const PronunciationScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DesignBackButton(onTap: onBack),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Произношение',
                  style: AppTheme.baloo(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4EE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Необязательный курс. Он не влияет на твой прогресс — занимайся, если хочешь.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFC77A4C),
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Column(
              children: [
                Text(
                  'Аа',
                  style: AppTheme.baloo(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: DesignColors.orange,
                    height: 1,
                  ),
                ),
                Text(
                  'Звук «А»',
                  style: TextStyle(
                    fontSize: 14,
                    color: DesignColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesignColors.darkBg,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Container(
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFF221F3D),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '[ анимация: губы и язык ]',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  Text(
                    'Крупный план артикуляции',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: DesignColors.textDark.withValues(alpha: 0.12),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Сравнение с образцом',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: DesignColors.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Bar(0.4, true),
                      _Bar(0.7, true),
                      _Bar(0.9, true),
                      _Bar(0.6, true),
                      _Bar(0.5, false),
                      _Bar(0.8, false),
                      _Bar(0.65, true),
                      _Bar(0.45, true),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Совет ИИ: открой губы чуть шире — звук станет ярче и чётче.',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF7A7F9A),
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
              color: DesignColors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Записать попытку',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(this.factor, this.sample);

  final double factor;
  final bool sample;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: FractionallySizedBox(
          heightFactor: factor,
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: sample ? DesignColors.green : const Color(0xFFE6E8F1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── LIVE CLASS ────────────────────────────────────────────────────────────────

class LiveClassScreen extends StatelessWidget {
  const LiveClassScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.5),
              radius: 1.2,
              colors: [Color(0xFF2E2B4D), DesignColors.liveBg],
            ),
          ),
        ),
        Center(
          child: Text(
            '[ видео: учитель ]',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
        Positioned(
          top: 56,
          left: 20,
          right: 20,
          child: Row(
            children: [
              DesignBackButton(onTap: onBack, light: true),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Урок · Математика',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Анна Петровна',
                      style: TextStyle(
                        color: Color(0x99FFFFFF),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: DesignColors.redLive.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    _LiveDot(),
                    SizedBox(width: 6),
                    Text(
                      'В эфире',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 116,
          right: 20,
          child: Container(
            width: 130,
            height: 170,
            decoration: BoxDecoration(
              color: DesignColors.purple.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6FF0B0),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Сурдо-аватар',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '3D-аватар\nпоказывает\nжесты',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 220,
          left: 20,
          child: Container(
            width: 76,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1830),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              'вы',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 116,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'СУБТИТРЫ · речь учителя',
                  style: TextStyle(
                    fontSize: 11,
                    color: DesignColors.purpleLight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '«Сегодня мы научимся складывать числа до десяти…»',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                size: 52,
                color: Colors.white.withValues(alpha: 0.18),
                icon: Icons.videocam_rounded,
              ),
              const SizedBox(width: 16),
              _ControlButton(
                size: 64,
                color: DesignColors.redLive,
                icon: Icons.call_end_rounded,
                iconColor: Colors.white,
              ),
              const SizedBox(width: 16),
              _ControlButton(
                size: 52,
                color: DesignColors.purple.withValues(alpha: 0.9),
                icon: Icons.mic_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5 + 0.5 * math.sin(t * 2 * math.pi)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.size,
    required this.color,
    required this.icon,
    this.iconColor = Colors.white,
  });

  final double size;
  final Color color;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: color == DesignColors.redLive
            ? [
                BoxShadow(
                  color: DesignColors.redLive.withValues(alpha: 0.7),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Icon(icon, color: iconColor, size: size * 0.4),
    );
  }
}

// ─── PROFILE ─────────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.onAlphabetMap,
  });

  final VoidCallback onAlphabetMap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 130),
      child: Column(
        children: [
          const AvatarImage(size: 96, borderWidth: 4),
          const SizedBox(height: 12),
          Text(
            'Артём, 11 лет',
            style: AppTheme.baloo(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: DesignColors.purpleSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Уровень 3 · Исследователь',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: DesignColors.purple,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _ProfileStat('12', 'дней подряд', DesignColors.orange)),
              const SizedBox(width: 10),
              Expanded(child: _ProfileStat('47', 'жестов', DesignColors.purple)),
              const SizedBox(width: 10),
              Expanded(child: _ProfileStat('8', 'наград', DesignColors.green)),
            ],
          ),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Аналитика от ИИ',
              style: AppTheme.baloo(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: DesignColors.textDark.withValues(alpha: 0.12),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: DesignColors.purple,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Над чем поработать',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: DesignColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _WeakLetter('Буква Д', 0.45, const Color(0xFFFF7A66), const Color(0xFFFFE6E1)),
                const SizedBox(height: 10),
                _WeakLetter('Буква П', 0.62, const Color(0xFFFFB23E), const Color(0xFFFFF2DF)),
                const SizedBox(height: 10),
                _WeakLetter('Буква М', 0.92, DesignColors.green, const Color(0xFFE2F6EC)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onAlphabetMap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: DesignColors.purpleSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Повторить слабые буквы',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: DesignColors.purple,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: DesignColors.textDark.withValues(alpha: 0.12),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                _SettingsRow(
                  iconBg: DesignColors.purpleSoft,
                  icon: Icons.pets_rounded,
                  iconColor: DesignColors.purple,
                  label: 'Питомец и награды',
                ),
                Divider(height: 1, color: const Color(0xFFF1F2F8), indent: 14, endIndent: 14),
                _SettingsRow(
                  iconBg: DesignColors.orangeSoft,
                  icon: Icons.star_outline_rounded,
                  iconColor: DesignColors.orange,
                  label: 'Доступность и вибрация',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DesignColors.textDark.withValues(alpha: 0.1),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.baloo(fontSize: 22, fontWeight: FontWeight.w800, color: color),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: DesignColors.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeakLetter extends StatelessWidget {
  const _WeakLetter(this.label, this.progress, this.color, this.bg);

  final String label;
  final double progress;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: DesignColors.textDark,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: bg,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress * 100).round()}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: DesignColors.textDark,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: DesignColors.textDim, size: 20),
        ],
      ),
    );
  }
}
