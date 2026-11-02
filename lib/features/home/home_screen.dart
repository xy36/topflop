import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/product_card.dart';
import '../../data/providers.dart';
import '../../data/repositories/models.dart';
import '../../l10n/app_localizations.dart';

enum _Filter { all, favorites, buyAgain }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _search = TextEditingController();
  _Filter _filter = _Filter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matchesQuery(ProductSummary s) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    final p = s.product;
    return [p.name, p.brand, p.barcode, s.lastStoreName].whereType<String>().any((v) => v.toLowerCase().contains(q));
  }

  bool _matchesFilter(ProductSummary s, _Filter f) => switch (f) {
        _Filter.all => true,
        _Filter.favorites => s.product.isFavorite,
        _Filter.buyAgain => s.wouldBuyAgain == true,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(productSummariesProvider);
    final all = summaries.value ?? const <ProductSummary>[];
    final matching = all.where(_matchesQuery).toList();
    final visible = matching.where((s) => _matchesFilter(s, _filter)).toList();
    final query = _search.text.trim();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.appName.toUpperCase(), style: AppText.overline().copyWith(fontSize: 12, letterSpacing: 1.4)),
                          const SizedBox(height: 4),
                          Text(l10n.homeTitle, style: AppText.display(32)),
                        ],
                      ),
                    ),
                    SquareIconButton(
                      icon: Icons.tune_rounded,
                      tooltip: l10n.settings,
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SearchField(controller: _search, hint: l10n.homeSearchHint, label: l10n.homeSearchLabel, onChanged: () => setState(() {})),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final (filter, label) in [
                        (_Filter.all, l10n.filterAll),
                        (_Filter.favorites, l10n.filterFavorites),
                        (_Filter.buyAgain, l10n.filterBuyAgain),
                      ]) ...[
                        PillChip(
                          label: label,
                          trailing: '${matching.where((s) => _matchesFilter(s, filter)).length}',
                          selected: _filter == filter,
                          onTap: () => setState(() => _filter = filter),
                        ),
                        const SizedBox(width: 8),
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
                        _EmptyState(title: l10n.homeEmptyTitle, body: l10n.homeEmptyBody, action: l10n.scanNow)
                      else if (visible.isEmpty)
                        _EmptyState(title: l10n.homeNoMatchTitle, body: l10n.homeNoMatchBody(query), action: l10n.scanNow)
                      else ...[
                        SectionHeader(
                          query.isEmpty ? l10n.homeRecent : l10n.homeResults,
                          trailing: l10n.productCount(visible.length),
                        ),
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
  const _EmptyState({required this.title, required this.body, required this.action});

  final String title;
  final String body;
  final String action;

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
          Text(body, style: AppText.body(14, color: AppColors.muted).copyWith(height: 1.45), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () => context.push('/scan'),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
