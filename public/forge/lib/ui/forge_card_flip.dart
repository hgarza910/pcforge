// lib/ui/forge_card_flip.dart
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/forge_models.dart';
import 'forge_card.dart';
import 'forge_card_back.dart';

class ForgeCardFlip extends StatefulWidget {
  const ForgeCardFlip({
    super.key,
    required this.front,
    required this.back,
    this.images = const <Uint8List>[],
    this.initialFlipped = false,
    this.onFlip,
  });

  final ForgeBuild front;
  final ForgeBuildBackData back;
  final List<Uint8List> images;
  final bool initialFlipped;
  final VoidCallback? onFlip;

  @override
  State<ForgeCardFlip> createState() => _ForgeCardFlipState();
}

class _ForgeCardFlipState extends State<ForgeCardFlip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _angle; // 0..π

  bool get _isFlipped => _ctrl.value >= 0.5;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: widget.initialFlipped ? 1.0 : 0.0,
    );
    _angle = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isFlipped) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
    widget.onFlip?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Both faces are always in the tree; we rotate the “deck” and
    // counter-rotate the back so it reads correctly.
    return GestureDetector(
      onDoubleTap: _toggle,
      child: AnimatedBuilder(
        animation: _angle,
        builder: (context, _) {
          final a = _angle.value; // 0..π
          final showBack = a > math.pi / 2;

          // Common 3D perspective matrix
          Matrix4 _deck(double angle) => Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle);

          // When showing the back, we counter-rotate its CONTENT by π so text isn't mirrored.
          Widget _counterRotatedBack() => Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: BackForgedCardWeb(
              frontBuild: widget.front,
              back: widget.back,
              onFlip: _toggle,
              key: const ValueKey('back'),
            ),
          );

          return Stack(
            alignment: Alignment.center,
            children: [
              // FRONT face: visible for angles 0..(π/2)
              IgnorePointer(ignoring: showBack, child: Opacity(
                opacity: showBack ? 0.0 : 1.0,
                child: Transform(
                  alignment: Alignment.center,
                  transform: _deck(a),
                  child: ForgedCardWeb(
                    key: const ValueKey('front'),
                    build: widget.front,
                    images: widget.images,
                    onFlip: _toggle,
                  ),
                ),
              )),

              // BACK face: visible for angles (π/2)..π
              IgnorePointer(ignoring: !showBack, child: Opacity(
                opacity: showBack ? 1.0 : 0.0,
                child: Transform(
                  alignment: Alignment.center,
                  // rotate the deck by current angle, which is near π when back is showing
                  transform: _deck(a),
                  // then counter-rotate the CONTENT by π so it reads normally
                  child: _counterRotatedBack(),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}

/// (unchanged) Grid helper you may still be using in other screens.
class ForgeCardPreviewDeck extends StatelessWidget {
  const ForgeCardPreviewDeck({
    super.key,
    required this.fronts,
    required this.backs,
    this.images = const <List<Uint8List>>[],
    this.crossAxisCount = 2,
  }) : assert(fronts.length == backs.length);

  final List<ForgeBuild> fronts;
  final List<ForgeBuildBackData> backs;
  final List<List<Uint8List>> images;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 300 / 480,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: fronts.length,
      itemBuilder: (_, i) => Center(
        child: ForgeCardFlip(
          front: fronts[i],
          back: backs[i],
          images: i < images.length ? images[i] : const <Uint8List>[],
        ),
      ),
    );
  }
}
