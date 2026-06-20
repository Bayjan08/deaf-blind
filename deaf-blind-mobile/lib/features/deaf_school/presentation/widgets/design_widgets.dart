import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/design_colors.dart';

class DesignBackButton extends StatelessWidget {
  const DesignBackButton({
    super.key,
    required this.onTap,
    this.light = false,
  });

  final VoidCallback onTap;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: light
              ? Colors.white.withValues(alpha: 0.16)
              : AppColors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: light ? null : AppShadows.light,
        ),
        child: Transform.scale(
          scaleX: -1,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: light ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Unaa-style streak badge for screens other than the Deaf School home tab
/// (which keeps the original orange [StreakBadge]).
class AppStreakBadge extends StatelessWidget {
  const AppStreakBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: compact ? AppColors.white : AppColors.grey100,
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        boxShadow: compact ? AppShadows.light : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: compact ? 14 : 15,
            color: AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            '12',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: compact ? 14 : 15,
            ),
          ),
        ],
      ),
    );
  }
}

/// Unaa-style avatar for screens other than the Deaf School home tab (which
/// keeps the original [AvatarImage]).
class AppAvatarImage extends StatelessWidget {
  const AppAvatarImage({
    super.key,
    required this.size,
    this.borderWidth = 0,
  });

  final double size;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey200,
        boxShadow: AppShadows.medium,
        border: borderWidth > 0
            ? Border.all(color: AppColors.white, width: borderWidth)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/avatar.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 12,
        vertical: compact ? 7 : 7,
      ),
      decoration: BoxDecoration(
        color: compact ? Colors.white : DesignColors.orangeSoft,
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        boxShadow: compact
            ? [
                BoxShadow(
                  color: DesignColors.textDark.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: compact ? 14 : 15,
            color: DesignColors.orange,
          ),
          const SizedBox(width: 5),
          Text(
            '12',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: DesignColors.orange,
              fontSize: compact ? 14 : 15,
            ),
          ),
        ],
      ),
    );
  }
}

class AvatarImage extends StatelessWidget {
  const AvatarImage({
    super.key,
    required this.size,
    this.borderWidth = 0,
  });

  final double size;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFCDD6EA),
        boxShadow: borderWidth > 0
            ? [
                BoxShadow(
                  color: DesignColors.purple.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ]
            : [
                BoxShadow(
                  color: DesignColors.purple.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
        border: borderWidth > 0
            ? Border.all(color: Colors.white, width: borderWidth)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/avatar.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class CardShadow extends StatelessWidget {
  const CardShadow({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.medium,
      ),
      child: child,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
    this.textColor = Colors.white,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.medium,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class LockedLevelNode extends StatelessWidget {
  const LockedLevelNode({
    super.key,
    required this.label,
    this.large = false,
  });

  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: large ? 92 : 74,
          height: large ? 78 : 70,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(large ? 18 : 16),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (large)
                Positioned(
                  top: -14,
                  child: Row(
                    children: [
                      _castlePillar(18),
                      const SizedBox(width: 4),
                      _castlePillar(24),
                      const SizedBox(width: 4),
                      _castlePillar(18),
                    ],
                  ),
                ),
              Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _castlePillar(double h) => Container(
        width: 14,
        height: h,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(3),
        ),
      );
}
