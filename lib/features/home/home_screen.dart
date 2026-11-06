import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/score.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/tab_header.dart';
import '../../core/widgets/product_card.dart';
import '../../data/providers.dart';
import '../../data/repositories/models.dart';
import '../../l10n/app_localizations.dart';
import 'filter_sheet.dart';
import 'product_filter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matchesQuery(ProductSummary s) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    final p = s.product;
    return [
      p.name,
      p.brand,
      p.barcode,
      ...s.stores.map((st) => st.name),
    ].whereType<String>().any((v) => v.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(productSummariesProvider);
    final filter = ref.watch(productFilterProvider);
    final filterNotifier = ref.read(productFilterProvider.notifier);
    final all = summaries.value ?? const <ProductSummary>[];
    final matching = all.where(_matchesQuery).toList();
    final visible = filter.apply(matching);
    final query = _search.text.trim();

    int countWith(ProductFilter f) => matching.where(f.matches).length;
    final favoritesFilter = filter.copyWith(favoritesOnly: !filter.favoritesOnly);
    final buyAgainFilter = filter.copyWith(buyAgain: () => filter.buyAgain == true ? null : true);

    final String sectionTitle;
    if (query.isNotEmpty || filter.isActive) {
      sectionTitle = l10n.homeResults;
    } else if (filter.sort == ProductSort.recent) {
      sectionTitle = l10n.homeRecent;
    } else {
      sectionTitle = l10n.homeAllProducts;
    }

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabHeader(
                  title: l10n.homeTitle,
                  action: _FilterButton(
                    activeCount: filter.activeCount,
                    tooltip: l10n.filterTitle,
                    onPressed: () => showFilterSheet(context),
                  ),
                ),
                const SizedBox(height: 16),
                _SearchField(
                  controller: _search,
                  hint: l10n.homeSearchHint,
                  label: l10n.homeSearchLabel,
                  onChanged: () => setState(() {}),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      PillChip(
                        label: l10n.filterAll,
                        trailing: '${matching.length}',
                        selected: !filter.isActive,
                        onTap: filterNotifier.clear,
                      ),
                      const SizedBox(width: 8),
                      PillChip(
                        label: l10n.filterFavorites,
                        trailing: '${countWith(filter.copyWith(favoritesOnly: true))}',
                        selected: filter.favoritesOnly,
                        onTap: () => filterNotifier.set(favoritesFilter),
                      ),
                      const SizedBox(width: 8),
                      PillChip(
                        label: l10n.filterBuyAgain,
                        trailing: '${countWith(filter.copyWith(buyAgain: () => true))}',
                        selected: filter.buyAgain == true,
                        onTap: () => filterNotifier.set(buyAgainFilter),
                      ),
                      // Weitere aktive Filter aus dem Filter-Panel, einzeln entfernbar.
                      for (final (label, remove) in _extraFilterChips(l10n, filter)) ...[
                        const SizedBox(width: 8),
                        _RemovableChip(label: label, onRemove: () => filterNotifier.set(remove)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: summaries.isLoading && summaries.value == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      if (all.isEmpty)
                        _EmptyState(
                          title: l10n.homeEmptyTitle,
                          body: l10n.homeEmptyBody,
                          action: l10n.scanNow,
                          onAction: () => context.push('/scan'),
                        )
                      else if (visible.isEmpty && filter.isActive)
                        _EmptyState(
                          title: l10n.homeNoMatchTitle,
                          body: l10n.filterNoMatchBody,
                          action: l10n.filterReset,
                          onAction: filterNotifier.clear,
                        )
                      else if (visible.isEmpty)
                        _EmptyState(
                          title: l10n.homeNoMatchTitle,
                          body: l10n.homeNoMatchBody(query),
                          action: l10n.scanNow,
                          onAction: () => context.push('/scan'),
                        )
                      else ...[
                        SectionHeader(sectionTitle, trailing: l10n.productCount(visible.length)),
                        const SizedBox(height: 10),
                        for (final s in visible) ...[
                          ProductCard(summary: s, onTap: () => context.push('/product/${s.product.id}')),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.hint, required this.label, required this.onChanged});

  final TextEditingController controller;
  final String hint;
  final String label;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.04), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.muted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              label: label,
              textField: true,
              child: TextField(
                controller: controller,
                onChanged: (_) => onChanged(),
                textInputAction: TextInputAction.search,
                style: AppText.body(16),
                decoration: InputDecoration(
                  hintText: hint,
                  filled: false,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.muted),
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              onPressed: () {
                controller.clear();
                onChanged();
              },
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body, required this.action, required this.onAction});

  final String title;
  final String body;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCBD1C4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(title, style: AppText.display(20), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            body,
            style: AppText.body(14, color: AppColors.muted).copyWith(height: 1.45),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: onAction,
            child: Text(action),
          ),
        ],
      ),
    );
  }
}

/// Chips für Filter, die nicht schon als Schnellfilter sichtbar sind:
/// jeweils Beschriftung und der Filter ohne diese Einschränkung.
List<(String, ProductFilter)> _extraFilterChips(AppLocalizations l10n, ProductFilter f) => [
  if (f.scoreActive)
    ('${Score.emoji(f.minScore)} ${f.minScore}–${f.maxScore}', f.copyWith(minScore: Score.min, maxScore: Score.max)),
  if (f.buyAgain == false) (l10n.notBuyAgain, f.copyWith(buyAgain: () => null)),
  if (f.storeIds.isNotEmpty) (l10n.filterStoresCount(f.storeIds.length), f.copyWith(storeIds: const {})),
  if (f.categories.length == 1)
    (f.categories.first.label(l10n), f.copyWith(categories: const {}))
  else if (f.categories.length > 1)
    (l10n.filterCategoriesCount(f.categories.length), f.copyWith(categories: const {})),
];

class _RemovableChip extends StatelessWidget {
  const _RemovableChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.ink,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onRemove,
        child: Semantics(
          button: true,
          label: '$label, ${l10n.filterRemove}',
          excludeSemantics: true,
          child: Container(
            height: 36,
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppText.body(14, weight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.close_rounded, size: 16, color: AppColors.lime),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Filterknopf oben rechts; dunkel mit Zähler, sobald Filter aktiv sind.
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount, required this.tooltip, required this.onPressed});

  final int activeCount;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final active = activeCount > 0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SquareIconButton(
          icon: Icons.tune_rounded,
          tooltip: tooltip,
          background: active ? AppColors.ink : AppColors.surface,
          foreground: active ? AppColors.lime : AppColors.ink,
          bordered: !active,
          onPressed: onPressed,
        ),
        if (active)
          Positioned(
            top: -5,
            right: -5,
            child: IgnorePointer(
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: Text('$activeCount', style: AppText.body(11, weight: FontWeight.w800)),
              ),
            ),
          ),
      ],
    );
  }
}
