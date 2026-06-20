import 'package:flutter/material.dart';

import '../../../../../core/theme/design_colors.dart';
import 'lobby_actions.dart';

class LobbyJoinCard extends StatelessWidget {
  const LobbyJoinCard({
    super.key,
    required this.controller,
    required this.onJoin,
    required this.loading,
  });

  final TextEditingController controller;
  final VoidCallback? onJoin;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DesignColors.textDark.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Присоединиться по коду',
            style: TextStyle(fontWeight: FontWeight.w800, color: DesignColors.textDark),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'ABC123',
              filled: true,
              fillColor: DesignColors.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          LobbySecondaryButton(label: 'Войти в класс', onTap: loading ? null : onJoin),
        ],
      ),
    );
  }
}
