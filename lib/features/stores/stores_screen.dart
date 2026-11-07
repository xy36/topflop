import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/score.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/tab_header.dart';
import '../../data/providers.dart';
import '../../data/repositories/models.dart';
import '../../l10n/app_localizations.dart';
import 'store_form_sheet.dart';

/// Deine Läden (Ketten), meistgenutzte zuerst.
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

    return SafeArea(
      bottom: false,
      child: ListView(
        // Die Liste läuft unter der Navigation durch; unten Platz dafür lassen.
        padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.paddingOf(context).bottom),
        children: [
          TabHeader(
            title: l10n.storesTitle,
            action: SquareIconButton(
              icon: Icons.add_rounded,
              tooltip: l10n.storesAdd,
              background: AppColors.ink,
              foreground: AppColors.lime,
              bordered: false,
              onPressed: () => showStoreForm(context),
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(l10n.storesAll, trailing: stores.isEmpty ? null : '${stores.length}'),
          const SizedBox(height: 10),
          if (stores.isEmpty)
            AppCard(
              child: Text(l10n.storesEmpty, style: AppText.body(14, color: AppColors.muted).copyWith(height: 1.45)),
            )
          else
            for (final summary in stores) ...[
              _StoreCard(summary: summary, onTap: () => context.push('/store/${summary.store.id}')),
              const SizedBox(height: 10),
            ],
        ],
      ),
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
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderSoft),
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
                decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.storefront_outlined, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.store.name, style: AppText.body(16, weight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(meta, style: AppText.body(13, color: AppColors.muted)),
                    if (top != null && top.score != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        l10n.storesTop('${Score.emoji(top.score!)} ${top.product.name} · ${top.score}'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(13, color: AppColors.inkSoft),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8A948C)),
            ],
          ),
        ),
      ),
    );
  }
}
