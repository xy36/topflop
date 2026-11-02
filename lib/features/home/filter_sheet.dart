import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/product_category.dart';
import '../../core/domain/score.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/providers.dart';
import '../../data/repositories/models.dart';
import '../../l10n/app_localizations.dart';
import 'product_filter.dart';

Future<void> showFilterSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => const _FilterSheet(),
);

/// Filter werden erst mit „N Produkte anzeigen“ übernommen.
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late ProductFilter _draft = ref.read(productFilterProvider);

  void _update(ProductFilter Function(ProductFilter) change) => setState(() => _draft = change(_draft));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final products = ref.watch(productSummariesProvider).value ?? const <ProductSummary>[];
    final stores = ref.watch(storeSummariesProvider).value ?? const <StoreSummary>[];
    final resultCount = products.where(_draft.matches).length;

    // Nur Kategorien zeigen, die es auch gibt – plus bereits gewählte.
    final usedCategories = {
      for (final p in products) ProductCategory.fromName(p.product.category),
      ..._draft.categories,
    };
    final categories = ProductCategory.values.where(usedCategories.contains).toList();

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 4),
            child: Row(
              children: [
                Expanded(child: Text(l10n.filterTitle, style: AppText.display(24))),
                TextButton(
                  onPressed: _draft.isActive ? () => _update((f) => f.cleared()) : null,
                  child: Text(l10n.filterReset),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              children: [
                _Section(
                  title: l10n.sortTitle,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (sort, label) in [
                        (ProductSort.recent, l10n.sortRecent),
                        (ProductSort.bestRated, l10n.sortBest),
                        (ProductSort.worstRated, l10n.sortWorst),
                        (ProductSort.name, l10n.sortName),
                      ])
                        PillChip(
                          label: label,
                          dark: false,
                          selected: _draft.sort == sort,
                          onTap: () => _update((f) => f.copyWith(sort: sort)),
                        ),
                    ],
                  ),
                ),
                _Section(
                  title: l10n.filterScore,
                  trailing:
                      '${Score.emoji(_draft.minScore)} ${_draft.minScore} – ${Score.emoji(_draft.maxScore)} ${_draft.maxScore}',
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 8,
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.border,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.lime.withValues(alpha: 0.4),
                      rangeTickMarkShape: const RoundRangeSliderTickMarkShape(tickMarkRadius: 0),
                      showValueIndicator: ShowValueIndicator.never,
                    ),
                    child: RangeSlider(
                      min: Score.min.toDouble(),
                      max: Score.max.toDouble(),
                      divisions: Score.max - Score.min,
                      values: RangeValues(_draft.minScore.toDouble(), _draft.maxScore.toDouble()),
                      semanticFormatterCallback: (v) => l10n.ratingTick(v.round()),
                      onChanged: (v) => _update((f) => f.copyWith(minScore: v.start.round(), maxScore: v.end.round())),
                    ),
                  ),
                ),
                _Section(
                  title: l10n.filterBuyAgain,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (value, label) in [(null, l10n.filterAny), (true, l10n.yes), (false, l10n.no)])
                        PillChip(
                          label: label,
                          dark: false,
                          selected: _draft.buyAgain == value,
                          onTap: () => _update((f) => f.copyWith(buyAgain: () => value)),
                        ),
                    ],
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _draft.favoritesOnly,
                  activeTrackColor: AppColors.primary,
                  onChanged: (v) => _update((f) => f.copyWith(favoritesOnly: v)),
                  title: Text(l10n.filterFavoritesOnly, style: AppText.body(15, weight: FontWeight.w700)),
                ),
                if (stores.isNotEmpty)
                  _Section(
                    title: l10n.filterStores,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in stores)
                          PillChip(
                            label: s.store.name,
                            dark: false,
                            selected: _draft.storeIds.contains(s.store.id),
                            onTap: () => _update((f) => f.copyWith(storeIds: _toggle(f.storeIds, s.store.id))),
                          ),
                      ],
                    ),
                  ),
                if (categories.isNotEmpty)
                  _Section(
                    title: l10n.filterCategories,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in categories)
                          PillChip(
                            label: c.label(l10n),
                            dark: false,
                            selected: _draft.categories.contains(c),
                            onTap: () => _update((f) => f.copyWith(categories: _toggle(f.categories, c))),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.paddingOf(context).bottom + 14),
            child: FilledButton(
              onPressed: () {
                ref.read(productFilterProvider.notifier).set(_draft);
                Navigator.pop(context);
              },
              child: Text(l10n.filterShowResults(resultCount)),
            ),
          ),
        ],
      ),
    );
  }

  static Set<T> _toggle<T>(Set<T> set, T value) => set.contains(value) ? ({...set}..remove(value)) : {...set, value};
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title, trailing: trailing),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
