// lib/theme/forge_theme_shim.dart
// Minimal theme shim to make the web preview work standalone.
import 'package:flutter/material.dart';

class ForgeZone {
  const ForgeZone({
    required this.slab,
    required this.accentPrimary,
    required this.textPrimary,
    required this.textMuted,
    this.tier1 = const Color(0xFF84D87A),
    this.tier2 = const Color(0xFF5BC0EB),
    this.tier3 = const Color(0xFFFFC857),
    this.tier4 = const Color(0xFFFF6F59),
    this.tier5 = const Color(0xFFB388EB),
  });
  final Color slab;
  final Color accentPrimary;
  final Color textPrimary;
  final Color textMuted;
  final Color tier1, tier2, tier3, tier4, tier5;
}

class PcForgeTheme {
  static final forge = ForgeZone(
    slab: const Color(0xFF13161A),
    accentPrimary: const Color(0xFFFF6A00),
    textPrimary: Colors.white,
    textMuted: Colors.white70,
  );
  static const soot = Color(0xFF0A0D10);
  static const textPrimary = Colors.white;
}
