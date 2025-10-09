// lib/ui/forge_card.dart (Front) — Web Demo version matching final ForgedCard
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../theme/forge_theme_shim.dart';
import '../models/forge_models.dart';
import 'shared_widgets.dart' as sw; // alias shared widgets to avoid name collisions
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // web-only; safe since you're targeting Flutter web.
import 'dart:ui' show ImageFilter, FontFeature;
import 'warranty_badge.dart';

const bool kPersistEmberScore = false;

class ForgedCardWeb extends StatefulWidget {
  const ForgedCardWeb({
    super.key,
    required this.build,
    this.images = const <Uint8List>[],
    this.onDelete,
    this.onFlip,
    this.onOpenAddParts, // optional action for the bottom CTA
  });

  final ForgeBuild build;
  final List<Uint8List> images; // cover-first if you want
  final void Function(ForgeBuild build)? onDelete;
  final VoidCallback? onFlip;
  final VoidCallback? onOpenAddParts;

  @override
  State<ForgedCardWeb> createState() => _ForgedCardWebState();
}

class _ForgedCardWebState extends State<ForgedCardWeb>
    with TickerProviderStateMixin {
  bool _editingName = false;
  late final TextEditingController _nameCtrl;
  final FocusNode _nameFocus = FocusNode();
  int _galleryIndex = 0;
  late final PageController _pageController;

  late int _emberScore;               // live counter shown in the pill
  late final AnimationController _popCtrl;      // +1 bubble
  late final Animation<double> _popFade;
  late final Animation<Offset> _popSlide;

  late final AnimationController _cardPopCtrl;  // card scale pop
  late final Animation<double> _cardScale;

  String get _emberKey => 'ember_${widget.build.id}';
  bool _isPhone(BuildContext context) => MediaQuery.sizeOf(context).width < 640;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.build.name);
    _pageController = PageController(initialPage: _galleryIndex);

    _emberScore = _readEmber() ?? widget.build.derivedEmberScore;

    _popCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _popFade = CurvedAnimation(parent: _popCtrl, curve: Curves.easeOut);
    _popSlide = Tween<Offset>(begin: const Offset(0, 0.0), end: const Offset(0, -0.8))
        .animate(CurvedAnimation(parent: _popCtrl, curve: Curves.easeOutCubic));

    _cardPopCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _cardScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_cardPopCtrl);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameFocus.dispose();
    _pageController.dispose();
    _popCtrl.dispose();
    _cardPopCtrl.dispose();
    super.dispose();
  }

  void _startEditName() {
    setState(() => _editingName = true);
    Future.delayed(const Duration(milliseconds: 30), () => _nameFocus.requestFocus());
  }

  void _commitEditName() {
    setState(() => _editingName = false);
  }

  int? _readEmber() {
    if (!kPersistEmberScore || !kIsWeb) return null;
    try {
      final v = html.window.localStorage[_emberKey];
      return v == null ? null : int.tryParse(v);
    } catch (_) { return null; }
  }

  void _saveEmber(int v) {
    if (!kPersistEmberScore || !kIsWeb) return;
    try { html.window.localStorage[_emberKey] = v.toString(); } catch (_) {}
  }

  void _resetEmber() {
    if (!kIsWeb) return;
    try { html.window.localStorage.remove(_emberKey); } catch (_) {}
    setState(() => _emberScore = widget.build.derivedEmberScore);
  }

  void _bumpEmber() {
    setState(() => _emberScore += 1);
    _saveEmber(_emberScore);
    _popCtrl.forward(from: 0);     // +1 bubble
    _cardPopCtrl.forward(from: 0); // card pop
  }

  int? _demoCoveredPartsFor(String id) {
    final sum = id.codeUnits.fold<int>(0, (a, b) => a + b);
    final r = sum % 10;        // 0..9
    if (r == 9) return null;   // stub / not uploaded
    return (r % 9).clamp(0, 8);
  }

  @override
  Widget build(BuildContext context) {
    final forge = PcForgeTheme.forge;
    const double kCardRadius = 20;

    // Match: status-driven glow color for the rim/halo
    final style = _statusStyle(widget.build.derivedStatus, accent: forge.accentPrimary);
    final Color? glowColor = style['glow'] as Color?;

    return GestureDetector(
      onDoubleTap: _bumpEmber,
      behavior: HitTestBehavior.translucent,
      child: ScaleTransition(
        scale: _cardScale,
        child: Container(
          width: 300,
          height: 450,
          decoration: _buildCardDecoration(forge, glow: glowColor),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1) Blur + tint overlay (UNDER everything)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kCardRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                    child: Container(color: forge.slab.withOpacity(0.28)),
                  ),
                ),
              ),

              // 2) Vignette ABOVE blur, BELOW content (keeps center readable)
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(kCardRadius),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.05),
                          radius: 0.9,
                          colors: [
                            const Color(0x00000000),
                            PcForgeTheme.soot.withOpacity(0.08),
                            PcForgeTheme.soot.withOpacity(0.18),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 3) Content
              Align(
                alignment: Alignment.center,
                child: SizedBox(width: 275, height: 425, child: _buildCardContainer(context)),
              ),

              // 4) Badges/buttons (warranty top-right, delete/flip bottom corners)
// lib/ui/forge_card.dart
              Positioned(
                top: 10,
                right: 10,
                child: WarrantyBadge(
                  coveredParts: _demoCoveredPartsFor(widget.build.id),
                  totalParts: 8,
                  textMode: WarrantyBadgeTextMode.none,
                  scale: 0.9, // matches the app’s look
                ),
              ),




              Positioned(bottom: 8, left: 8, child: _buildDeleteButton(context)),
              Positioned(bottom: 8, right: 8, child: _buildFlipButton(context)),

              // 5) Bottom centered CTA (optional, matches “Add Parts / View Build”)
              Positioned(
                bottom: 15, left: 0, right: 0,
                child: Center(child: _buildAddPartsButton(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer(BuildContext context) {
    final forge = PcForgeTheme.forge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, forge),
        const SizedBox(height: 8),
        _buildMockupPreview(context),
        const SizedBox(height: 2),
        _buildHighlightBanner(widget.build.trio),
        _buildPriceRowWithBackplate(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ForgeZone forge) {
    final width = MediaQuery.of(context).size.width;
    double nameSize;
    if (width >= 768) {
      nameSize = 22; // tablets
    } else if (width >= 380) {
      nameSize = 20; // most modern phones
    } else {
      nameSize = 19; // compact phones
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ID + Tier pill
        Padding(
          padding: const EdgeInsets.only(bottom: 2, left: 10),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('#${widget.build.id.substring(0, 6).toUpperCase()}',
                style: TextStyle(fontSize: 10, color: forge.textMuted)),
            const SizedBox(width: 6),
            _buildTierPillInlineNullable(widget.build.tier),
          ]),
        ),

        // Editable name (left pad = 10 to align with ID/Tier)
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: _editingName
              ? ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 230),
            child: TextField(
              controller: _nameCtrl,
              focusNode: _nameFocus,
              maxLength: 32,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: forge.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                counterText: '',
                hintText: 'Build name…',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _commitEditName(),
              onEditingComplete: _commitEditName,
            ),
          )
              : GestureDetector(
            onTap: _startEditName,
            child: Stack(children: [
              Positioned(
                top: 1.2,
                left: 1.2,
                child: Text(
                  widget.build.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900.withOpacity(0.6),
                  ),
                ),
              ),
              Text(
                widget.build.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: nameSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.15,
                  height: 1.05,
                  color: forge.textPrimary,
                  shadows: const [
                    Shadow(offset: Offset(-0.5, -0.5), blurRadius: 1, color: Colors.white24),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildMockupPreview(BuildContext context) {
    final accent = PcForgeTheme.forge.accentPrimary;
    final images = widget.images;
    final hasAny = images.isNotEmpty;

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 270,
        child: AspectRatio(
          aspectRatio: 3 / 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 3, color: accent.withOpacity(0.25)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF16181B), Color(0xFF0F1113)],
              ),
              boxShadow: [
                // mimic subtle inset/ambient (web-safe approximation)
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(2,2)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(fit: StackFit.expand, children: [
                // Content
                if (!hasAny)
                  Center(
                    child: Image.asset(
                      'assets/images/tower_silhouette_main.png',
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                      gaplessPlayback: true,
                    ),
                  )
                else
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _galleryIndex = i),
                      itemBuilder: (_, i) => Image.memory(
                        images[i],
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                  ),

                // subtle glass sweep overlay
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.06),
                          Colors.transparent,
                          Colors.white.withOpacity(0.03),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // HUD badges — Ember pill
                Positioned(top: 8, right: 8, child: _emberPillSmall(context)),

                // +1 bubble
                Positioned(
                  top: 2,
                  right: 14,
                  child: FadeTransition(
                    opacity: _popFade,
                    child: SlideTransition(
                      position: _popSlide,
                      child: const _PlusOne(),
                    ),
                  ),
                ),

                // Status badge (bottom-left)
                _buildStatusBadge(widget.build.derivedStatus),

                // page dots
                if (images.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (i) {
                        final active = i == _galleryIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: (active ? accent : Colors.white30)
                                .withOpacity(active ? 0.9 : 0.5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emberPillSmall(BuildContext context) {
    final accent = PcForgeTheme.forge.accentPrimary;
    final liked = _emberScore > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: _bumpEmber,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent.withOpacity(liked ? 0.85 : 0.65), width: 1),
            boxShadow: liked ? [BoxShadow(color: accent.withOpacity(0.6), blurRadius: 8, spreadRadius: 1)] : [],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.local_fire_department, size: 14, color: liked ? accent : accent.withOpacity(0.8)),
            const SizedBox(width: 4),
            Text('x$_emberScore', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)),
          ]),
        ),
      ),
    );
  }

  // ——— Highlight Banner (bars, narrower hairline, compact font) ———
  Widget _buildHighlightBanner(List<String> trio) {
    final accent = PcForgeTheme.forge.accentPrimary;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _hairline(accent, height: 1.3),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _highlightText(trio.elementAt(0), maxWidth: 92, fontSize: 9.5),
              _trioSeparatorBar(),
              _highlightText(trio.elementAt(1), maxWidth: 100, fontSize: 9.5),
              _trioSeparatorBar(),
              _highlightText(trio.elementAt(2), maxWidth: 92, fontSize: 9.5),
            ],
          ),
          const SizedBox(height: 6),
          _hairline(accent, height: 1.3),
        ],
      ),
    );
  }

  Widget _hairline(Color accent, {double height = 1.2}) => Container(
    height: height,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft, end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          accent.withOpacity(0.34),
          accent.withOpacity(0.58),
          accent.withOpacity(0.34),
          Colors.transparent,
        ],
        stops: const [0.0, 0.18, 0.5, 0.82, 1.0],
      ),
      boxShadow: [
        BoxShadow(color: accent.withOpacity(0.16), blurRadius: 2.2, spreadRadius: 0.25),
      ],
    ),
  );

  Widget _trioSeparatorBar({double h = 12}) {
    final accent = PcForgeTheme.forge.accentPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 1.2, height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [accent.withOpacity(0.0), accent.withOpacity(0.65), accent.withOpacity(0.0)],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _highlightText(String text, {double maxWidth = 92, double fontSize = 9.5}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
          letterSpacing: 0.45,
          height: 1.05,
        ),
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }

  // ——— Price Row (gradient price + molten micro-pill + QR) ———
  Widget _buildPriceRowWithBackplate(BuildContext context) {
    const double qrChipSize = 95.0;
    return SizedBox(
      height: qrChipSize + 16,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: _buildPriceAndActions(context)),
        ],
      ),
    );
  }

  Widget _buildPriceAndActions(BuildContext context) {
    final forge = PcForgeTheme.forge;
    final accent = forge.accentPrimary;
    const double qrChipSize = 95;

    final price = '\$${widget.build.livePrice.toStringAsFixed(0)}';

    final TextStyle base = Theme.of(context).textTheme.headlineSmall
        ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

    final priceTextStyle = base.copyWith(
      fontSize: (base.fontSize ?? 18) + 6,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
      fontFeatures: const [FontFeature.tabularFigures()],
      foreground: Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFE6ECFF), // near-white blue
            Colors.white,
            Color(0xFFBFD3FF), // soft steel
          ],
          stops: [0.0, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, 260, 60)),
      shadows: const [
        Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black54),
        Shadow(offset: Offset(0, 0), blurRadius: 8, color: Colors.black38),
      ],
    );

    // Web demo lacks a real build date; emulate label from status
    final status = (widget.build.derivedStatus ?? '').toLowerCase();
    final builtLabel = status == 'completed'
        ? 'Built —'
        : (status == 'in_progress' ? 'In progress' : 'Updated —');

    final captionStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 10,
      height: 1.0,
      letterSpacing: 0.35,
      fontWeight: FontWeight.w600,
      color: Colors.white.withOpacity(0.65),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 0, right: 8, left: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // LEFT — PRICE + DATE (nudged up a touch)
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(price, style: priceTextStyle),
                    ),
                    const SizedBox(height: 3),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.red.withOpacity(0.08),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 0.8,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule, size: 11, color: Colors.white60),
                              const SizedBox(width: 4),
                              Text(builtLabel.toUpperCase(), style: captionStyle),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // RIGHT — Demo QR (keeps your DemoChipQr)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  blurRadius: 14,
                  spreadRadius: 1.5,
                  offset: const Offset(0, 2),
                  color: Colors.white.withOpacity(0.08),
                ),
              ],
            ),
            child: sw.DemoChipQr(
              data: 'demo:${widget.build.id}',
              size: 100,                  // or qrChipSize
              assetPath: 'assets/qr_designs/qr_design_5.png',
              assetScale: 1.2,
              qrScale: 0.50,              // ✅ matches final spacing
              darkColor: const Color(0xFFF5F5F5),
              lightColor: const Color(0xFF0F1115),
              showDemoSlash: true,
            ),
          ),
        ],
      ),
    );
  }

  // ——— Add Parts / View Build CTA (web demo: fire a callback if provided) ———
  bool _addDown = false;
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
    lowerBound: 0.0,
    upperBound: 1.0,
  )..repeat(reverse: true);

  Widget _buildAddPartsButton(BuildContext context) {
    final forge  = PcForgeTheme.forge;
    final accent = forge.accentPrimary;
    final isComplete = (widget.build.derivedStatus ?? '').toLowerCase() == 'completed';
    final String label = isComplete ? 'View Build' : 'Add Parts';
    final bool showIcon = !isComplete;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220, minHeight: 44),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onHighlightChanged: (v) => setState(() => _addDown = v),
            onTap: widget.onOpenAddParts, // no routing on web demo by default
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF0C0C0E), Color(0xFF17181B)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(_addDown ? 0.18 : 0.10),
                    blurRadius: _addDown ? 14 : 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: accent.withOpacity(_addDown ? 0.75 : 0.55),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showIcon)
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) {
                        final t = 0.6 + 0.4 * _pulse.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(blurRadius: 7 * t, color: accent.withOpacity(0.80 * t)),
                                  BoxShadow(blurRadius: 12 * t, color: accent.withOpacity(0.40 * t)),
                                ],
                              ),
                            ),
                            const Icon(Icons.add_circle_outline, size: 18, color: Colors.white),
                          ],
                        );
                      },
                    ),
                  if (showIcon) const SizedBox(width: 8),
                  _glowText(label, accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glowText(String text, Color accent) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.7,
          ).copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0
              ..color = accent,
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.7, color: Colors.white,
          ).copyWith(
            shadows: [
              Shadow(blurRadius: 20, color: accent.withOpacity(1.0), offset: const Offset(0, 0)),
              Shadow(blurRadius: 30, color: accent.withOpacity(0.45), offset: const Offset(0, 0)),
            ],
          ),
        ),
      ],
    );
  }

  // ——— Card shell (texture + edge/halo + status glow) ———
  BoxDecoration _buildCardDecoration(ForgeZone forge, {Color? glow}) {
    final Color edge = (glow == null || glow == Colors.transparent)
        ? Colors.white24
        : glow.withOpacity(0.55);

    final Color halo = (glow == null || glow == Colors.transparent)
        ? Colors.black.withOpacity(0.35)
        : glow.withOpacity(0.25);

    return BoxDecoration(
      color: forge.slab,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: edge, width: 1.6),
      boxShadow: [
        if (glow != null && glow != Colors.transparent)
          BoxShadow(color: glow.withOpacity(0.25), blurRadius: 12, spreadRadius: 0.5),
        BoxShadow(color: halo, blurRadius: 6, offset: const Offset(0, 3)),
      ],
      image: const DecorationImage(
        image: AssetImage("assets/plain_card_textures/texture_14.png"),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        colorFilter: ColorFilter.mode(Color(0x1FFFFFFF), BlendMode.softLight),
      ),
    );
  }

  // ——— Delete / Flip ———
  Widget _buildDeleteButton(BuildContext context) {
    const mutedRed = Color(0xFFDD6B6B);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => widget.onDelete?.call(widget.build),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF141518), Color(0xFF0F1114)],
            ),
            border: Border.all(color: mutedRed.withOpacity(0.55), width: 1.1),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: const Icon(Icons.delete_outline, size: 20, color: mutedRed),
        ),
      ),
    );
  }

  Widget _buildFlipButton(BuildContext context) {
    final accent = PcForgeTheme.forge.accentPrimary;
    return Tooltip(
      message: 'Flip Card',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => widget.onFlip?.call(),
        child: SizedBox(
          width: 38, height: 38,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF1A1C20), Color(0xFF101215)],
              ),
              boxShadow: [
                BoxShadow(color: accent.withOpacity(0.28), blurRadius: 8, spreadRadius: 0.5, offset: const Offset(0, 2)),
              ],
              border: Border.all(color: accent.withOpacity(0.65), width: 1.1),
            ),
            child: Icon(Icons.flip_camera_android_rounded, size: 18, color: accent),
          ),
        ),
      ),
    );
  }

  // ——— Status badge + style map (pillBg/pillStroke/glow) ———
  Map<String, Map<String, dynamic>> _statusStyles({required Color accent}) => {
    'in_progress': {
      'label': 'In Progress',
      'pillBg': const Color(0xFF30343A),
      'pillStroke': Colors.white70.withOpacity(0.25),
      'glow': Colors.transparent,
    },
    'forged': {
      'label': 'Forged',
      'pillBg': const Color(0xFFFFD54F),
      'pillStroke': const Color(0xFFFFE082),
      'glow': const Color(0xFFFFC85C),
    },
    'completed': {
      'label': 'Completed',
      'pillBg': accent,
      'pillStroke': accent,
      'glow': accent,
    },
    'sold': {
      'label': 'Sold',
      'pillBg': const Color(0xFFFF5252),
      'pillStroke': const Color(0xFFFF8A80),
      'glow': const Color(0xFFFF5252),
    },
    'imported': {
      'label': 'Imported',
      'pillBg': const Color(0xFFE0E0E0),
      'pillStroke': Colors.white,
      'glow': const Color(0xFFFFFFFF),
    },
    'pending': {
      'label': 'Pending',
      'pillBg': const Color(0xFF64B5F6),
      'pillStroke': const Color(0xFF90CAF9),
      'glow': const Color(0xFF64B5F6),
    },
    'unknown': {
      'label': 'Unknown',
      'pillBg': accent.withOpacity(0.6),
      'pillStroke': accent,
      'glow': accent.withOpacity(0.6),
    },
  };

  Map<String, dynamic> _statusStyle(String? raw, {Color? accent}) {
    final key = (raw ?? '').trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    final Color acc = accent ?? PcForgeTheme.forge.accentPrimary;
    final styles = _statusStyles(accent: acc);
    return styles[key] ?? styles['unknown']!;
  }

  Widget _buildStatusBadge(String? status) {
    final cfg = _statusStyle(status, accent: PcForgeTheme.forge.accentPrimary);
    final Color base   = (cfg['pillBg']     as Color?) ?? Colors.black45;
    final Color stroke = (cfg['pillStroke'] as Color?) ?? Colors.white24;
    final String label = (cfg['label']      as String?) ?? '—';

    return Positioned(
      left: 8,
      bottom: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [base.withOpacity(0.12), base.withOpacity(0.05)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: stroke.withOpacity(0.5), width: 0.8),
                boxShadow: [
                  BoxShadow(color: stroke.withOpacity(0.18), blurRadius: 4, offset: const Offset(0, 1)),
                ],
              ),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: const Alignment(0.2, 0.6),
                      colors: [Colors.white.withOpacity(0.14), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ——— Tier pills ———
  Widget _buildTierPillInlineNullable(int? tier) {
    if (tier == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            'Tier —',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white38, letterSpacing: 0.3),
          ),
        ),
      );
    }
    return _buildTierPillInline(tier);
  }

  Widget _buildTierPillInline(int tier) {
    final color = _tierColor(tier);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.lerp(Colors.black, color, 0.12)!.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.70), width: 1),
        boxShadow: [BoxShadow(color: color.withOpacity(0.22), blurRadius: 6, spreadRadius: 0.4)],
      ),
      child: Stack(children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text('',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.3)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            _tierLabel(tier),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.3),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: const Alignment(0.3, 0.7),
                  colors: [Colors.white.withOpacity(0.12), Colors.transparent],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  String _tierLabel(int t) {
    switch (t) {
      case 5: return 'Ultra';
      case 4: return 'Enthusiast';
      case 3: return 'Highend';
      case 2: return 'Midrange';
      case 1: return 'Budget';
      default: return 'Tier';
    }
  }

  Color _tierColor(int tier) {
    final f = PcForgeTheme.forge;
    switch (tier) {
      case 1: return f.tier1;
      case 2: return f.tier2;
      case 3: return f.tier3;
      case 4: return f.tier4;
      case 5: return f.tier5;
      default: return f.accentPrimary;
    }
  }
}

class _PlusOne extends StatelessWidget {
  const _PlusOne();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(8)),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text('+1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }
}
