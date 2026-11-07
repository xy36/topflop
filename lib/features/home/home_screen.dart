import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/score.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/product_card.dart';
import '../../data/db/database.dart';
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

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  final _search = TextEditingController();

  /// Wie viele Pixel des Kopfbereichs gerade weggeklappt sind.
  late final _hidden = AnimationController.unbounded(vsync: this);

  /// Maximal wegklappbare Höhe (alles außer der oberen Leiste).
  double _range = 0;
  double _gestureStart = 0;

  /// Scrollposition der Liste; liegt Inhalt unter dem Kopf, bekommt er einen Schatten.
  double _pixels = 0;

  @override
  void dispose() {
    _search.dispose();
    _hidden.dispose();
    super.dispose();
  }

  /// „Quick Return“: Der Kopf folgt dem Scrollen pixelgenau (runter = weg,
  /// hoch = sofort wieder da). Endet die Bewegung mittendrin, rastet er je
  /// nach Gesamtrichtung der Geste ganz aus oder ganz ein.
  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    final pixels = n.metrics.pixels;
    _pixels = pixels;
    final limit = pixels.clamp(0.0, _range);
    if (n is ScrollStartNotification) {
      _hidden.stop();
      _gestureStart = pixels;
    } else if (n is ScrollUpdateNotification) {
      _hidden.value = (_hidden.value + (n.scrollDelta ?? 0)).clamp(0.0, limit);
    } else if (n is ScrollEndNotification) {
      final value = _hidden.value;
      if (value > 0 && value < limit) {
        final scrolledUp = pixels < _gestureStart;
        _hidden.animateTo(
          scrolledUp ? 0 : limit,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      }
    }
    return false;
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

    // Läden als Schnellfilter: die, in denen du am meisten bewertet hast, zuerst.
    final storeCounts = <int, (Store, int)>{};
    for (final s in all) {
      for (final st in s.stores) {
        storeCounts[st.id] = (st, (storeCounts[st.id]?.$2 ?? 0) + 1);
      }
    }
    final quickStores = storeCounts.values.toList()
      ..sort((a, b) {
        final byCount = b.$2.compareTo(a.$2);
        return byCount != 0 ? byCount : a.$1.name.toLowerCase().compareTo(b.$1.name.toLowerCase());
      });
    void toggleStore(int id) {
      final ids = {...filter.storeIds};
      if (!ids.remove(id)) ids.add(id);
      filterNotifier.set(filter.copyWith(storeIds: ids));
    }

    final String sectionTitle;
    if (query.isNotEmpty || filter.isActive) {
      sectionTitle = l10n.homeResults;
    } else if (filter.sort == ProductSort.recent) {
      sectionTitle = l10n.homeRecent;
    } else {
      sectionTitle = l10n.homeAllProducts;
    }

    // Großer Titel, Suche und Chips klappen beim Runterscrollen unter eine
    // schmale Leiste; schon ein kurzes Hochscrollen holt alles zurück.
    final header = _HomeHeader(
      title: l10n.homeTitle,
      appName: l10n.appName.toUpperCase(),
      settingsTooltip: l10n.settings,
      filterButton: _FilterButton(
        activeCount: filter.activeCount,
        tooltip: l10n.filterTitle,
        onPressed: () => showFilterSheet(context),
      ),
      search: _SearchField(
        controller: _search,
        hint: l10n.homeSearchHint,
        label: l10n.homeSearchLabel,
        onChanged: () => setState(() {}),
      ),
      chips: quickStores.isEmpty && !filter.isActive
          ? null
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Aktive Filter aus dem Filter-Panel zuerst, einzeln entfernbar.
                  for (final (label, remove) in _extraFilterChips(l10n, filter)) ...[
                    _RemovableChip(label: label, onRemove: () => filterNotifier.set(remove)),
                    const SizedBox(width: 8),
                  ],
                  if (quickStores.isNotEmpty) ...[
                    PillChip(
                      label: l10n.filterAll,
                      trailing: '${countWith(filter.copyWith(storeIds: const {}))}',
                      selected: filter.storeIds.isEmpty,
                      onTap: () => filterNotifier.set(filter.copyWith(storeIds: const {})),
                    ),
                    for (final (store, _) in quickStores) ...[
                      const SizedBox(width: 8),
                      PillChip(
                        label: store.name,
                        trailing: '${countWith(filter.copyWith(storeIds: {store.id}))}',
                        selected: filter.storeIds.contains(store.id),
                        onTap: () => toggleStore(store.id),
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
    _range = header.maxExtent - header.minExtent;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: header.maxExtent)),
                if (summaries.isLoading && summaries.value == null)
                  const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator()))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverList.list(
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
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _hidden,
              builder: (context, _) {
                final hidden = _hidden.value.clamp(0.0, _range);
                return SizedBox(
                  height: header.maxExtent - hidden,
                  child: header.build(context, hidden, scrolledUnder: _pixels > hidden + 1),
                );
              },
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

/// Chips für aktive Filter, die nicht schon als Laden-Schnellfilter sichtbar
/// sind: jeweils Beschriftung und der Filter ohne diese Einschränkung.
List<(String, ProductFilter)> _extraFilterChips(AppLocalizations l10n, ProductFilter f) => [
  if (f.favoritesOnly) (l10n.filterFavorites, f.copyWith(favoritesOnly: false)),
  if (f.buyAgain == true) (l10n.filterBuyAgain, f.copyWith(buyAgain: () => null)),
  if (f.buyAgain == false) (l10n.notBuyAgain, f.copyWith(buyAgain: () => null)),
  if (f.scoreActive)
    ('${Score.emoji(f.minScore)} ${f.minScore}–${f.maxScore}', f.copyWith(minScore: Score.min, maxScore: Score.max)),
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

/// Kopf der Übersicht. Ausgeklappt: App-Name mit Zahnrad, großer Titel mit
/// Filterknopf, Suche und Chips. Beim Runterscrollen schiebt sich alles unter
/// die obere Leiste, in die dann ein kleiner Titel und der Filterknopf
/// einblenden. Beim Hochscrollen fährt der Kopf sofort wieder aus und rastet
/// am Ende ganz ein oder ganz aus.
class _HomeHeader {
  _HomeHeader({
    required this.title,
    required this.appName,
    required this.settingsTooltip,
    required this.filterButton,
    required this.search,
    required this.chips,
  });

  final String title;
  final String appName;
  final String settingsTooltip;
  final Widget filterButton;
  final Widget search;
  final Widget? chips;

  static const _bar = 52.0; // 8 Abstand + 44 Leiste
  static const _titleRow = 56.0;
  static const _search = 52.0;
  static const _chips = 40.0;
  static const _gap = 16.0;
  static const _bottom = 8.0;

  double get _body => _titleRow + _gap + _search + (chips == null ? 0 : _gap + _chips) + _bottom;

  double get maxExtent => _bar + _body;

  double get minExtent => _bar + _bottom;

  Widget build(BuildContext context, double shrinkOffset, {bool scrolledUnder = false}) {
    // 0 = großer Titel sichtbar, 1 = Titel ist unter der Leiste verschwunden.
    final t = Curves.easeOut.transform((shrinkOffset / (_titleRow * 0.8)).clamp(0.0, 1.0));
    final collapsed = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: scrolledUnder ? 0.08 : 0.08 * collapsed),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Inhalt schiebt sich, unten verankert, unter die Leiste.
            Positioned(
              left: 0,
              right: 0,
              top: _bar - shrinkOffset,
              height: _body,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: _titleRow,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Opacity(
                        opacity: 1 - t,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: AppText.display(32),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IgnorePointer(ignoring: t > 0.5, child: filterButton),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: _gap),
                  SizedBox(
                    height: _search,
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: search),
                  ),
                  if (chips != null) ...[
                    const SizedBox(height: _gap),
                    SizedBox(
                      height: _chips,
                      child: Align(alignment: Alignment.centerLeft, child: chips),
                    ),
                  ],
                ],
              ),
            ),
            // Obere Leiste, immer sichtbar.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: _bar,
              child: ColoredBox(
                color: AppColors.background,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Opacity(
                              opacity: 1 - t,
                              child: Text(
                                appName,
                                style: AppText.overline().copyWith(fontSize: 12, letterSpacing: 1.4),
                              ),
                            ),
                            Opacity(
                              opacity: t,
                              child: Transform.translate(
                                offset: Offset(0, 8 * (1 - t)),
                                child: Text(
                                  title,
                                  style: AppText.display(20),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IgnorePointer(
                        ignoring: t < 0.5,
                        child: Opacity(
                          opacity: t,
                          child: Transform.scale(scale: 0.85 + 0.15 * t, child: filterButton),
                        ),
                      ),
                      SizedBox(width: 8 * t),
                      SizedBox(
                        width: 44,
                        child: IconButton(
                          onPressed: () => context.push('/settings'),
                          tooltip: settingsTooltip,
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.settings_outlined, size: 22, color: AppColors.muted),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
