import 'package:flutter/material.dart';

/// §1/§6/§7 KEYSTONE: plays an ordered list of avatar animation clips
/// (pre-built Rive/Lottie) keyed by vocabulary id. ML-light by design.
class SignAvatarPlayer extends StatelessWidget {
  const SignAvatarPlayer({super.key, required this.animationIds});

  final List<int> animationIds;

  @override
  Widget build(BuildContext context) => const Placeholder();
}
