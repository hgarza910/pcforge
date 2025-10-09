// lib/main.dart
//flutter build web --release --base-href=/forge/
import 'package:flutter/material.dart';
import 'ui/forge_card_flip.dart';
import 'models/forge_models.dart';
import 'theme/forge_theme_shim.dart';
import 'dart:typed_data';
import 'ui/forge_header.dart';
import 'ui/forge_carousel.dart';
import 'dart:ui' show ImageFilter;

void main() {
  runApp(const ForgeCardWebDemo());
}

class ForgeCardWebDemo extends StatelessWidget {
  const ForgeCardWebDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: const ColorScheme.dark(),
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: PcForgeTheme.forge.slab,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.black, foregroundColor: Colors.white70),
    );


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Forge Card Web Demo',
      theme: theme,
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // —— Replace these with YOUR builds ——
    final fronts = <ForgeBuild>[
      const ForgeBuild(
        id: 'AB12CD',
        name: 'Neo-Forge Scout',
        tier: 3,
        derivedEmberScore: 7,
        derivedStatus: 'in_progress',
        livePrice: 1899.99,
        trio: ['Ryzen 7 7800X3D', 'RTX 4080', 'Phanteks NV7'],
      ),
      const ForgeBuild(
        id: 'EF56GH',
        name: 'Carbon Widow',
        tier: 4,
        derivedEmberScore: 11,
        derivedStatus: 'forged',
        livePrice: 2599.00,
        trio: ['i7-13700K', 'RTX 4090', 'Lian Li O11D'],
      ),
      const ForgeBuild(
        id: 'ZX90YU',
        name: 'Atlas Micro',
        tier: 2,
        derivedEmberScore: 5,
        derivedStatus: 'completed',
        livePrice: 1199.50,
        trio: ['Ryzen 5 7600', 'RX 7700 XT', 'NR200P'],
      ),
      const ForgeBuild(
        id: 'QW34ER',
        name: 'Ghost Rail',
        tier: 5,
        derivedEmberScore: 14,
        derivedStatus: 'sold',
        livePrice: 3299.99,
        trio: ['i9-14900K', 'RTX 4090', 'Fractal North'],
      ),
    ];

    final backs = <ForgeBuildBackData>[
      const ForgeBuildBackData(
        cpu: 'Ryzen 7 7800X3D • 8 cores • 5.0 GHz',
        gpu: 'RTX 4080 • 16 GB • 2505 MHz boost',
        motherboard: 'X670E Aorus Master (ATX)',
        caseName: 'Phanteks NV7',
        ram: '32 GB (2×16) • 6000 MHz',
        storage1: '1 TB NVMe (Gen4)',
        storage2: '2 TB NVMe (Gen4)',
        psuModel: 'Corsair RM850x',
        psuWatt: '850W',
        psuRating: '80+ Gold',
        coolerType: 'AIO',
        coolerSize: '360mm',
        metrics: {'idle_w': '65', 'peak_w': '420', 'timespy': '18200', 'cb23_multi': '28000'},
        tags: ['sleek', 'orange glow', 'glass'],
        warrantyStatus: 'Covered',
        warrantyExpires: 'Jun 2026',
        ownerName: 'Forge Demo',
        buildAgeLabel: '4 mo',
        upgradePotential: 'High',
        upgradeNote: 'Thermal headroom; add a Gen5 drive later.',
      ),
      const ForgeBuildBackData(
        cpu: 'Core i7-13700K • 16 cores • 5.4 GHz',
        gpu: 'RTX 4090 • 24 GB • 2520 MHz boost',
        motherboard: 'Z790 Hero (ATX)',
        caseName: 'Lian Li O11D',
        ram: '64 GB (2×32) • 6000 MHz',
        storage1: '2 TB NVMe (Gen4)',
        psuModel: 'Seasonic Prime',
        psuWatt: '1000W',
        psuRating: '80+ Platinum',
        coolerType: 'AIO',
        coolerSize: '360mm',
        metrics: {'idle_w': '80', 'peak_w': '520', 'timespy': '23500'},
        tags: ['white build', 'halo GPU'],
        warrantyStatus: 'Covered',
        warrantyExpires: 'Jan 2027',
        ownerName: 'Forge Demo',
        buildAgeLabel: '2 mo',
        upgradePotential: 'Medium',
        upgradeNote: 'GPU already top-tier; consider faster RAM timing.',
      ),
      const ForgeBuildBackData(
        cpu: 'Ryzen 5 7600 • 6 cores • 5.1 GHz',
        gpu: 'Radeon RX 7700 XT • 12 GB',
        motherboard: 'B650I ITX',
        caseName: 'Cooler Master NR200P',
        ram: '32 GB (2×16) • 6000 MHz',
        storage1: '1 TB NVMe (Gen4)',
        psuModel: 'Corsair SF750',
        psuWatt: '750W',
        psuRating: '80+ Platinum',
        coolerType: 'Air',
        coolerSize: '120mm tower',
        metrics: {'idle_w': '42', 'peak_w': '320', 'timespy': '12500'},
        tags: ['SFF', 'quiet'],
        warrantyStatus: 'Covered',
        warrantyExpires: 'Oct 2026',
        ownerName: 'Forge Demo',
        buildAgeLabel: '7 mo',
        upgradePotential: 'High',
        upgradeNote: 'Room for GPU upgrade to 7900 GRE/4080.',
      ),
      const ForgeBuildBackData(
        cpu: 'Core i9-14900K • 24 cores • 6.0 GHz',
        gpu: 'RTX 4090 • 24 GB • 2520 MHz boost',
        motherboard: 'Z790 Aorus Elite',
        caseName: 'Fractal North',
        ram: '64 GB (2×32) • 6400 MHz',
        storage1: '2 TB NVMe (Gen4)',
        storage2: '4 TB NVMe (Gen4)',
        psuModel: 'Corsair HX1200',
        psuWatt: '1200W',
        psuRating: '80+ Platinum',
        coolerType: 'AIO',
        coolerSize: '420mm',
        metrics: {'idle_w': '95', 'peak_w': '650', 'timespy': '24000'},
        tags: ['premium', 'wood/mesh'],
        warrantyStatus: 'Covered',
        warrantyExpires: 'Dec 2027',
        ownerName: 'Forge Demo',
        buildAgeLabel: '1 mo',
        upgradePotential: 'Low',
        upgradeNote: 'Already maxed; focus on acoustics.',
      ),
    ];

    // No images by default for the hero; you can provide List<Uint8List> per card.
    final heroImages = <List<Uint8List>>[];


// lib/main.dart (inside DemoScreen.build)


    final size = MediaQuery.of(context).size;
    final w = size.width;
    final isPhone = w < 600;
    final edgePad = isPhone ? 12.0 : 16.0;
    final topContentPad = isPhone ? 84.0 : 96.0;
    final laneMaxWidth = isPhone ? 520.0 : 920.0;

// inside build(...) where the page Stack is
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1) Background image
          Image.asset(
            'assets/backgrounds/background_1.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
          ),

          // 2) Global blur + darken overlay
          // (BackdropFilter blurs whatever is behind it)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5), // tweak 2.0–3.5 to taste
              child: Container(
                color: const Color(0xFF0B0D10).withOpacity(0.30), // subtle darken
              ),
            ),
          ),

          // 3) Top vignette to make the header pop
          Positioned(
            top: 0, left: 0, right: 0,
            child: IgnorePointer(
              child: Container(
                height: 160, // extend if you want a deeper fade
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xCC000000), Color(0x00000000)],
                    stops: [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 4) Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: const ForgeHeader(), // uses bigger defaults above
            ),
          ),

          // 5) Foreground content
          SafeArea(
            top: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(edgePad, topContentPad, edgePad, edgePad),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: laneMaxWidth),
                  child: ForgeCarousel(
                    fronts: fronts,
                    backs: backs,
                    images: heroImages,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}
