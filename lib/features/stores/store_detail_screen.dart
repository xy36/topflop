import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/product_card.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'store_form_sheet.dart';

/// A store with the products available there.
class StoreDetailScreen extends ConsumerWidget {
  const StoreDetailScreen({super.key, required this.storeId});

  final int storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(storeSummariesProvider).value?.where((s) => s.store.id == storeId).firstOrNull;

    if (summary == null) return Scaffold(appBar: AppBar());

    final store = summary.store;

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
