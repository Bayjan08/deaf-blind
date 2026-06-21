import 'dart:math' as math;
import 'package:flutter/material.dart';

class Pet {
  final String id;
  final String asset;
  const Pet(this.id, this.asset);
}

const List<Pet> kPets = <Pet>[
  Pet('cat', 'assets/pets/cat.png'),
  Pet('dog', 'assets/pets/dog.png'),
  Pet('fox', 'assets/pets/fox.png'),
  Pet('dragon', 'assets/pets/dragon.png'),
  Pet('penguin', 'assets/pets/penguin.png'),
];

class PetSelectionScreen extends StatefulWidget {
  final ValueChanged<Pet>? onConfirmed;
  const PetSelectionScreen({super.key, this.onConfirmed});

  @override
  State<PetSelectionScreen> createState() => _PetSelectionScreenState();
}

class _PetSelectionScreenState extends State<PetSelectionScreen>
    with TickerProviderStateMixin {
  static const Color _accent = Color(0xFF8A63EA);
  static const Color _accentDark = Color(0xFF6F43D6);
  static const Color _cardBg = Color(0xFFFFE7CF);
  static const Color _cardEdge = Color(0xFFF3973F);
  static const Color _ink = Color(0xFF2C4A5E);

  String? _selectedId;
  String? _glowId;
  bool _confirmed = false;

  late final AnimationController _idle;
  late final AnimationController _enter;
  late final AnimationController _fab;
  late final AnimationController _ring;
  late final AnimationController _jump;

  late final Animatable<double> _jumpY;
  late final Animatable<double> _jumpScale;
  late final Animatable<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _enter =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 580));
    _fab =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _ring =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    _jump =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 850));

    _jumpY = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: -40.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 35),
      TweenSequenceItem(
          tween: Tween(begin: -40.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 35),
    ]);
    _jumpScale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.07), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.07, end: 0.97), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.0), weight: 35),
    ]);
    _fabScale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(
          tween: Tween(begin: 0.6, end: 1.18)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 60),
      TweenSequenceItem(
          tween: Tween(begin: 1.18, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 40),
    ]);

    // Pre-select the first pet by default
    _selectedId = kPets.first.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enter.forward();
      _fab.forward();
    });
  }

  @override
  void dispose() {
    _idle.dispose();
    _enter.dispose();
    _fab.dispose();
    _ring.dispose();
    _jump.dispose();
    super.dispose();
  }

  Pet? get _selected =>
      _selectedId == null ? null : kPets.firstWhere((p) => p.id == _selectedId);

  void _selectPet(Pet p) {
    setState(() {
      _glowId = p.id;
      _confirmed = false;
    });
    _ring.reset();
    _jump.reset();
    Future.delayed(const Duration(milliseconds: 230), () {
      if (!mounted) return;
      setState(() {
        _selectedId = p.id;
        _glowId = null;
      });
      _enter.forward(from: 0);
      _fab.forward(from: 0);
    });
  }

  void _confirm() {
    final pet = _selected;
    if (pet == null) return;
    setState(() => _confirmed = true);
    _ring.forward(from: 0);
    _jump.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      widget.onConfirmed?.call(pet);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double petSize = math.min(w * 0.82, 360.0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCDEEFB), Color(0xFFB3E0F6), Color(0xFFA6D6F2)],
            stops: [0.0, 0.52, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 14, 26, 4),
                child: Image.asset(
                  'assets/pets/gesture.png',
                  height: 84,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(child: _buildStage(petSize)),
              _buildRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStage(double petSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_selected == null) _placeholder(),
        if (_selected != null) _stagePet(petSize),
        if (_confirmed) _confirmRing(petSize),
        if (_selected != null)
          Positioned(right: 26, bottom: 18, child: _confirmFab()),
      ],
    );
  }

  Widget _placeholder() {
    return AnimatedBuilder(
      animation: _idle,
      builder: (context, _) {
        final double e = Curves.easeInOut.transform(_idle.value);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, -9 * e),
              child: Container(
                width: 172,
                height: 172,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _ink.withValues(alpha:0.32), width: 3),
                ),
                child: Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha:0.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Opacity(
              opacity: 0.55 + 0.45 * e,
              child: const Text(
                'tap a friend below ↓',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A6076),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _stagePet(double petSize) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idle, _enter, _jump]),
      builder: (context, _) {
        final double ie = Curves.easeInOut.transform(_idle.value);
        final double idleY = -16.0 * ie;
        final double idleRotDeg = -2.2 + 4.4 * ie;

        final double et = _enter.value;
        final double enterScale = 0.35 + 0.65 * Curves.easeOutBack.transform(et);
        final double enterY = 150.0 * (1 - Curves.easeOutCubic.transform(et));
        final double enterOpacity = (et / 0.6).clamp(0.0, 1.0);

        final double jumpY =
            _jump.isAnimating || _confirmed ? _jumpY.evaluate(_jump) : 0.0;
        final double jumpScale =
            _jump.isAnimating || _confirmed ? _jumpScale.evaluate(_jump) : 1.0;

        return Opacity(
          opacity: enterOpacity,
          child: Transform.translate(
            offset: Offset(0, idleY + enterY + jumpY),
            child: Transform.rotate(
              angle: idleRotDeg * math.pi / 180.0,
              child: Transform.scale(
                scale: enterScale * jumpScale,
                child: Image.asset(
                  _selected!.asset,
                  width: petSize,
                  height: petSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _confirmRing(double petSize) {
    final double base = petSize * 0.8;
    return AnimatedBuilder(
      animation: _ring,
      builder: (context, _) {
        if (_ring.value == 0) return const SizedBox.shrink();
        final double t = _ring.value;
        final double scale = 0.5 + (2.4 - 0.5) * Curves.easeOut.transform(t);
        return Opacity(
          opacity: 0.7 * (1 - t),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: base,
              height: base,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _accent, width: 5),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _confirmFab() {
    return AnimatedBuilder(
      animation: _fab,
      builder: (context, child) {
        final double s = _fab.isAnimating ? _fabScale.evaluate(_fab) : 1.0;
        return Transform.scale(scale: s, child: child);
      },
      child: GestureDetector(
        onTap: _confirm,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              colors: [_accent, _accentDark],
            ),
            boxShadow: [
              BoxShadow(
                color: _accentDark.withValues(alpha:0.5),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: _accent.withValues(alpha:0.18),
                blurRadius: 0,
                spreadRadius: 6,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
        ),
      ),
    );
  }

  Widget _buildRow() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha:0.0), Colors.white.withValues(alpha:0.42)],
          stops: const [0.0, 0.38],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 22),
      child: SizedBox(
        height: 112,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          itemCount: kPets.length,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (context, i) => _petCard(kPets[i]),
        ),
      ),
    );
  }

  Widget _petCard(Pet p) {
    final bool selected = _selectedId == p.id;
    final bool glow = _glowId == p.id;
    return GestureDetector(
      onTap: () => _selectPet(p),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: _cardEdge, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB46E28).withValues(alpha:0.5),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(9),
            child: Image.asset(p.asset, fit: BoxFit.contain),
          ),
          if (selected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: _accent, width: 3),
                ),
              ),
            ),
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: glow ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: _accent, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha:0.7),
                      blurRadius: 22,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
