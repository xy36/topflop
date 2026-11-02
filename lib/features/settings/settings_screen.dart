import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/backup/backup_service.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

final _backupInfoProvider = FutureProvider.autoDispose<(DateTime?, int)>((ref) async {
  final backup = ref.watch(backupServiceProvider);
  return (await backup.lastExport(), await backup.databaseSize());
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    final box = context.findRenderObject() as RenderBox?;
    setState(() => _busy = true);
    try {
      final backup = ref.read(backupServiceProvider);
      final file = await backup.exportToFile();
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: l10n.backupShareText,
          sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
      if (result.status != ShareResultStatus.dismissed) await backup.markExported();
      ref.invalidate(_backupInfoProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final file = await FilePicker.pickFile(type: FileType.any);
    if (file == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsImportTitle),
        content: Text(l10n.settingsImportBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.settingsImport)),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final content = await file.xFile.readAsString();
      await ref.read(backupServiceProvider).importJson(content);
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsImportDone)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsImportFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final info = ref.watch(_backupInfoProvider).value;
    final lastExport = info?.$1;
    final size = info?.$2 ?? 0;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Text(l10n.appName.toUpperCase(), style: AppText.overline().copyWith(fontSize: 12, letterSpacing: 1.4)),
          const SizedBox(height: 4),
          Text(l10n.settings, style: AppText.display(32)),
          const SizedBox(height: 24),
          SectionHeader(l10n.settingsBackup),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.settingsBackupInfo, style: AppText.body(14, color: AppColors.inkSoft).copyWith(height: 1.45)),
                const SizedBox(height: 14),
                Text(
                  lastExport == null
                      ? l10n.settingsNeverExported
                      : l10n.settingsLastExport(DateFormat.yMMMMd(locale).format(lastExport)),
                  style: AppText.body(13, weight: FontWeight.w600, color: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Text(l10n.settingsDbSize(_formatBytes(size, locale)), style: AppText.body(13, color: AppColors.muted)),
                if (size >= BackupService.sizeWarningBytes) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.scoreLow, borderRadius: BorderRadius.circular(14)),
                    child: Text(l10n.settingsSizeWarning, style: AppText.body(13, weight: FontWeight.w600)),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _busy ? null : _export,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(l10n.settingsExport),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _import,
                  icon: const Icon(Icons.download_rounded),
                  label: Text(l10n.settingsImport),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(l10n.settingsAbout),
          const SizedBox(height: 10),
          AppCard(
            child: Text(
              l10n.settingsAboutBody,
              style: AppText.body(14, color: AppColors.inkSoft).copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatBytes(int bytes, String locale) {
    if (bytes < 1024 * 1024) return '${NumberFormat('0', locale).format(bytes / 1024)} KB';
    return '${NumberFormat('0.0', locale).format(bytes / (1024 * 1024))} MB';
  }
}
