import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_colors.dart';
import '../models/math_content.dart';
import '../widgets/design_widgets.dart';

// ─── MAP ─────────────────────────────────────────────────────────────────────

class MathMapScreen extends StatelessWidget {
  const MathMapScreen({
    super.key,
    required this.onBack,
    required this.onNodeTap,
    required this.completedIds,
    required this.unlockedIds,
    required this.currentId,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onNodeTap;
  final Set<String> completedIds;
  final Set<String> unlockedIds;
  final String currentId;

  @override
  Widget build(BuildContext context) {
    final catalog = buildMathCatalog();
    final completed = completedIds.length;
    final total = catalog.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [MathColors.map, DesignColors.bg],
          stops: [0, 0.35],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 14),
              child: Row(
                children: [
                  DesignBackButton(onTap: onBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Математика',
                      style: AppTheme.baloo(fontSize: 20, fontWeight: FontWeight.w700, height: 1),
                    ),
                  ),
                  const StreakBadge(compact: true),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: DesignColors.textDark.withValues(alpha: 0.12),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const _FloatingBeaver(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Бобр строит башни из чисел',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: DesignColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 7),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 9,
                              backgroundColor: DesignColors.progressBg,
                              color: MathColors.primary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$completed из $total тем пройдено',
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
            ),
            const SizedBox(height: 20),
            for (final level in mathLevels) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Уровень ${level.level} · ${level.title}',
                      style: AppTheme.baloo(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: MathColors.primary,
                      ),
                    ),
                    Text(
                      level.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final node in catalog.where((n) => n.level == level.level))
                      _MathNodeChip(
                        node: node,
                        isCompleted: completedIds.contains(node.id),
                        isUnlocked: unlockedIds.contains(node.id),
                        isCurrent: node.id == currentId,
                        onTap: unlockedIds.contains(node.id)
                            ? () => onNodeTap(node.id)
                            : null,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _MathNodeChip extends StatelessWidget {
  const _MathNodeChip({
    required this.node,
    required this.isCompleted,
    required this.isUnlocked,
    required this.isCurrent,
    this.onTap,
  });

  final MathNode node;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = !isUnlocked
        ? const Color(0xFFE7E9F1)
        : isCurrent
            ? MathColors.primary
            : isCompleted
                ? MathColors.tealSoft
                : Colors.white;

    final border = isCurrent
        ? Border.all(color: MathColors.primaryLight, width: 2.5)
        : isCompleted
            ? Border.all(color: MathColors.teal, width: 1.5)
            : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.sizeOf(context).width - 52) / 2,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: border,
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: DesignColors.textDark.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(node.emoji, style: const TextStyle(fontSize: 22)),
                const Spacer(),
                if (!isUnlocked)
                  Icon(Icons.lock_outline_rounded, size: 16, color: DesignColors.textDim)
                else if (isCompleted)
                  Icon(Icons.check_circle_rounded, size: 18, color: MathColors.teal)
                else if (isCurrent)
                  const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              node.title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: isCurrent ? Colors.white : DesignColors.textDark,
              ),
            ),
            Text(
              node.subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isCurrent ? Colors.white.withValues(alpha: 0.85) : DesignColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBeaver extends StatefulWidget {
  const _FloatingBeaver();

  @override
  State<_FloatingBeaver> createState() => _FloatingBeaverState();
}

class _FloatingBeaverState extends State<_FloatingBeaver> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
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
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -5 * math.sin(_c.value * math.pi)),
        child: child,
      ),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: MathColors.soft,
        ),
        alignment: Alignment.center,
        child: const Text('🦫', style: TextStyle(fontSize: 28)),
      ),
    );
  }
}

// ─── INTRO ───────────────────────────────────────────────────────────────────

class MathIntroScreen extends StatefulWidget {
  const MathIntroScreen({
    super.key,
    required this.node,
    required this.onBack,
    required this.onPractice,
  });

  final MathNode node;
  final VoidCallback onBack;
  final VoidCallback onPractice;

  @override
  State<MathIntroScreen> createState() => _MathIntroScreenState();
}

class _MathIntroScreenState extends State<MathIntroScreen> {
  int _stepIndex = 0;

  MathLessonStep get _step => widget.node.lessonSteps[_stepIndex];
  bool get _isLastStep => _stepIndex >= widget.node.lessonSteps.length - 1;

  @override
  Widget build(BuildContext context) {
    final steps = widget.node.lessonSteps;
    final total = steps.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 130),
      child: Column(
        children: [
          Row(
            children: [
              DesignBackButton(onTap: widget.onBack),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_stepIndex + 1) / total,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE6E8F1),
                    color: MathColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_stepIndex + 1}/$total',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: MathColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Изучаем',
            style: TextStyle(
              fontSize: 13,
              color: DesignColors.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            widget.node.title,
            style: AppTheme.baloo(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Text(
            _step.headline,
            style: AppTheme.baloo(
              fontSize: 88,
              fontWeight: FontWeight.w800,
              color: MathColors.primary,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
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
                MathCountVisual(
                  itemEmoji: _step.itemEmoji,
                  count: _step.itemCount,
                  showBasket: _step.showBasket,
                  minHeight: 160,
                ),
                const SizedBox(height: 14),
                Text(
                  _step.caption,
                  textAlign: TextAlign.center,
                  style: AppTheme.baloo(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: MathColors.primary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (total > 1) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                return Container(
                  width: i == _stepIndex ? 22 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _stepIndex ? MathColors.primary : const Color(0xFFE6E8F1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: MathColors.map,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: const Text('💡', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Подсказка',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: DesignColors.textDark,
                        ),
                      ),
                      Text(
                        widget.node.tipHint,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF7A7F9A),
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: _isLastStep ? 'К тесту →' : 'Дальше →',
            onTap: _isLastStep
                ? widget.onPractice
                : () => setState(() => _stepIndex++),
            color: MathColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Basket + items visual used in lesson and practice.
class MathCountVisual extends StatelessWidget {
  const MathCountVisual({
    super.key,
    this.itemEmoji,
    this.count = 0,
    this.showBasket = false,
    this.minHeight = 120,
  });

  final String? itemEmoji;
  final int count;
  final bool showBasket;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final item = itemEmoji ?? '🍎';

    if (showBasket) {
      return SizedBox(
        height: minHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (count > 0)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: List.generate(
                  count,
                  (_) => Text(item, style: const TextStyle(fontSize: 32)),
                ),
              )
            else
              Text(
                'пусто',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DesignColors.textMuted,
                ),
              ),
            const SizedBox(height: 10),
            const Text('🧺', style: TextStyle(fontSize: 44)),
          ],
        ),
      );
    }

    if (count > 0) {
      return SizedBox(
        height: minHeight,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            count,
            (_) => Text(item, style: TextStyle(fontSize: count > 8 ? 26 : 34)),
          ),
        ),
      );
    }

    return SizedBox(
      height: minHeight,
      child: Center(
        child: Text(itemEmoji ?? '🔢', style: const TextStyle(fontSize: 48)),
      ),
    );
  }
}

// ─── PRACTICE ────────────────────────────────────────────────────────────────

enum _MathFeedback { none, wrong, checking, correct }

class MathPracticeScreen extends StatefulWidget {
  const MathPracticeScreen({
    super.key,
    required this.node,
    required this.onBack,
    required this.onComplete,
  });

  final MathNode node;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  State<MathPracticeScreen> createState() => _MathPracticeScreenState();
}

class _MathPracticeScreenState extends State<MathPracticeScreen> {
  int _taskIndex = 0;
  _MathFeedback _feedback = _MathFeedback.none;
  int _wrongAttempts = 0;

  MathTask get _task => widget.node.tasks[_taskIndex];

  void _submit(dynamic answer) {
    if (_feedback == _MathFeedback.checking) return;
    setState(() {
      _feedback = _MathFeedback.checking;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_task.check(answer)) {
        setState(() => _feedback = _MathFeedback.correct);
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          if (_taskIndex < widget.node.tasks.length - 1) {
            setState(() {
              _taskIndex++;
              _feedback = _MathFeedback.none;
              _wrongAttempts = 0;
            });
          } else {
            widget.onComplete();
          }
        });
      } else {
        setState(() {
          _feedback = _MathFeedback.wrong;
          _wrongAttempts++;
        });
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (mounted) setState(() => _feedback = _MathFeedback.none);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.node.tasks.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DesignBackButton(onTap: widget.onBack),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (_taskIndex + 1) / total,
                    minHeight: 10,
                    backgroundColor: DesignColors.progressBg,
                    color: MathColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_taskIndex + 1}/$total',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: MathColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _task.prompt,
            style: AppTheme.baloo(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _TaskVisual(task: _task, feedback: _feedback),
          const SizedBox(height: 18),
          _TaskInput(
            key: ValueKey('${_task.type}_$_taskIndex'),
            task: _task,
            feedback: _feedback,
            showHint: _wrongAttempts >= 2,
            onSubmit: _submit,
          ),
          if (_feedback == _MathFeedback.wrong) ...[
            const SizedBox(height: 12),
            Text(
              _wrongAttempts >= 2 ? 'Правильный ответ подсвечен' : 'Попробуй ещё',
              style: TextStyle(
                color: MathColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
          if (_feedback == _MathFeedback.checking) ...[
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Проверяем…',
                style: TextStyle(fontWeight: FontWeight.w800, color: DesignColors.textMuted),
              ),
            ),
          ],
          if (_feedback == _MathFeedback.correct) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignColors.greenSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: DesignColors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Верно!',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: DesignColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── TASK VISUAL ─────────────────────────────────────────────────────────────

class _TaskVisual extends StatelessWidget {
  const _TaskVisual({required this.task, required this.feedback});

  final MathTask task;
  final _MathFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final shake = feedback == _MathFeedback.wrong;
    Widget child;

    child = switch (task.type) {
      MathTaskType.pickLargerGroup => _GroupsVisual(task: task),
      MathTaskType.dragSign => _SignVisual(task: task),
      MathTaskType.pickShape => _ShapesVisual(highlight: task.shape),
      MathTaskType.pickPattern => _PatternVisual(pattern: task.pattern ?? []),
      MathTaskType.buildEquation => _EquationVisual(parts: task.equationParts ?? []),
      MathTaskType.dragOrder => _OrderVisual(items: task.orderItems ?? []),
      MathTaskType.yesNo => _MoneyVisual(),
      _ => _EmojiVisual(task: task),
    };

    if (shake) {
      child = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        builder: (_, v, c) => Transform.translate(
          offset: Offset(math.sin(v * math.pi * 6) * 8, 0),
          child: c,
        ),
        child: child,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: DesignColors.textDark.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EmojiVisual extends StatelessWidget {
  const _EmojiVisual({required this.task});
  final MathTask task;

  @override
  Widget build(BuildContext context) {
    if (task.itemEmoji != null || task.useBasket) {
      return MathCountVisual(
        itemEmoji: task.itemEmoji,
        count: task.count ?? task.digit ?? 0,
        showBasket: task.useBasket,
        minHeight: 140,
      );
    }

    final emoji = task.emoji ?? '🔢';
    final count = task.count;
    final display = count != null && count > 0 ? mathRepeatItems(emoji, count) : emoji;
    return Column(
      children: [
        Text(
          display,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: count != null && count <= 6 ? 36 : 28, height: 1.4),
        ),
      ],
    );
  }
}

class _GroupsVisual extends StatelessWidget {
  const _GroupsVisual({required this.task});
  final MathTask task;

  @override
  Widget build(BuildContext context) {
    final item = task.itemEmoji ?? task.emoji ?? '🍎';
    if (task.itemEmoji != null || (task.emoji != null && task.emoji!.length <= 4)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _GroupBox(item: item, count: task.left ?? 0),
          _GroupBox(item: item, count: task.right ?? 0),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _NumberBox(n: task.left ?? 0),
        _NumberBox(n: task.right ?? 0),
      ],
    );
  }
}

class _GroupBox extends StatelessWidget {
  const _GroupBox({required this.item, required this.count});
  final String item;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: List.generate(
            count,
            (_) => Text(item, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(height: 6),
        Text('$count', style: AppTheme.baloo(fontSize: 28, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _NumberBox extends StatelessWidget {
  const _NumberBox({required this.n});
  final int n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MathColors.soft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '$n',
        style: AppTheme.baloo(fontSize: 36, fontWeight: FontWeight.w800, color: MathColors.primary),
      ),
    );
  }
}

class _SignVisual extends StatelessWidget {
  const _SignVisual({required this.task});
  final MathTask task;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NumberBox(n: task.left ?? 0),
        Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: MathColors.primary, width: 2, strokeAlign: BorderSide.strokeAlignInside),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text('?', style: AppTheme.baloo(fontSize: 24, color: MathColors.primary)),
        ),
        _NumberBox(n: task.right ?? 0),
      ],
    );
  }
}

class _ShapesVisual extends StatelessWidget {
  const _ShapesVisual({this.highlight});
  final MathShape? highlight;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: MathShape.values.map((s) {
        return _ShapeIcon(shape: s, large: s == highlight);
      }).toList(),
    );
  }
}

class _ShapeIcon extends StatelessWidget {
  const _ShapeIcon({required this.shape, this.large = false});
  final MathShape shape;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 56.0 : 44.0;
    final color = large ? MathColors.primary : DesignColors.textMuted;
    return switch (shape) {
      MathShape.circle => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      MathShape.square => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        ),
      MathShape.triangle => CustomPaint(
          size: Size(size, size),
          painter: _TriangleShapePainter(color),
        ),
      MathShape.rectangle => Container(
          width: size * 1.3,
          height: size * 0.7,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
    };
  }
}

class _TriangleShapePainter extends CustomPainter {
  _TriangleShapePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PatternVisual extends StatelessWidget {
  const _PatternVisual({required this.pattern});
  final List<String> pattern;

  @override
  Widget build(BuildContext context) {
    final shown = pattern.length > 5 ? pattern.sublist(0, 5) : pattern;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final p in shown)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(p, style: const TextStyle(fontSize: 32)),
          ),
        const Text('?', style: TextStyle(fontSize: 32, color: MathColors.primary)),
      ],
    );
  }
}

class _EquationVisual extends StatelessWidget {
  const _EquationVisual({required this.parts});
  final List<int> parts;

  @override
  Widget build(BuildContext context) {
    if (parts.length < 3) return const SizedBox.shrink();
    final op = parts[0] - parts[1] == parts[2] ? '−' : '+';
    return Text(
      '_ $op _ = ${parts[2]}',
      style: AppTheme.baloo(fontSize: 36, fontWeight: FontWeight.w800, color: MathColors.primary),
    );
  }
}

class _OrderVisual extends StatelessWidget {
  const _OrderVisual({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      alignment: WrapAlignment.center,
      children: items.map((e) => Text(e, style: const TextStyle(fontSize: 36))).toList(),
    );
  }
}

class _MoneyVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('🍦', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(
          '15 ₽',
          style: AppTheme.baloo(fontSize: 32, fontWeight: FontWeight.w800, color: MathColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          'У тебя: 10 ₽',
          style: TextStyle(fontWeight: FontWeight.w800, color: DesignColors.textMuted),
        ),
      ],
    );
  }
}

// ─── TASK INPUT ──────────────────────────────────────────────────────────────

class _TaskInput extends StatefulWidget {
  const _TaskInput({
    super.key,
    required this.task,
    required this.feedback,
    required this.showHint,
    required this.onSubmit,
  });

  final MathTask task;
  final _MathFeedback feedback;
  final bool showHint;
  final ValueChanged<dynamic> onSubmit;

  @override
  State<_TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends State<_TaskInput> {
  int? _selectedDigit;
  int? _selectedGroup;
  String? _selectedSign;
  MathShape? _selectedShape;
  String? _selectedPattern;
  bool? _yesNo;
  final List<int?> _equationSlots = [null, null, null];
  final List<String> _orderSlots = [];
  final Set<int> _tappedIndices = {};

  @override
  void initState() {
    super.initState();
    if (widget.task.orderItems != null) {
      _orderSlots.addAll(List.filled(widget.task.orderItems!.length, ''));
    }
  }

  bool get _canSubmit {
    return switch (widget.task.type) {
      MathTaskType.pickDigit ||
      MathTaskType.fillBlank ||
      MathTaskType.pickMatchingCount =>
        _selectedDigit != null,
      MathTaskType.tapAll => _tappedIndices.length == (widget.task.count ?? 0),
      MathTaskType.pickLargerGroup => _selectedGroup != null,
      MathTaskType.dragSign => _selectedSign != null,
      MathTaskType.pickShape => _selectedShape != null,
      MathTaskType.pickPattern => _selectedPattern != null,
      MathTaskType.buildEquation => _isEquationComplete,
      MathTaskType.yesNo => _yesNo != null,
      MathTaskType.dragOrder => !_orderSlots.contains(''),
    };
  }

  bool get _isEquationComplete {
    final parts = widget.task.equationParts;
    if (parts == null || parts.length < 3) return false;
    if (parts[0] - parts[1] == parts[2]) {
      return _equationSlots[1] != null;
    }
    return !_equationSlots.contains(null);
  }

  void _trySubmit() {
    if (!_canSubmit || widget.feedback == _MathFeedback.checking) return;
    final answer = switch (widget.task.type) {
      MathTaskType.pickDigit ||
      MathTaskType.fillBlank ||
      MathTaskType.pickMatchingCount =>
        _selectedDigit,
      MathTaskType.tapAll => _tappedIndices.length,
      MathTaskType.pickLargerGroup => _selectedGroup,
      MathTaskType.dragSign => _selectedSign,
      MathTaskType.pickShape => _selectedShape,
      MathTaskType.pickPattern => _selectedPattern,
      MathTaskType.buildEquation => _equationSlots,
      MathTaskType.yesNo => _yesNo,
      MathTaskType.dragOrder => _orderSlots.where((e) => e.isNotEmpty).toList(),
    };
    widget.onSubmit(answer);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        switch (widget.task.type) {
          MathTaskType.pickDigit ||
          MathTaskType.fillBlank ||
          MathTaskType.pickMatchingCount =>
            _DigitPicker(
              options: widget.task.options ?? [0, 1, 2, 3],
              selected: _selectedDigit,
              hint: widget.showHint ? widget.task.digit : null,
              onPick: (v) => setState(() => _selectedDigit = v),
            ),
          MathTaskType.tapAll => _TapCounter(
            emoji: widget.task.itemEmoji ?? widget.task.emoji ?? '⭐',
            useBasket: widget.task.useBasket,
            count: widget.task.count ?? 3,
            tapped: _tappedIndices,
            onTap: (i) => setState(() => _tappedIndices.add(i)),
          ),
          MathTaskType.pickLargerGroup => _GroupPicker(
            task: widget.task,
            selected: _selectedGroup,
            hint: widget.showHint ? widget.task.correctIndex : null,
            onPick: (v) => setState(() => _selectedGroup = v),
          ),
          MathTaskType.dragSign => _SignPicker(
            selected: _selectedSign,
            hint: widget.showHint ? widget.task.correctSign : null,
            onPick: (v) => setState(() => _selectedSign = v),
          ),
          MathTaskType.pickShape => _ShapePicker(
            selected: _selectedShape,
            hint: widget.showHint ? widget.task.shape : null,
            onPick: (v) => setState(() => _selectedShape = v),
          ),
          MathTaskType.pickPattern => _PatternPicker(
            options: const ['●', '▲'],
            selected: _selectedPattern,
            hint: widget.showHint ? widget.task.pattern?.last : null,
            onPick: (v) => setState(() => _selectedPattern = v),
          ),
          MathTaskType.buildEquation => _EquationBuilder(
            parts: widget.task.equationParts ?? [],
            slots: _equationSlots,
            hint: widget.showHint,
            onChanged: (i, v) => setState(() => _equationSlots[i] = v),
          ),
          MathTaskType.yesNo => _YesNoPicker(
            selected: _yesNo,
            hint: widget.showHint ? (widget.task.correctIndex == 1) : null,
            onPick: (v) => setState(() => _yesNo = v),
          ),
          MathTaskType.dragOrder => _OrderBuilder(
            items: widget.task.orderItems ?? [],
            slots: _orderSlots,
            hint: widget.showHint,
            onSlot: (i, v) => setState(() => _orderSlots[i] = v),
          ),
        },
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Проверить',
          onTap: _canSubmit ? _trySubmit : () {},
          color: _canSubmit ? MathColors.primary : DesignColors.textDim,
        ),
      ],
    );
  }
}

class _DigitPicker extends StatelessWidget {
  const _DigitPicker({
    required this.options,
    required this.selected,
    required this.onPick,
    this.hint,
  });

  final List<int> options;
  final int? selected;
  final int? hint;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: options.map((d) {
        final isSelected = selected == d;
        final isHint = hint == d;
        return GestureDetector(
          onTap: () => onPick(d),
          child: Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isHint
                  ? DesignColors.greenSoft
                  : isSelected
                      ? MathColors.primary
                      : MathColors.soft,
              borderRadius: BorderRadius.circular(18),
              border: isHint ? Border.all(color: DesignColors.green, width: 2) : null,
            ),
            child: Text(
              '$d',
              style: AppTheme.baloo(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : MathColors.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TapCounter extends StatelessWidget {
  const _TapCounter({
    required this.emoji,
    required this.count,
    required this.tapped,
    required this.onTap,
    this.useBasket = false,
  });

  final String emoji;
  final int count;
  final Set<int> tapped;
  final ValueChanged<int> onTap;
  final bool useBasket;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (useBasket)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MathCountVisual(
              itemEmoji: emoji,
              count: tapped.length,
              showBasket: true,
              minHeight: 100,
            ),
          ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: List.generate(count, (i) {
            final done = tapped.contains(i);
            return GestureDetector(
              onTap: done ? null : () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: done ? DesignColors.greenSoft : MathColors.soft,
                  borderRadius: BorderRadius.circular(16),
                  border: done ? Border.all(color: DesignColors.green) : null,
                ),
                child: Text(emoji, style: TextStyle(fontSize: 32, color: done ? DesignColors.green : null)),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _GroupPicker extends StatelessWidget {
  const _GroupPicker({
    required this.task,
    required this.selected,
    required this.onPick,
    this.hint,
  });

  final MathTask task;
  final int? selected;
  final int? hint;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PickTile(
            label: task.emoji != null ? '${task.left}' : '${task.left}',
            selected: selected == 0,
            hint: hint == 0,
            onTap: () => onPick(0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PickTile(
            label: task.emoji != null ? '${task.right}' : '${task.right}',
            selected: selected == 1,
            hint: hint == 1,
            onTap: () => onPick(1),
          ),
        ),
      ],
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.hint = false,
  });

  final String label;
  final bool selected;
  final bool hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hint
              ? DesignColors.greenSoft
              : selected
                  ? MathColors.primary
                  : MathColors.soft,
          borderRadius: BorderRadius.circular(18),
          border: hint ? Border.all(color: DesignColors.green, width: 2) : null,
        ),
        child: Text(
          label,
          style: AppTheme.baloo(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : MathColors.primary,
          ),
        ),
      ),
    );
  }
}

class _SignPicker extends StatelessWidget {
  const _SignPicker({required this.selected, required this.onPick, this.hint});

  final String? selected;
  final String? hint;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    const signs = ['>', '<', '='];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: signs.map((s) {
        final isSelected = selected == s;
        final isHint = hint == s;
        return GestureDetector(
          onTap: () => onPick(s),
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isHint
                  ? DesignColors.greenSoft
                  : isSelected
                      ? MathColors.primary
                      : MathColors.soft,
              borderRadius: BorderRadius.circular(16),
              border: isHint ? Border.all(color: DesignColors.green, width: 2) : null,
            ),
            child: Text(
              s,
              style: AppTheme.baloo(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : MathColors.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ShapePicker extends StatelessWidget {
  const _ShapePicker({required this.selected, required this.onPick, this.hint});

  final MathShape? selected;
  final MathShape? hint;
  final ValueChanged<MathShape> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: MathShape.values.map((s) {
        final isSelected = selected == s;
        final isHint = hint == s;
        return GestureDetector(
          onTap: () => onPick(s),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHint
                  ? DesignColors.greenSoft
                  : isSelected
                      ? MathColors.soft
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isHint
                    ? DesignColors.green
                    : isSelected
                        ? MathColors.primary
                        : Colors.transparent,
                width: 2,
              ),
            ),
            child: _ShapeIcon(shape: s, large: true),
          ),
        );
      }).toList(),
    );
  }
}

class _PatternPicker extends StatelessWidget {
  const _PatternPicker({
    required this.options,
    required this.selected,
    required this.onPick,
    this.hint,
  });

  final List<String> options;
  final String? selected;
  final String? hint;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((p) {
        final isSelected = selected == p;
        final isHint = hint == p;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () => onPick(p),
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isHint
                    ? DesignColors.greenSoft
                    : isSelected
                        ? MathColors.primary
                        : MathColors.soft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                p,
                style: TextStyle(fontSize: 28, color: isSelected ? Colors.white : null),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EquationBuilder extends StatelessWidget {
  const _EquationBuilder({
    required this.parts,
    required this.slots,
    required this.onChanged,
    required this.hint,
  });

  final List<int> parts;
  final List<int?> slots;
  final bool hint;
  final void Function(int index, int value) onChanged;

  @override
  Widget build(BuildContext context) {
    final uniquePool = parts.toSet().toList()..sort();
    final op = parts[0] - parts[1] == parts[2] ? '−' : '+';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (op == '−') ...[
              Text('${parts[0]}', style: AppTheme.baloo(fontSize: 28, color: MathColors.primary)),
              Text(' $op ', style: AppTheme.baloo(fontSize: 24)),
              _EqSlot(value: slots[1]),
              Text(' = ', style: AppTheme.baloo(fontSize: 24)),
              Text('${parts[2]}', style: AppTheme.baloo(fontSize: 28, color: MathColors.primary)),
            ] else ...[
              _EqSlot(value: slots[0]),
              Text(' $op ', style: AppTheme.baloo(fontSize: 24)),
              _EqSlot(value: slots[1]),
              Text(' = ', style: AppTheme.baloo(fontSize: 24)),
              Text('${parts[2]}', style: AppTheme.baloo(fontSize: 28, color: MathColors.primary)),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          alignment: WrapAlignment.center,
          children: uniquePool.map((n) {
            return GestureDetector(
              onTap: () {
                if (op == '−') {
                  if (slots[1] == null) onChanged(1, n);
                  return;
                }
                final empty = slots.indexWhere((s) => s == null);
                if (empty >= 0) onChanged(empty, n);
              },
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: hint && parts.contains(n) ? DesignColors.greenSoft : MathColors.soft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('$n', style: AppTheme.baloo(fontSize: 24, color: MathColors.primary)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EqSlot extends StatelessWidget {
  const _EqSlot({required this.value});
  final int? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: MathColors.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value?.toString() ?? '?',
        style: AppTheme.baloo(fontSize: 24, color: MathColors.primary),
      ),
    );
  }
}

class _YesNoPicker extends StatelessWidget {
  const _YesNoPicker({required this.selected, required this.onPick, this.hint});

  final bool? selected;
  final bool? hint;
  final ValueChanged<bool> onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PickTile(
            label: 'Да',
            selected: selected == true,
            hint: hint == true,
            onTap: () => onPick(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PickTile(
            label: 'Нет',
            selected: selected == false,
            hint: hint == false,
            onTap: () => onPick(false),
          ),
        ),
      ],
    );
  }
}

class _OrderBuilder extends StatelessWidget {
  const _OrderBuilder({
    required this.items,
    required this.slots,
    required this.onSlot,
    required this.hint,
  });

  final List<String> items;
  final List<String> slots;
  final bool hint;
  final void Function(int index, String value) onSlot;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slots.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: slots[i].isNotEmpty ? () => onSlot(i, '') : null,
                child: Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: MathColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(slots[i], style: const TextStyle(fontSize: 24)),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          alignment: WrapAlignment.center,
          children: items.map((e) {
            final used = slots.contains(e);
            return GestureDetector(
              onTap: used
                  ? null
                  : () {
                      final empty = slots.indexWhere((s) => s.isEmpty);
                      if (empty >= 0) onSlot(empty, e);
                    },
              child: Opacity(
                opacity: used ? 0.35 : 1,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hint ? DesignColors.greenSoft : MathColors.soft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(e, style: const TextStyle(fontSize: 28)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── SUCCESS ─────────────────────────────────────────────────────────────────

class MathSuccessScreen extends StatelessWidget {
  const MathSuccessScreen({
    super.key,
    required this.node,
    required this.completedCount,
    required this.totalCount,
    required this.onMap,
    required this.onNext,
    required this.hasNext,
  });

  final MathNode node;
  final int completedCount;
  final int totalCount;
  final VoidCallback onMap;
  final VoidCallback onNext;
  final bool hasNext;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [MathColors.primary, MathColors.primaryLight],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 40, 26, 130),
        child: Column(
          children: [
            const Text('🦫', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              'Тема пройдена!',
              style: AppTheme.baloo(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '«${node.title}» — отлично!\n+10 опыта для Бобра',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.92),
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Text(
                    'Уровень ${node.level} · ${node.title}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$completedCount / $totalCount тем',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            PrimaryButton(
              label: 'На карту уровней',
              onTap: onMap,
              color: Colors.white,
              textColor: MathColors.primary,
            ),
            if (hasNext) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onNext,
                child: const Text(
                  'Следующая тема →',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
