import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/domain/product_category.dart';
import '../../core/domain/score.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/product_image.dart';
import '../../data/providers.dart';
import '../../data/repositories/models.dart';
import '../../l10n/app_localizations.dart';
import 'product_edit_sheet.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.productId});

  final int productId;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  static const _heroHeight = 260.0;
  static const _barHeight = 68.0;

  /// Sobald das Bild weggescrollt ist, bekommt die Kopfzeile einen festen
  /// Hintergrund und zeigt den Produktnamen.
  final _collapsed = ValueNotifier(false);

  @override
  void dispose() {
    _collapsed.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0) _collapsed.value = n.metrics.pixels > _heroHeight - _barHeight - 24;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final productId = widget.productId;
    final async = ref.watch(productProvider(productId));
    final summary = async.value;

    if (summary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: async.isLoading ? const CircularProgressIndicator() : const SizedBox()),
      );
    }

    final p = summary.product;
    final repo = ref.read(productRepositoryProvider);
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Hero(summary: summary, height: _heroHeight + topInset),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -24),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _Body(summary: summary),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _collapsed,
            builder: (context, collapsed, _) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: topInset + _barHeight,
              padding: EdgeInsets.fromLTRB(20, topInset + 12, 20, 12),
              decoration: BoxDecoration(
                color: collapsed ? AppColors.background : AppColors.background.withValues(alpha: 0),
                border: Border(
                  bottom: BorderSide(color: collapsed ? AppColors.border : AppColors.border.withValues(alpha: 0)),
                ),
              ),
              child: Row(
                children: [
                  SquareIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: l10n.back,
                    bordered: false,
                    elevated: !collapsed,
                    onPressed: () => context.canPop() ? context.pop() : context.go('/'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: collapsed ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(16, weight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SquareIconButton(
                    icon: p.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    tooltip: l10n.favorite,
                    foreground: AppColors.primary,
                    bordered: false,
                    elevated: !collapsed,
                    onPressed: () => repo.setFavorite(p.id, !p.isFavorite),
                  ),
                  const SizedBox(width: 8),
                  SquareIconButton(
                    icon: Icons.edit_outlined,
                    tooltip: l10n.productEditTitle,
                    bordered: false,
                    elevated: !collapsed,
                    onPressed: () => showProductEditSheet(context, p),
                  ),
                  const SizedBox(width: 8),
                  SquareIconButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: l10n.delete,
                    bordered: false,
                    elevated: !collapsed,
                    onPressed: () async {
                      final ok = await _confirm(context, l10n.deleteProductTitle, l10n.deleteProductBody);
                      if (ok && context.mounted) {
                        context.pop();
                        await repo.deleteProduct(p.id);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.paddingOf(context).bottom + 16),
        child: FilledButton.icon(
          onPressed: () => context.push('/product/${p.id}/rate'),
          icon: Icon(summary.isRated ? Icons.edit_outlined : Icons.add_rounded),
          label: Text(summary.isRated ? l10n.ratingChange : l10n.rate),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.summary, required this.height});

  final ProductSummary summary;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = summary.product;
    final category = ProductCategory.fromName(p.category);
    final placeholder = CategoryTile(category: category, iconSize: 120, strokeWidth: 0.9);
    return SizedBox(
      height: height,
      child: p.imageUrl == null
          ? placeholder
          : ColoredBox(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, MediaQuery.paddingOf(context).top + 56, 24, 40),
                child: CachedNetworkImage(
                  imageUrl: p.imageUrl!,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => const SizedBox(),
                  errorWidget: (_, _, _) => placeholder,
                ),
              ),
            ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.summary});

  final ProductSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final p = summary.product;
    final rating = summary.rating;
    final subtitle = [p.brand, p.quantity].whereType<String>().join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: AppText.body(14, weight: FontWeight.w600, color: AppColors.muted),
          ),
        const SizedBox(height: 6),
        Text(p.name, style: AppText.display(32)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (p.nutriScore != null) _InfoChip(l10n.nutriScore(p.nutriScore!), bold: true),
            _InfoChip(ProductCategory.fromName(p.category).label(l10n)),
          ],
        ),
        const SizedBox(height: 20),
        if (rating != null) ...[
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: l10n.productScore,
                  background: AppColors.ink,
                  foreground: Colors.white,
                  labelColor: Colors.white.withValues(alpha: 0.72),
                  value: '${rating.score}',
                  emoji: Score.emoji(rating.score),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(
                  label: l10n.productBuyAgain,
                  background: rating.wouldBuyAgain ? AppColors.lime : AppColors.scoreLow,
                  labelColor: const Color(0xFF2E3A16),
                  value: rating.wouldBuyAgain ? l10n.yes : l10n.no,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(
                  label: l10n.ratingPrice,
                  background: AppColors.surface,
                  bordered: true,
                  value: rating.priceCents == null ? '–' : formatPrice(rating.priceCents!, locale),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l10n.productRatedOn(DateFormat.yMMMMd(locale).format(rating.ratedAt)),
            style: AppText.body(13, color: AppColors.muted),
          ),
          if (rating.note != null && rating.note!.isNotEmpty) ...[
            const SizedBox(height: 20),
            SectionHeader(l10n.productYourNote),
            const SizedBox(height: 10),
            AppCard(
              radius: 20,
              child: Text(rating.note!, style: AppText.body(15, color: AppColors.inkSoft).copyWith(height: 1.45)),
            ),
          ],
        ] else
          AppCard(
            child: Text(l10n.productNoRatings, style: AppText.body(15, color: AppColors.muted)),
          ),
        if (summary.stores.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionHeader(l10n.productAvailableAt),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final store in summary.stores)
                ActionChip(
                  avatar: const Icon(Icons.place_outlined, size: 16, color: AppColors.primary),
                  label: Text(store.name),
                  labelStyle: AppText.body(14, weight: FontWeight.w600),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onPressed: () => context.push('/store/${store.id}'),
                ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        const SizedBox(height: 8),
        if (p.barcode != null)
          Text(
            l10n.dataSourceOff,
            textAlign: TextAlign.center,
            style: AppText.body(12, color: AppColors.muted),
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label, {this.bold = false});

  final String label;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppText.body(
          12,
          weight: bold ? FontWeight.w700 : FontWeight.w600,
          color: bold ? AppColors.ink : const Color(0xFF3E4A42),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.background,
    this.foreground = AppColors.ink,
    this.labelColor = AppColors.muted,
    this.emoji,
    this.bordered = false,
  });

  final String label;
  final String value;
  final String? emoji;
  final Color background;
  final Color foreground;
  final Color labelColor;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: bordered ? Border.all(color: AppColors.border) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(12, weight: FontWeight.w600, color: labelColor),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                if (emoji != null) ...[
                  Text(emoji!, style: const TextStyle(fontSize: 22, height: 1)),
                  const SizedBox(width: 6),
                ],
                Text(value, style: AppText.display(26, color: foreground)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> _confirm(BuildContext context, String title, String? body) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
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
  return result ?? false;
}
