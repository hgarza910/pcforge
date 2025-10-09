// lib/ui/shared_widgets.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/forge_theme_shim.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// ------------------------------
/// Warranty badge
/// ------------------------------
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


/// ------------------------------
/// Soft radial plate used behind QR
/// ------------------------------
class SoftRadialPlate extends StatelessWidget {
  const SoftRadialPlate({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SoftRadialPlatePainter(),
      isComplex: true,
    );
  }
}

class _SoftRadialPlatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final gradient = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.14),
        Colors.white.withOpacity(0.06),
        Colors.transparent,
      ],
      stops: const [0.0, 0.55, 1.0],
    );
    final rect = Rect.fromCircle(center: center, radius: r);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(center, r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ------------------------------
/// Etched price window
/// ------------------------------
class EtchedPriceWindow extends StatelessWidget {
  const EtchedPriceWindow({
    super.key,
    required this.priceText,
    required this.accent,
    this.textStyle,
  });

  final String priceText;
  final Color accent;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withOpacity(0.45), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 8),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.10), Colors.transparent],
        ),
      ),
      child: Text(
        priceText,
        style: (textStyle ??
            Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ))!,
      ),
    );
  }
}

/// ------------------------------
/// QrDock: little plate that holds a QR child
/// ------------------------------
class QrDock extends StatelessWidget {
  const QrDock({
    super.key,
    required this.child,
    required this.accent,
    this.paddingScale = 0.3,
  });

  final Widget child;
  final Color accent;
  final double paddingScale;

  @override
  Widget build(BuildContext context) {
    final pad = (paddingScale.clamp(0.0, 1.0)) * 16.0 + 4.0;
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withOpacity(0.45), width: 1),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 10,
            spreadRadius: 0.5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// ------------------------------
/// ChipQr: lightweight, dependency-free “QR-ish” visual
/// (stub: looks good in previews; swap with real QR later if needed)
/// ------------------------------


class DemoChipQr extends StatelessWidget {
  const DemoChipQr({
    super.key,
    required this.data,
    required this.size,
    this.darkColor = const Color(0xFF0F1115),
    this.lightColor = const Color(0xFFF5F5F5),
    this.cornerRadius = 10,
    this.finderSize = 5,
    this.fillDensity = 0.25,
    this.strokeBorder = true,
    this.showDemoSlash = false,
    this.assetPath = 'assets/qr_designs/qr_design_5.png',
    this.assetScale = 1.0,
    this.qrScale = 1.0,
  });

  final String data;
  final double size;
  final Color darkColor;
  final Color lightColor;
  final double cornerRadius;
  final int finderSize;
  final double fillDensity;
  final bool strokeBorder;
  final bool showDemoSlash;

  // background frame
  final String? assetPath;
  final double assetScale;
  final double qrScale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: LayoutBuilder(
        builder: (_, c) {
          final side = math.min(c.maxWidth, c.maxHeight);
          final frameSide = side * assetScale;
          final hasAsset = assetPath != null;

          // how big the QR core should be (inside the frame)
          final qrSide = (side * qrScale).clamp(0.0, side);

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (hasAsset)
                SizedBox(
                  width: frameSide,
                  height: frameSide,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(frameSide * 0.06),
                    child: Image.asset(
                      assetPath!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),

              // >>> REAL QR CORE <<< (replaces the fake painter)
              SizedBox(
                width: qrSide,
                height: qrSide,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cornerRadius * 0.6),
                  child: QrImageView(
                    data: data,
                    size: qrSide,
                    backgroundColor: lightColor,
                    foregroundColor: darkColor,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                    gapless: true,
                    padding: EdgeInsets.zero,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: darkColor,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                    ),
                  ),
                ),
              ),

              // Optional thin border around the whole chip when no asset
              if (strokeBorder && !hasAsset)
                IgnorePointer(
                  child: Container(
                    width: side,
                    height: side,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(cornerRadius),
                      border: Border.all(color: Colors.black12, width: 1),
                    ),
                  ),
                ),

              if (showDemoSlash)
                IgnorePointer(
                  child: CustomPaint(
                    size: Size.square(side),
                    painter: _SlashPainter(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DemoChipQrPainter extends CustomPainter {
  _DemoChipQrPainter({
    required this.darkColor,
    required this.lightColor,
    required this.seed,
    required this.cornerRadius,
    required this.finderSize,
    required this.fillDensity,
    required this.strokeBorder,
    required this.showDemoSlash,
    required this.paintBackground,
    required this.qrScale,
  });

  final Color darkColor;
  final Color lightColor;
  final int seed;
  final double cornerRadius;
  final int finderSize;
  final double fillDensity;
  final bool strokeBorder;
  final bool showDemoSlash;
  final bool paintBackground;
  final double qrScale;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius));
    canvas.clipRRect(rrect);

    if (paintBackground) {
      canvas.drawRRect(rrect, Paint()..color = lightColor);
    }

    // inner rect based on qrScale
    final double inset = (1.0 - qrScale).clamp(0.0, 1.0) * size.width * 0.5;
    final Rect gridRect = rect.deflate(inset);

    const int cells = 21;
    final double cell = gridRect.width / cells;
    final Offset origin = gridRect.topLeft;

    int h = seed ^ 0x9E3779B9;
    bool nextOn() {
      h = (h * 1664525 + 1013904223) & 0x7fffffff;
      return (h & 0x7fffffff) < (0x7fffffff * fillDensity);
    }

    final fg = Paint()..color = darkColor;

    for (int y = 0; y < cells; y++) {
      for (int x = 0; x < cells; x++) {
        final bool isFinder =
            (x < finderSize && y < finderSize) ||
                (x >= cells - finderSize && y < finderSize) ||
                (x < finderSize && y >= cells - finderSize);

        if (isFinder || nextOn()) {
          canvas.drawRect(
            Rect.fromLTWH(
              origin.dx + x * cell,
              origin.dy + y * cell,
              cell,
              cell,
            ),
            fg,
          );
        }
      }
    }

    // finder inner squares
    final finderPaint = Paint()..color = lightColor;
    void finderAt(int ox, int oy) {
      final Rect outer = Rect.fromLTWH(
        origin.dx + ox * cell,
        origin.dy + oy * cell,
        finderSize * cell,
        finderSize * cell,
      );
      final double pad = cell;
      final Rect inner = outer.deflate(pad);
      canvas.drawRect(inner, finderPaint);
      canvas.drawRect(inner.deflate(pad * 0.6), fg);
    }
    finderAt(0, 0);
    finderAt(cells - finderSize, 0);
    finderAt(0, cells - finderSize);

    if (strokeBorder) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.black12,
      );
    }

    if (showDemoSlash) {
      canvas.drawLine(
        rect.topLeft,
        rect.bottomRight,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * 0.04
          ..strokeCap = StrokeCap.square
          ..color = Colors.black.withOpacity(0.08),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DemoChipQrPainter o) =>
      o.darkColor != darkColor ||
          o.lightColor != lightColor ||
          o.seed != seed ||
          o.cornerRadius != cornerRadius ||
          o.finderSize != finderSize ||
          o.fillDensity != fillDensity ||
          o.strokeBorder != strokeBorder ||
          o.showDemoSlash != showDemoSlash ||
          o.paintBackground != paintBackground ||
          o.qrScale != qrScale; // 👈 include this
}

// tiny painter just for the optional demo slash overlay
class _SlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset.zero,
      Offset(size.width, size.height),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.04
        ..strokeCap = StrokeCap.square
        ..color = Colors.black.withOpacity(0.08),
    );
  }
  @override
  bool shouldRepaint(covariant _SlashPainter oldDelegate) => false;
}
