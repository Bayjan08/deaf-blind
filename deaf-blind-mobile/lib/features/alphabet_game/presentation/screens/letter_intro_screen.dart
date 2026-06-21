import 'package:flutter/material.dart';
import 'letter_practice_screen.dart';

class LetterIntroScreen extends StatefulWidget {
  const LetterIntroScreen({
    super.key,
    required this.letter,
    required this.word,
    required this.petAsset,
  });

  final String letter;
  final String word;
  final String petAsset;

  @override
  State<LetterIntroScreen> createState() => _LetterIntroScreenState();
}

class _LetterIntroScreenState extends State<LetterIntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wobble = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _wobble.dispose();
    super.dispose();
  }

  void _goToPractice() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => LetterPracticeScreen(
        letter: widget.letter,
        petAsset: widget.petAsset,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final rest = widget.word.length > 1 ? widget.word.substring(1) : '';
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFDCEFFF), Color(0xFFEAF6FD), Color(0xFFF4FBFF)],
            ),
          ),
          child: Stack(children: [
            Column(children: [
              // back button row (no text)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _RoundButton(
                    icon: Icons.chevron_left,
                    onTap: () => Navigator.maybePop(context),
                  ),
                ),
              ),
              // hero zone with wobbling letter image
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFBFE6FB), Color(0xFFA9D8F4)],
                      ),
                    ),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _wobble,
                        builder: (_, child) => Transform.rotate(
                          angle: (_wobble.value - 0.5) * 0.13,
                          alignment: Alignment.bottomCenter,
                          child: child,
                        ),
                        child: Image.asset(
                          'assets/letter_a.png',
                          width: 200,
                          errorBuilder: (_, _, _) => Text(
                            widget.letter,
                            style: const TextStyle(
                              fontSize: 160,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF3E9FD6),
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // compare cards — images only, no labels
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: Row(children: [
                  Expanded(child: _CompareCard(asset: 'assets/hand_sign_a.png')),
                  const SizedBox(width: 13),
                  Expanded(child: _CompareCard(asset: 'assets/watermelon.png')),
                ]),
              ),
              // word "Арбуз" with orange first letter — the only text
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      TextSpan(
                        text: widget.letter,
                        style: const TextStyle(color: Color(0xFFF2941F)),
                      ),
                      TextSpan(
                        text: rest,
                        style: const TextStyle(color: Color(0xFF3F6275)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 90),
            ]),
            // floating green check button
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _goToPractice,
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3DD27A), Color(0xFF22B45F)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22B45F).withValues(alpha: 0.5),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 38),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3E9FD6).withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF3E9FD6)),
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  const _CompareCard({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 138,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E9FD6).withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: Color(0xFFBFE6FB),
        ),
      ),
    );
  }
}
