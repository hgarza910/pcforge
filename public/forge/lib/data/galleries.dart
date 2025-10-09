// lib/data/galleries.dart
// How to load per-card hero galleries from bundled asset images (Flutter web).
// 1) Put images under /assets/gallery/<CARD_ID>/image_01.jpg etc.
// 2) Add each file to pubspec.yaml under flutter.assets.
// 3) Use loadGalleries(fronts) to get List<List<Uint8List>> to pass to ForgeCardPreviewDeck.

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import '../models/forge_models.dart';

/// Explicit manifest of images per card. Flutter cannot list directories at runtime,
/// so you must keep this up to date (or generate during build).
final Map<String, List<String>> cardImageManifest = {
  // Example:
  // 'AB12CD': [
  //   'assets/gallery/AB12CD/cover.jpg',
  //   'assets/gallery/AB12CD/angle_1.jpg',
  //   'assets/gallery/AB12CD/angle_2.jpg',
  // ],
};

Future<List<List<Uint8List>>> loadGalleries(List<ForgeBuild> fronts) async {
  final galleries = <List<Uint8List>>[];
  for (final b in fronts) {
    final paths = cardImageManifest[b.id] ?? const <String>[];
    final bytesList = <Uint8List>[];
    for (final p in paths) {
      try {
        final bd = await rootBundle.load(p);
        bytesList.add(bd.buffer.asUint8List());
      } catch (_) {
        // Silently skip missing assets; keep the rest.
      }
    }
    galleries.add(bytesList);
  }
  return galleries;
}
