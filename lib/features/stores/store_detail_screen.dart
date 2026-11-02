import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/product_card.dart';
import '../../data/location/location_service.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

class StoreDetailScreen extends ConsumerWidget {
  const StoreDetailScreen({super.key, required this.storeId});

  final int storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final summary = ref.watch(storeSummariesProvider).value?.where((s) => s.store.id == storeId).firstOrNull;
    final position = ref.watch(currentPositionProvider).value;

    if (summary == null) return Scaffold(appBar: AppBar());

    final store = summary.store;
    final distance = position == null || store.latitude == null
        ? null
        : formatDistance(position.distanceTo(store.latitude!, store.longitude!), locale);
    final meta = [store.address, distance].whereType<String>().join(' · ');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                SquareIconButton(icon: Icons.arrow_back_ios_new_rounded, tooltip: l10n.back, onPressed: () => context.pop()),
              ],
            ),
            const SizedBox(height: 20),
            Text(store.name, style: AppText.display(32)),
            if (meta.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(meta, style: AppText.body(14, weight: FontWeight.w600, color: AppColors.muted)),
            ],
            const SizedBox(height: 20),
            SectionHeader(l10n.storeProducts, trailing: l10n.productCount(summary.ratedCount)),
            const SizedBox(height: 10),
            for (final p in summary.products) ...[
              ProductCard(summary: p, onTap: () => context.push('/product/${p.product.id}')),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
