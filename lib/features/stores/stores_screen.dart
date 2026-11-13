import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/score.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/collapsing_tab_page.dart';
import '../../core/widgets/common.dart';
import '../../data/providers.dart';
import '../../data/repositories/models.dart';
import '../../l10n/app_localizations.dart';
import 'store_form_sheet.dart';

/// Your stores (chains), most used first.
class StoresScreen extends ConsumerWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stores = [...?ref.watch(storeSummariesProvider).value]
      ..sort((a, b) {
        final byCount = b.ratedCount.compareTo(a.ratedCount);
        return byCount != 0 ? byCount : a.store.name.toLowerCase().compareTo(b.store.name.toLowerCase());
      });

    return CollapsingTabPage(
      title: l10n.storesTitle,
      action: SquareIconButton(
        icon: Icons.add_rounded,
        tooltip: l10n.storesAdd,
        background: context.colors.strong,
        foreground: context.colors.strongAccent,
        bordered: false,
        onPressed: () => showStoreForm(context),
      ),
      slivers: [
        SliverPadding(
          // The list runs underneath the navigation; leave room for it at the bottom.
          padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.paddingOf(context).bottom),
          sliver: SliverList.list(
            children: [
              SectionHeader(l10n.storesAll, trailing: stores.isEmpty ? null : '${stores.length}'),
              const SizedBox(height: 10),
              if (stores.isEmpty)
                AppCard(
                  child: Text(
                    l10n.storesEmpty,
                    style: AppText.body(14, color: context.colors.muted).copyWith(height: 1.45),
                  ),
                )
              else
                for (final summary in stores) ...[
                  _StoreCard(summary: summary, onTap: () => context.push('/store/${summary.store.id}')),
                  const SizedBox(height: 10),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.summary, required this.onTap});

  final StoreSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final top = summary.top;
    final meta = l10n.storesRatedCount(summary.ratedCount);

    return Material(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.colors.borderSoft),
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
                decoration: BoxDecoration(color: context.colors.primaryTint, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.storefront_outlined, color: context.colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.store.name, style: AppText.body(16, weight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(meta, style: AppText.body(13, color: context.colors.muted)),
                    if (top != null && top.score != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        l10n.storesTop('${Score.emoji(top.score!)} ${top.product.name} · ${top.score}'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(13, color: context.colors.inkSoft),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.colors.faint),
            ],
          ),
        ),
      ),
    );
  }
}
