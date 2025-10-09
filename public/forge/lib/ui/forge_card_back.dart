// lib/ui/forge_card_back.dart (Back)
import 'package:flutter/material.dart';

import '../theme/forge_theme_shim.dart';
import '../models/forge_models.dart';
import 'shared_widgets.dart' as sw; // 👈 alias shared widgets

class BackForgedCardWeb extends StatelessWidget {
  const BackForgedCardWeb({
    super.key,
    required this.frontBuild,
    required this.back,
    required this.onFlip,
  });

  final ForgeBuild frontBuild;
  final ForgeBuildBackData back;
  final VoidCallback onFlip;

  // tolerant dash helper
  String _dash(Object? v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty) ? '—' : s;
  }

  @override
  Widget build(BuildContext context) {
    final forge = PcForgeTheme.forge;
// inside build(...)
    return Container(
      width: 300,
      height: 450,
      decoration: BoxDecoration(
        color: forge.slab,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: forge.accentPrimary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: forge.accentPrimary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Stack(
        children: [
          // Fill the card; just keep a little breathing room
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8), // was a fixed 275 box; now full width
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildBody(context, forge),
              ),
            ),
          ),
          Positioned(bottom: 8, right: 8, child: _flipBtn(forge, onTap: onFlip)),
        ],
      ),
    );

  }

  Widget _flipBtn(ForgeZone forge, {required VoidCallback onTap}) => Tooltip(
    message: 'Flip Card',
    child: InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.4),
          border: Border.all(color: forge.accentPrimary.withOpacity(0.6), width: 1.5),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1C20), Color(0xFF101215)],
          ),
        ),
        child: Icon(Icons.flip_camera_android_rounded, size: 18, color: forge.accentPrimary),
      ),
    ),
  );

  Widget _buildBody(BuildContext context, ForgeZone forge) {
    final idle = _dash(back.metrics['idle_w']);
    final peak = _dash(back.metrics['peak_w']);
    final ts = _dash(back.metrics['timespy']);
    final cb23 = _dash(back.metrics['cb23_multi']);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16181B), Color(0xFF101215)],
        ),
        border: Border.all(color: Colors.white10, width: 0.6),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                frontBuild.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),

          _section(
            title: 'Core Components',
            forge: forge,
            icon: Icons.memory_outlined,
            child: _coreComponentsGrid(forge),
          ),


          _section(
            title: 'Memory & Storage',
            forge: forge,
            icon: Icons.storage_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv('RAM', back.ram),
                _kv('Drive #1', back.storage1),
                if (_dash(back.storage2) != '—') _kv('Drive #2', back.storage2!),
              ],
            ),
          ),

          _section(
            title: 'Power Supply',
            forge: forge,
            icon: Icons.power_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv('Model', back.psuModel),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _pill('Wattage', _dash(back.psuWatt)),
                    if (_dash(back.psuRating) != '—') _pill('Rating', _dash(back.psuRating)),
                  ],
                ),
              ],
            ),
          ),

          _section(
            title: 'Cooling',
            forge: forge,
            icon: Icons.ac_unit_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv('Type', back.coolerType),
                if (_dash(back.coolerSize) != '—')
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    _pill('Size', _dash(back.coolerSize)),
                  ]),
              ],
            ),
          ),

          _section(
            title: 'Power Draw',
            forge: forge,
            icon: Icons.bolt_outlined,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (idle != '—') _pill('Idle', idle),
                if (peak != '—') _pill('Peak', peak),
              ],
            ),
          ),

          _accentStrip(
            forge: forge,
            title: 'Performance',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ts != '—') _kv('3DMark Time Spy', ts),
                if (cb23 != '—') _kv('Cinebench R23 Multi', cb23),
              ],
            ),
          ),

          _splitRow(
            left: _section(
              title: 'Warranty',
              forge: forge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('Coverage', _dash(back.warrantyStatus)),
                  _kv('Expires', _dash(back.warrantyExpires)),
                ],
              ),
            ),
            right: _section(
              title: 'Build Age',
              forge: forge,
              child: _kv('Age', _dash(back.buildAgeLabel)),
            ),
          ),

          _section(
            title: 'Upgrade Potential',
            forge: forge,
            icon: Icons.trending_up_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_dash(back.upgradePotential) != '—')
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    _pill('Overall', _dash(back.upgradePotential)),
                  ]),
                if (_dash(back.upgradeNote) != '—') ...[
                  const SizedBox(height: 6),
                  Text(_dash(back.upgradeNote), style: _sub(forge)),
                ],
              ],
            ),
          ),

          if (back.tags.isNotEmpty)
            _angledPlate(
              forge: forge,
              title: 'Vibe Tags',
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final t in back.tags) _chip(t, forge)],
              ),
            ),

          const SizedBox(height: 8),
          _footerRow(forge),
        ],
      ),
    );
  }

  Widget _coreComponentsGrid(ForgeZone forge) {
    // CPU, GPU, Motherboard, Case in a tidy 2-column responsive grid
    final items = <Widget>[
      _kvWithMeta('CPU', _dash(back.cpu)),
      _kvWithMeta('GPU', _dash(back.gpu)),
      _kvWithMeta('Motherboard', _dash(back.motherboard)),
      _kvWithMeta('Case', _dash(back.caseName)),
    ];


    return LayoutBuilder(
      builder: (context, c) {
        // two columns if space allows, otherwise stack
        final isTwoCol = c.maxWidth >= 420; // ~two 200px tiles side-by-side
        if (!isTwoCol) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((w) => Padding(padding: const EdgeInsets.only(bottom: 8), child: w))
                .toList(),
          );
        }
        return Wrap(
          spacing: 10,
          runSpacing: 8,
          children: items
              .map((w) => ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 180),
            child: w,
          ))
              .toList(),
        );
      },
    );
  }

  // Split "Model • meta1 • meta2" into (model, "meta1 · meta2")
  ({String model, String meta}) _splitModelMeta(String raw) {
    final parts = raw.split('•').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return (model: raw, meta: '');
    final model = parts.first;
    final meta  = parts.length > 1 ? parts.skip(1).join(' · ') : '';
    return (model: model, meta: meta);
  }

// Compact tile: title + small meta on the first row, model on the second row
  Widget _kvWithMeta(String label, String value) {
    final rec = _splitModelMeta(value);
    final cap = _cap(); // you already have _cap()
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: cap),
            if (rec.meta.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                '· ${rec.meta}',
                style: cap.copyWith(
                  fontSize: cap.fontSize,         // keep small
                  color: Colors.white54,          // slightly muted
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          rec.model,
          style: _val(),                         // your existing value style
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }


  Widget _kvTight(String k, String v) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(k, style: _cap()),              // you already have _cap()
      const SizedBox(height: 2),
      Text(v, style: _val(), maxLines: 1, overflow: TextOverflow.ellipsis), // you already have _val()
    ],
  );


  // === UI helpers ===
  Widget _section({
    required String title,
    required ForgeZone forge,
    required Widget child,
    IconData icon = Icons.memory_outlined,
  }) =>
      Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24.withOpacity(0.12), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 12, color: forge.accentPrimary.withOpacity(0.9)),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white70)),
            ]),
            const SizedBox(height: 6),
            child,
          ],
        ),
      );

  Widget _accentStrip({
    required ForgeZone forge,
    required String title,
    required Widget child,
  }) =>
      Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [forge.accentPrimary.withOpacity(0.08), Colors.transparent],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: forge.accentPrimary.withOpacity(0.25), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.speed_rounded, size: 12, color: forge.accentPrimary.withOpacity(0.95)),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white70)),
            ]),
            const SizedBox(height: 6),
            child,
          ],
        ),
      );

  Widget _angledPlate({
    required ForgeZone forge,
    required String title,
    required Widget child,
  }) =>
      Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1113),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.sell_outlined, size: 12, color: forge.accentPrimary.withOpacity(0.9)),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white70)),
            ]),
            const SizedBox(height: 6),
            child,
          ],
        ),
      );

  Widget _footerRow(ForgeZone forge) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.32),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _warrantyShield(),
              const SizedBox(height: 6),
              Text('Owner', style: _cap()),
              const SizedBox(height: 2),
              Text(_dash(back.ownerName), style: _val()),
            ]),
          ),
          // Use alias, and no const (they aren’t const-constructible)
          sw.QrDock(
            accent: Colors.white70,
            child: const sw.DemoChipQr(
              data: 'demo:back', // fixed seed; stays const-safe
              size: 72,
              assetPath: 'assets/qr_designs/qr_design_5.png',
              assetScale: 0.96,                  // tweak to show more of the frame
              darkColor: Color(0xFF0F1115),
              lightColor: Color(0xFFF5F5F5),
              showDemoSlash: true,
            ),

          ),
        ],
      ),
    );
  }

  Widget _warrantyShield() {
    final s = _dash(back.warrantyStatus).toLowerCase();
    Color c;
    if (s.contains('expir')) {
      c = const Color(0xFFFFC107);
    } else if (s.contains('expired')) {
      c = const Color(0xFFE53935);
    } else if (s.contains('cover')) {
      c = const Color(0xFF43A047);
    } else {
      c = Colors.white24;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.6)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.shield_outlined, size: 12, color: c),
        const SizedBox(width: 6),
        Text(_dash(back.warrantyStatus), style: TextStyle(fontSize: 11, color: c)),
      ]),
    );
  }

  // small typographic helpers
  TextStyle _cap() => const TextStyle(
    fontSize: 10.5,
    color: Colors.white60,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w600,
  );

  TextStyle _val() => const TextStyle(
    fontSize: 12.5,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  TextStyle _sub(ForgeZone forge) => TextStyle(
    fontSize: 11,
    color: Colors.white.withOpacity(0.75),
  );

  Widget _twoLine(String category, String model) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          model,
          style: _val(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );

  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: _cap()),
        const SizedBox(height: 2),
        Text(v, style: _val()),
      ],
    ),
  );

  Widget _pill(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.45),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white24.withOpacity(0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Widget _chip(String t, ForgeZone forge) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.35),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: forge.accentPrimary.withOpacity(0.35)),
    ),
    child: Text(
      t,
      style: const TextStyle(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.w700),
    ),
  );

  Widget _splitRow({required Widget left, required Widget right}) =>
      Row(children: [Expanded(child: left), const SizedBox(width: 10), Expanded(child: right)]);
}
