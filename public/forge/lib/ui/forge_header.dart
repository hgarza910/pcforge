// lib/ui/forge_header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/forge_theme_shim.dart';

class ForgeHeader extends StatelessWidget {
  const ForgeHeader({
    super.key,
    this.accent,
    this.title = 'The Forge',
    this.titleSize,
  });

  final Color? accent;
  final String title;
  final double? titleSize;

  @override
  Widget build(BuildContext context) {
    final forge = PcForgeTheme.forge;
    final a = accent ?? forge.accentPrimary;
    final isPhone = MediaQuery.of(context).size.width < 640;

    final base = GoogleFonts.ibmPlexSans(
      fontSize: titleSize ?? (isPhone ? 32 : 40),
      fontWeight: FontWeight.w800,
      letterSpacing: 1.15,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPhone ? 16 : 20,
        vertical: isPhone ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
        border: Border.all(color: a.withOpacity(0.28), width: 1),
        boxShadow: [
          BoxShadow(color: a.withOpacity(0.20), blurRadius: 22, spreadRadius: 1),
          BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // stroke
            Text(
              title,
              textAlign: TextAlign.center,
              style: base.copyWith(
                foreground: (Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = (isPhone ? 1.2 : 1.6)
                  ..color = a),
              ),
            ),
            // fill + glow
            Text(
              title,
              textAlign: TextAlign.center,
              style: base.copyWith(
                color: Colors.white,
                shadows: [
                  Shadow(blurRadius: 26, color: a.withOpacity(1.0)),
                  Shadow(blurRadius: 40, color: a.withOpacity(0.55)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
