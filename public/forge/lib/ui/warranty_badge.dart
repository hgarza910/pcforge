import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

enum WarrantyStatus { covered, expiringSoon, expired, notUploaded }
enum WarrantyBadgeTextMode { fraction, percent, none }

class WarrantyBadge extends StatelessWidget {
  final int? coveredParts;         // 0..8 (null = legacy mode)
  final int totalParts;            // defaults to 8
  final WarrantyBadgeTextMode textMode;

  final WarrantyStatus status;     // legacy
  final String? label;             // legacy text / none mode

  /// NEW: scale the whole badge (ring + shield + icon + label).
  /// 1.0 = current size. Try 0.9 or 0.85 for “a few ticks smaller”.
  final double scale;

  const WarrantyBadge({
    super.key,
    this.coveredParts,
    this.totalParts = 8,
    this.textMode = WarrantyBadgeTextMode.fraction,
    this.label,
    this.status = WarrantyStatus.notUploaded,
    this.scale = 0.9, // ← default slightly smaller than before
  });

  // ---------------- Coverage helpers ----------------
  double get _pct =>
      (coveredParts == null || totalParts <= 0)
          ? 0
          : (coveredParts!.clamp(0, totalParts) / totalParts);

  Color get _coverageColor {
    final p = _pct * 100;
    if (p >= 100) return const Color(0xFF00FFA3); // green
    if (p >= 50)  return const Color(0xFFFFC85C); // flame blue
    if (p > 0)    return const Color(0xFFFF5252); // ember/orange
    return const Color(0xFF707983);               // graphite
  }

  String get _coverageText {
    switch (textMode) {
      case WarrantyBadgeTextMode.fraction:
        return '${coveredParts ?? 0}/$totalParts';
      case WarrantyBadgeTextMode.percent:
        final p = (_pct * 100).round();
        return '$p%';
      case WarrantyBadgeTextMode.none:
        return label ?? '';
    }
  }

  // ---------------- Legacy helpers ----------------
  Color get _legacyColor {
    switch (status) {
      case WarrantyStatus.covered:      return const Color(0xFF3CFB95);
      case WarrantyStatus.expiringSoon: return const Color(0xFFFFB300);
      case WarrantyStatus.expired:      return const Color(0xFFFF5252);
      case WarrantyStatus.notUploaded:  return const Color(0xFFB0BEC5);
    }
  }

  IconData get _legacyIcon {
    switch (status) {
      case WarrantyStatus.covered:      return FontAwesomeIcons.shieldHalved;
      case WarrantyStatus.expiringSoon: return FontAwesomeIcons.hourglassHalf;
      case WarrantyStatus.expired:      return FontAwesomeIcons.triangleExclamation;
      case WarrantyStatus.notUploaded:  return FontAwesomeIcons.fileCircleQuestion;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCoverage = coveredParts != null;
    final Color color = isCoverage ? _coverageColor : _legacyColor;
    final IconData icon = isCoverage ? FontAwesomeIcons.shieldHalved : _legacyIcon;

    // single source of truth
    final double ring    = 36 * scale;   // widget box + ring diameter
    final double shieldW = ring * 0.72;
    final double shieldH = ring * 0.86;
    final double iconSz  = ring * 0.38;

    // optical tweak: push ONLY the shield down a bit (2–4 px @ 36dp)
    final double shieldDown = ring * 0.12; // try 0.06..0.12 to taste

    return SizedBox(
      width: ring,
      height: ring,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isCoverage)
            SizedBox(
              width: ring,
              height: ring,
              child: CustomPaint(
                painter: _RingPainter(progress: _pct, color: color),
              ),
            ),

          // ↓ move the green shield background down
          Transform.translate(
            offset: Offset(0, shieldDown),
            child: SizedBox(
              width: shieldW,
              height: shieldH,
              child: CustomPaint(painter: ShieldPainter(color)),
            ),
          ),

          // black glyph stays perfectly centered
          Icon(icon, size: iconSz, color: Colors.black),
        ],
      ),
    );
  }

}

class ShieldPainter extends CustomPainter {
  final Color color;
  ShieldPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.95);

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width * 0.9, size.height * 0.28)
      ..quadraticBezierTo(
        size.width / 2,
        size.height * 1.02,
        size.width * 0.1,
        size.height * 0.28,
      )
      ..close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.35), 3, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ShieldPainter old) => color != old.color;
}

class _RingPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final double strokeBg;
  final double strokeFg;
  _RingPainter({
    required this.progress,
    required this.color,
    this.strokeBg = 2.0,
    this.strokeFg = 2.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double r = (size.shortestSide / 2) - (strokeFg / 2);
    final Offset c = Offset(size.width / 2, size.height / 2);
    final Rect arcRect = Rect.fromCircle(center: c, radius: r);

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeBg
      ..color = Colors.black.withOpacity(0.25)
      ..isAntiAlias = true;

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeFg
      ..color = color
      ..isAntiAlias = true;

    canvas.drawArc(arcRect, -math.pi / 2, 2 * math.pi, false, bg);

    final sweep = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    if (sweep > 0) {
      canvas.drawArc(arcRect, -math.pi / 2, sweep, false, fg);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      progress != old.progress || color != old.color || strokeBg != old.strokeBg || strokeFg != old.strokeFg;
}
