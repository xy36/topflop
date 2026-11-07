import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/product_category.dart';
import '../../core/domain/score.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/product_image.dart';
import '../../data/providers.dart';
import '../../data/repositories/models.dart';
import '../../l10n/app_localizations.dart';
import 'product_filter.dart';

Future<void> showFilterSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: context.colors.background,
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

  void _update(ProductFilter Function(ProductFilter) change) {
    HapticFeedback.selectionClick();
    setState(() => _draft = change(_draft));
  }

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
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Text(l10n.filterTitle, style: AppText.display(28))),
                AnimatedOpacity(
                  opacity: _draft.isActive || _draft.sort != ProductSort.recent ? 1 : 0.35,
                  duration: const Duration(milliseconds: 150),
                  child: TextButton.icon(
                    onPressed: _draft.isActive || _draft.sort != ProductSort.recent
                        ? () => _update((_) => const ProductFilter())
                        : null,
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: Text(l10n.filterReset),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.primary,
                      disabledForegroundColor: context.colors.muted,
                      textStyle: AppText.body(14, weight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                _Card(
                  title: l10n.sortTitle,
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 3.1,
                    // Ohne explizites Padding übernimmt ein GridView den System-Rand.
                    padding: EdgeInsets.zero,
                    children: [
                      for (final (sort, icon, label) in [
                        (ProductSort.recent, Icons.schedule_rounded, l10n.sortRecent),
                        (ProductSort.bestRated, Icons.trending_up_rounded, l10n.sortBest),
                        (ProductSort.worstRated, Icons.trending_down_rounded, l10n.sortWorst),
                        (ProductSort.name, Icons.sort_by_alpha_rounded, l10n.sortName),
                      ])
                        _SortTile(
                          icon: icon,
                          label: label,
                          selected: _draft.sort == sort,
                          onTap: () => _update((f) => f.copyWith(sort: sort)),
                        ),
                    ],
                  ),
                ),
                _Card(
                  title: l10n.filterScore,
                  trailing: _ScoreRangeLabel(min: _draft.minScore, max: _draft.maxScore),
                  child: _ScoreRange(
                    min: _draft.minScore,
                    max: _draft.maxScore,
                    onChanged: (min, max) => _update((f) => f.copyWith(minScore: min, maxScore: max)),
                  ),
                ),
                _Card(
                  title: l10n.filterBuyAgain,
                  child: _Segmented<bool?>(
                    value: _draft.buyAgain,
                    options: [
                      (null, null, l10n.filterAny),
                      (true, Icons.check_rounded, l10n.yes),
                      (false, Icons.close_rounded, l10n.no),
                    ],
                    onChanged: (v) => _update((f) => f.copyWith(buyAgain: () => v)),
                  ),
                ),
                _Card(
                  padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: context.colors.primaryTint,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(Icons.favorite_rounded, size: 18, color: context.colors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(l10n.filterFavoritesOnly, style: AppText.body(15, weight: FontWeight.w700)),
                      ),
                      Switch.adaptive(
                        value: _draft.favoritesOnly,
                        activeTrackColor: context.colors.primary,
                        onChanged: (v) => _update((f) => f.copyWith(favoritesOnly: v)),
                      ),
                    ],
                  ),
                ),
                if (stores.isNotEmpty)
                  _Card(
                    title: l10n.filterStores,
                    trailing: _draft.storeIds.isEmpty ? null : _CountBadge(_draft.storeIds.length),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in stores)
                          _SelectChip(
                            label: s.store.name,
                            leading: Icon(Icons.storefront_outlined, size: 18, color: context.colors.primary),
                            selected: _draft.storeIds.contains(s.store.id),
                            onTap: () => _update((f) => f.copyWith(storeIds: _toggle(f.storeIds, s.store.id))),
                          ),
                      ],
                    ),
                  ),
                if (categories.isNotEmpty)
                  _Card(
                    title: l10n.filterCategories,
                    trailing: _draft.categories.isEmpty ? null : _CountBadge(_draft.categories.length),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in categories)
                          _SelectChip(
                            label: c.label(l10n),
                            leading: ProductImage(category: c, size: 24, radius: 7, iconSize: 15),
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
            decoration: BoxDecoration(
              color: context.colors.surface,
              border: Border(top: BorderSide(color: context.colors.border)),
            ),
            padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.paddingOf(context).bottom + 14),
            child: FilledButton(
              onPressed: resultCount == 0
                  ? null
                  : () {
                      ref.read(productFilterProvider.notifier).set(_draft);
                      Navigator.pop(context);
                    },
              style: FilledButton.styleFrom(
                disabledBackgroundColor: context.colors.border,
                disabledForegroundColor: context.colors.muted,
              ),
              child: Text(l10n.filterShowResults(resultCount)),
            ),
          ),
        ],
      ),
    );
  }

  static Set<T> _toggle<T>(Set<T> set, T value) => set.contains(value) ? ({...set}..remove(value)) : {...set, value};
}

/// Weiße Karte mit Abschnittstitel, wie auf der Bewertungsseite.
class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
  });

  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: padding,
        radius: 22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              SizedBox(
                height: 28,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(title!, style: AppText.body(15, weight: FontWeight.w700)),
                    ),
                    ?trailing,
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _SortTile extends StatelessWidget {
  const _SortTile({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? context.colors.primary : context.colors.inkSoft;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? context.colors.primaryTint : context.colors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? context.colors.primary : Colors.transparent, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(13.5, weight: selected ? FontWeight.w700 : FontWeight.w600, color: fg),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// „😕 5 – 🤩 10“ als kleine Plakette rechts im Kartentitel.
class _ScoreRangeLabel extends StatelessWidget {
  const _ScoreRangeLabel({required this.min, required this.max});

  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: context.colors.background, borderRadius: BorderRadius.circular(99)),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${Score.emoji(min)} '),
            TextSpan(
              text: '$min',
              style: AppText.body(14, weight: FontWeight.w800),
            ),
            TextSpan(
              text: '  –  ',
              style: AppText.body(14, color: context.colors.muted),
            ),
            TextSpan(text: '${Score.emoji(max)} '),
            TextSpan(
              text: '$max',
              style: AppText.body(14, weight: FontWeight.w800),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 15, height: 1.2),
      ),
    );
  }
}

/// Einrastender Bereichsregler mit Zahlenleiste darunter.
class _ScoreRange extends StatelessWidget {
  const _ScoreRange({required this.min, required this.max, required this.onChanged});

  final int min;
  final int max;
  final void Function(int min, int max) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: context.colors.primary,
            inactiveTrackColor: context.colors.border,
            thumbColor: Colors.white,
            overlayColor: AppColors.lime.withValues(alpha: 0.35),
            rangeThumbShape: const _RingRangeThumb(),
            rangeTickMarkShape: const RoundRangeSliderTickMarkShape(tickMarkRadius: 0),
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: RangeSlider(
            min: Score.min.toDouble(),
            max: Score.max.toDouble(),
            divisions: Score.max - Score.min,
            values: RangeValues(min.toDouble(), max.toDouble()),
            semanticFormatterCallback: (v) => l10n.ratingTick(v.round()),
            onChanged: (v) {
              final (a, b) = (v.start.round(), v.end.round());
              if (a != min || b != max) onChanged(a, b);
            },
          ),
        ),
        Padding(
          // Gleicher Innenabstand wie die Slider-Spur, damit die Zahlen unter den Rastpunkten stehen.
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var n = Score.min; n <= Score.max; n++)
                SizedBox(
                  width: 20,
                  child: Text(
                    '$n',
                    textAlign: TextAlign.center,
                    style: AppText.body(
                      12,
                      weight: n >= min && n <= max ? FontWeight.w700 : FontWeight.w500,
                      color: n >= min && n <= max ? context.colors.ink : context.colors.faint,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingRangeThumb extends RangeSliderThumbShape {
  const _RingRangeThumb();

  static const _radius = 13.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) {
    context.canvas
      ..drawCircle(
        center + const Offset(0, 1.5),
        _radius,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawCircle(center, _radius, Paint()..color = Colors.white)
      ..drawCircle(center, _radius - 4, Paint()..color = sliderTheme.activeTrackColor ?? Colors.green);
  }
}

/// Segment-Umschalter im Stil von „Wieder kaufen?“ auf der Bewertungsseite.
class _Segmented<T> extends StatelessWidget {
  const _Segmented({required this.value, required this.options, required this.onChanged});

  final T value;
  final List<(T, IconData?, String)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: context.colors.background, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          for (final (option, icon, label) in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: option == value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 42,
                  decoration: BoxDecoration(
                    color: option == value ? context.colors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: option == value
                        ? [
                            BoxShadow(
                              color: context.colors.shadow.withValues(alpha: 0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onChanged(option),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 16, color: option == value ? context.colors.primary : context.colors.muted),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          label,
                          style: AppText.body(
                            14,
                            weight: option == value ? FontWeight.w700 : FontWeight.w600,
                            color: option == value ? context.colors.ink : context.colors.muted,
                          ),
                        ),
                      ],
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

/// Mehrfachauswahl-Chip; ausgewählt mit Häkchen statt Icon.
class _SelectChip extends StatelessWidget {
  const _SelectChip({required this.label, required this.leading, required this.selected, required this.onTap});

  final String label;
  final Widget leading;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? context.colors.primaryTint : context.colors.background,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? context.colors.primary : Colors.transparent, width: 1.5),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 7, 14, 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: selected
                      ? Container(
                          key: const ValueKey('check'),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(color: context.colors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                        )
                      : SizedBox(
                          key: const ValueKey('icon'),
                          width: 24,
                          height: 24,
                          child: Center(child: leading),
                        ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppText.body(
                    14,
                    weight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? context.colors.onPrimaryTint : context.colors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: context.colors.strong, borderRadius: BorderRadius.circular(99)),
      child: Text(
        '$count',
        style: AppText.body(12, weight: FontWeight.w800, color: context.colors.strongAccent),
      ),
    );
  }
}
