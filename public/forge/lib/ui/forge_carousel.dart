// lib/ui/forge_carousel.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/forge_models.dart';
import '../theme/forge_theme_shim.dart';
import 'forge_card_flip.dart';
import 'dart:ui' show PointerDeviceKind;

class ForgeCarousel extends StatefulWidget {
  const ForgeCarousel({
    super.key,
    required this.fronts,
    required this.backs,
    this.images = const <List<Uint8List>>[],
    this.height = 520,          // total area height (includes some padding)
    this.viewportFraction = 0.78, // how wide each card appears (0–1)
    this.onIndexChanged,
  });

  final List<ForgeBuild> fronts;
  final List<ForgeBuildBackData> backs;
  final List<List<Uint8List>> images;
  final double height;
  final double viewportFraction;
  final void Function(int index)? onIndexChanged;

  @override
  State<ForgeCarousel> createState() => _ForgeCarouselState();
}

bool _isPhone(BuildContext context) =>
    MediaQuery.of(context).size.width < 640;

class _ForgeCarouselState extends State<ForgeCarousel> {
  PageController? _pc;          // <- not final; we may recreate it
  double _page = 0.0;
  double _currentVF = 0.0;      // track applied viewportFraction

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final phone = _isPhone(context);
    final desiredVF = phone ? 0.92 : widget.viewportFraction;

    if (_pc == null || _currentVF != desiredVF) {
      final initialIndex = _pc?.hasClients == true
          ? (_pc!.page ?? _pc!.initialPage.toDouble()).round()
          : 0;

      _pc?.dispose();
      _pc = PageController(
        viewportFraction: desiredVF,
        initialPage: initialIndex,
      );

      _currentVF = desiredVF;
      _page = initialIndex.toDouble(); // keep initial scale/opacity correct
      setState(() {});                 // ensure rebuild with new controller
    }
  }

  @override
  void dispose() {
    _pc?.dispose();
    super.dispose();
  }


  void _jump(int delta) {
    final next = (_pc!.page ?? 0).round() + delta;
    if (next < 0 || next >= widget.fronts.length) return;
    _pc!.animateToPage(next,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic);
    widget.onIndexChanged?.call(next);
  }



// lib/ui/forge_carousel.dart  (only the build(...) changed + a couple tiny helpers)



  @override
  Widget build(BuildContext context) {
    final forge = PcForgeTheme.forge;
    final accent = forge.accentPrimary;
    final phone = _isPhone(context);

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              final m = n.metrics;
              if (m is PageMetrics && m.page != null) {
                final p = m.page!;
                if (p != _page) setState(() => _page = p);
              }
              return false;
            },
            child: PageView.builder(
              controller: _pc!,
              itemCount: widget.fronts.length,
              clipBehavior: Clip.none,
              padEnds: phone ? true : false,     // <- center first/last on phones
              allowImplicitScrolling: true,
              onPageChanged: (i) {
                setState(() => _page = i.toDouble());
                widget.onIndexChanged?.call(i);
              },
              scrollBehavior: const _WebScrollBehavior(),
              itemBuilder: (context, index) {
                final distance = (index - _page).abs().clamp(0.0, 1.0);
                final shrink   = phone ? 0.08 : 0.06;
                final lift     = phone ? 10.0 : 8.0;

                final scale    = 1.0 - (shrink * distance);
                final elevate  = (1.0 - distance) * lift;
                final fade     = 1.0 - (0.25 * distance);

                final imgs = (index < widget.images.length)
                    ? widget.images[index]
                    : const <Uint8List>[];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
                  child: Align(                       // <- hard-center each page
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(0, 8 - elevate),
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: fade,
                          child: ForgeCardFlip(
                            front: widget.fronts[index],
                            back: widget.backs[index],
                            images: imgs,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (!phone) Positioned.fill(
            child: Row(
              children: [
                _arrowBtn(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _jump(-1),
                  alignment: Alignment.centerLeft,
                  accent: accent,
                ),
                const Spacer(),
                _arrowBtn(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _jump(1),
                  alignment: Alignment.centerRight,
                  accent: accent,
                ),
              ],
            ),
          ),

          Positioned(
            bottom: phone ? 12 : 6,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.fronts.length, (i) {
                final active = (_page.round() == i);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                  width: active ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: (active ? accent : Colors.white30)
                        .withOpacity(active ? 0.95 : 0.55),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }


  Widget _arrowBtn({
    required IconData icon,
    required VoidCallback onTap,
    required Alignment alignment,
    required Color accent,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.38),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: accent.withOpacity(0.55), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 26, color: Colors.white.withOpacity(0.95)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Allow mouse wheel (shift+wheel) to pan horizontally on web without glow.
class _WebScrollBehavior extends MaterialScrollBehavior {
  const _WebScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: ClampingScrollPhysics());
}
