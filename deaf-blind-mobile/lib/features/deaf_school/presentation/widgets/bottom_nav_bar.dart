import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../app_screen.dart';

class DesignBottomNav extends StatelessWidget {
  const DesignBottomNav({
    super.key,
    required this.activeTab,
    required this.onHome,
    required this.onSubjects,
    required this.onClass,
    required this.onProfile,
  });

  final NavTab activeTab;
  final VoidCallback onHome;
  final VoidCallback onSubjects;
  final VoidCallback onClass;
  final VoidCallback onProfile;

  static const _on = AppColors.primary;
  static const _off = AppColors.textTertiary;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            label: 'Главная',
            active: activeTab == NavTab.home,
            onTap: onHome,
            icon: _homeIcon,
          ),
          _NavItem(
            label: 'Предметы',
            active: activeTab == NavTab.subjects,
            onTap: onSubjects,
            icon: _gridIcon,
          ),
          _NavItem(
            label: 'Класс',
            active: activeTab == NavTab.class_,
            onTap: onClass,
            icon: _classIcon,
          ),
          _NavItem(
            label: 'Профиль',
            active: activeTab == NavTab.profile,
            onTap: onProfile,
            icon: _profileIcon,
          ),
        ],
      ),
    );
  }

  static Widget _homeIcon(bool active) => Icon(
        Icons.home_rounded,
        size: 25,
        color: active ? _on : _off,
      );

  static Widget _gridIcon(bool active) => Icon(
        Icons.grid_view_rounded,
        size: 25,
        color: active ? _on : _off,
      );

  static Widget _classIcon(bool active) => Icon(
        Icons.videocam_rounded,
        size: 25,
        color: active ? _on : _off,
      );

  static Widget _profileIcon(bool active) => Icon(
        Icons.person_outline_rounded,
        size: 25,
        color: active ? _on : _off,
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.active,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final Widget Function(bool active) icon;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textTertiary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon(active),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AiTranslatorFab extends StatelessWidget {
  const AiTranslatorFab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.primary,
          boxShadow: AppShadows.heavy,
        ),
        child: const Icon(
          Icons.translate_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
