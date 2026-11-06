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
import 'store_form_sheet.dart';

/// Eine Kette mit ihren Filialen und den Produkten, die es dort gibt.
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
    final locations = [for (final l in summary.locations) (l, position?.distanceTo(l.latitude, l.longitude))]
      ..sort((a, b) => (a.$2 ?? double.infinity).compareTo(b.$2 ?? double.infinity));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                SquareIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  tooltip: l10n.back,
                  onPressed: () => context.pop(),
                ),
                const Spacer(),
                SquareIconButton(
                  icon: Icons.edit_outlined,
                  tooltip: l10n.storeEditTitle,
                  onPressed: () => showStoreForm(context, existing: store),
                ),
                const SizedBox(width: 8),
                SquareIconButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: l10n.delete,
                  onPressed: () async {
                    final ok = await _confirm(context, l10n.deleteStoreTitle, l10n.deleteStoreBody);
                    if (ok && context.mounted) {
                      context.pop();
                      await ref.read(storeRepositoryProvider).deleteStore(store.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(store.name, style: AppText.display(32)),
            const SizedBox(height: 6),
            Text(
              l10n.storeBranchCount(summary.locations.length),
              style: AppText.body(14, weight: FontWeight.w600, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            SectionHeader(l10n.storeBranches),
            const SizedBox(height: 10),
            if (locations.isEmpty)
              AppCard(
                radius: 20,
                child: Text(
                  l10n.storeNoBranches,
                  style: AppText.body(14, color: AppColors.muted).copyWith(height: 1.4),
                ),
              )
            else
              AppCard(
                radius: 20,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (final (location, distance) in locations)
                      ListTile(
                        leading: const Icon(Icons.place_outlined, color: AppColors.primary),
                        title: Text(
                          location.address ?? l10n.storeBranchUnnamed,
                          style: AppText.body(15, weight: FontWeight.w600),
                        ),
                        subtitle: distance == null
                            ? null
                            : Text(formatDistance(distance, locale), style: AppText.body(13, color: AppColors.muted)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                          tooltip: l10n.storeBranchRemove,
                          onPressed: () async {
                            final ok = await _confirm(context, l10n.storeBranchRemoveTitle, null);
                            if (ok) await ref.read(storeRepositoryProvider).deleteLocation(location.id);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
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

Future<bool> _confirm(BuildContext context, String title, String? body) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: body == null ? null : Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete)),
      ],
    ),
  );
  return ok ?? false;
}
