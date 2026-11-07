import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/score.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/tab_header.dart';
import '../../data/location/location_service.dart';
import '../../data/providers.dart';
import '../../data/repositories/models.dart';
import '../../l10n/app_localizations.dart';
import 'store_form_sheet.dart';

class StoresScreen extends ConsumerWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final stores = ref.watch(storeSummariesProvider).value ?? const <StoreSummary>[];
    final position = ref.watch(currentPositionProvider).value;
    final suggestions = ref.watch(nearbySuggestionsProvider).value ?? const <NearbySuggestion>[];

    double? distanceOf(StoreSummary s) => s.nearest(position?.distanceTo)?.$2;
    final sorted = [for (final s in stores) (s, distanceOf(s))]
      ..sort((a, b) => (a.$2 ?? double.infinity).compareTo(b.$2 ?? double.infinity));

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentPositionProvider);
          await ref.read(nearbySuggestionsProvider.future);
        },
        child: ListView(
          // Die Liste läuft unter der Navigation durch; unten Platz dafür lassen.
          padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.paddingOf(context).bottom),
          children: [
            TabHeader(
              title: l10n.storesTitle,
              action: SquareIconButton(
                icon: Icons.add_rounded,
                tooltip: l10n.storesAdd,
                background: AppColors.ink,
                foreground: AppColors.lime,
                bordered: false,
                onPressed: () => showStoreForm(context, latitude: position?.latitude, longitude: position?.longitude),
              ),
            ),
            const SizedBox(height: 16),
            _StoreMap(
              position: position,
              stores: stores,
              youAreHere: l10n.storesYouAreHere,
              locationOff: l10n.storesLocationOff,
            ),
            const SizedBox(height: 18),
            SectionHeader(
              position == null ? l10n.storesAll : l10n.storesNearby,
              trailing: position == null ? null : l10n.storesByDistance,
            ),
            const SizedBox(height: 10),
            if (stores.isEmpty)
              AppCard(
                child: Text(l10n.storesEmpty, style: AppText.body(14, color: AppColors.muted).copyWith(height: 1.45)),
              )
            else
              for (final (summary, distance) in sorted) ...[
                _StoreCard(
                  summary: summary,
                  distance: distance == null ? null : formatDistance(distance, locale),
                  onTap: () => context.push('/store/${summary.store.id}'),
                ),
                const SizedBox(height: 10),
              ],
            for (final suggestion in suggestions) ...[
              _SuggestionCard(
                suggestion: suggestion,
                distance: formatDistance(suggestion.distance, locale),
                onAdd: () async {
                  final chain = suggestion.chain;
                  if (chain == null) {
                    await showStoreForm(
                      context,
                      initialName: suggestion.shop.name,
                      initialAddress: suggestion.shop.address,
                      latitude: suggestion.shop.latitude,
                      longitude: suggestion.shop.longitude,
                    );
                    return;
                  }
                  // Bekannte Kette: einfach als weitere Filiale speichern.
                  await ref
                      .read(storeRepositoryProvider)
                      .addLocation(
                        chain.id,
                        latitude: suggestion.shop.latitude,
                        longitude: suggestion.shop.longitude,
                        address: suggestion.shop.address,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(l10n.storeBranchAdded(chain.name))));
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
            if (suggestions.isNotEmpty)
              Text(
                l10n.storesMapAttribution,
                textAlign: TextAlign.center,
                style: AppText.body(12, color: AppColors.muted),
              ),
          ],
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.summary, required this.distance, required this.onTap});

  final StoreSummary summary;
  final String? distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final top = summary.top;
    final meta = [
      distance,
      if (summary.locations.length > 1) l10n.storeBranchCount(summary.locations.length),
      l10n.storesRatedCount(summary.ratedCount),
    ].whereType<String>().join(' · ');

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderSoft),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.storefront_outlined, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.store.name, style: AppText.body(16, weight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(meta, style: AppText.body(13, color: AppColors.muted)),
                    if (top != null && top.score != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        l10n.storesTop('${Score.emoji(top.score!)} ${top.product.name} · ${top.score}'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(13, color: AppColors.inkSoft),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8A948C)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion, required this.distance, required this.onAdd});

  final NearbySuggestion suggestion;
  final String distance;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC3CABB), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (suggestion.chain == null
                          ? l10n.storesSuggestion
                          : l10n.storesSuggestionBranch(suggestion.chain!.name))
                      .toUpperCase(),
                  style: AppText.overline().copyWith(fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  [suggestion.shop.address ?? suggestion.shop.name, distance].join(' · '),
                  style: AppText.body(15, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.lime,
              foregroundColor: AppColors.ink,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: AppText.body(14, weight: FontWeight.w700),
            ),
            onPressed: onAdd,
            child: Text(l10n.storesAddAction),
          ),
        ],
      ),
    );
  }
}

/// Schematische Karte: deine Position in der Mitte, Läden relativ dazu,
/// Pins mit der Zahl bewerteter Produkte. Kommt ohne Kartenkacheln aus.
class _StoreMap extends StatelessWidget {
  const _StoreMap({required this.position, required this.stores, required this.youAreHere, required this.locationOff});

  final LatLon? position;
  final List<StoreSummary> stores;
  final String youAreHere;
  final String locationOff;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 176,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final pins = _project(size);
            return Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _MapBackgroundPainter())),
                if (position != null)
                  Positioned(
                    left: size.width / 2 - 9,
                    top: size.height / 2 - 9,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.locationBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [BoxShadow(color: AppColors.locationBlue.withValues(alpha: 0.18), spreadRadius: 8)],
                      ),
                    ),
                  ),
                for (final (offset, count) in pins)
                  Positioned(
                    left: offset.dx - 15,
                    top: offset.dy - 38,
                    child: Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            '$count',
                            style: AppText.body(12, weight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        Container(width: 2, height: 8, color: AppColors.primary),
                      ],
                    ),
                  ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: position == null ? AppColors.muted : AppColors.locationBlue,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          position == null ? locationOff : youAreHere,
                          style: AppText.body(12, weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Filialen auf die Kartenfläche abbilden (Maßstab passt sich an). Jeder Pin
  /// zeigt die Zahl der Produkte, die es bei der jeweiligen Kette gibt.
  List<(Offset, int)> _project(Size size) {
    final here = position;
    if (here == null) return const [];
    final located = [
      for (final s in stores)
        for (final l in s.locations) (l, s.ratedCount),
    ];
    if (located.isEmpty) return const [];

    const metersPerDegLat = 111320.0;
    final metersPerDegLon = metersPerDegLat * math.cos(here.latitude * math.pi / 180);
    final points = [
      for (final (l, count) in located)
        (
          Offset((l.longitude - here.longitude) * metersPerDegLon, -(l.latitude - here.latitude) * metersPerDegLat),
          count,
        ),
    ];
    final maxDist = points.map((p) => math.max(p.$1.dx.abs(), p.$1.dy.abs())).fold(200.0, math.max);
    final halfW = size.width / 2 - 24;
    final halfH = size.height / 2 - 24;
    final scale = math.min(halfW, halfH) / maxDist;
    final projected = [
      for (final (o, count) in points)
        (
          Offset(
            size.width / 2 + (o.dx * scale).clamp(-halfW, halfW),
            size.height / 2 + 14 + (o.dy * scale).clamp(-halfH, halfH - 14),
          ),
          count,
        ),
    ];
    return _spreadOverlapping(projected, size);
  }

  /// Läden am (fast) selben Ort würden exakt übereinander liegen: solche Pins
  /// abwechselnd nach rechts und links versetzen, bis sie frei stehen.
  static List<(Offset, int)> _spreadOverlapping(List<(Offset, int)> pins, Size size) {
    const minGap = 36.0;
    final placed = <(Offset, int)>[];
    for (final (origin, count) in pins) {
      var candidate = origin;
      for (var step = 1; placed.any((p) => (p.$1 - candidate).distance < minGap) && step < 12; step++) {
        final shift = minGap * ((step + 1) ~/ 2) * (step.isOdd ? 1 : -1);
        candidate = Offset((origin.dx + shift).clamp(18, size.width - 18), origin.dy);
      }
      placed.add((candidate, count));
    }
    return placed;
  }
}

class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE3E8DD));
    final park = Paint()..color = const Color(0xFFCFE0C4);
    canvas
      ..drawRRect(
        RRect.fromLTRBR(size.width * 0.6, -10, size.width * 0.94, size.height * 0.34, const Radius.circular(12)),
        park,
      )
      ..drawRRect(
        RRect.fromLTRBR(
          size.width * 0.06,
          size.height * 0.67,
          size.width * 0.31,
          size.height + 10,
          const Radius.circular(12),
        ),
        park,
      );

    Paint road(double w) => Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w;
    final w = size.width;
    final h = size.height;
    canvas
      ..drawPath(
        Path()
          ..moveTo(-10, h * 0.52)
          ..cubicTo(w * 0.23, h * 0.45, w * 0.46, h * 0.62, w + 10, h * 0.4),
        road(14),
      )
      ..drawLine(Offset(w * 0.37, -10), Offset(w * 0.43, h + 10), road(10))
      ..drawLine(Offset(w * 0.71, h * 0.4), Offset(w * 0.83, h + 10), road(8))
      ..drawLine(Offset(-10, h * 0.23), Offset(w * 0.4, h * 0.17), road(6))
      ..drawLine(Offset(w * 0.43, h * 0.8), Offset(w + 10, h * 0.85), road(6))
      ..drawPath(
        Path()
          ..moveTo(0, h * 0.91)
          ..cubicTo(w * 0.17, h * 0.85, w * 0.26, h, w * 0.4, h * 0.95),
        Paint()
          ..color = const Color(0xFFBCD3E0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
