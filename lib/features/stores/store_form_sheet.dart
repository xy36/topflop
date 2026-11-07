import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/store_repository.dart';
import '../../l10n/app_localizations.dart';

/// Öffnet das Formular für einen neuen Laden – oder, mit [existing], zum
/// Umbenennen. Gibt es den Laden (die Kette) schon, wird kein zweiter
/// angelegt. Liefert die ID des Ladens oder `null`.
Future<int?> showStoreForm(BuildContext context, {Store? existing}) {
  return showModalBottomSheet<int>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => _StoreForm(existing: existing),
  );
}

class _StoreForm extends ConsumerStatefulWidget {
  const _StoreForm({this.existing});

  final Store? existing;

  @override
  ConsumerState<_StoreForm> createState() => _StoreFormState();
}

class _StoreFormState extends ConsumerState<_StoreForm> {
  late final _name = TextEditingController(text: widget.existing?.name);
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);

    final repo = ref.read(storeRepositoryProvider);
    final int id;
    if (_editing) {
      id = widget.existing!.id;
      await repo.renameStore(id, name);
    } else {
      id = await repo.addStore(name: name);
    }
    if (mounted) Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chains = ref.watch(storeSummariesProvider).value?.map((s) => s.store).toList() ?? const <Store>[];
    final typedKey = StoreRepository.chainKey(_name.text);
    final matchingChain = _editing || typedKey.isEmpty
        ? null
        : chains.where((c) => StoreRepository.chainKey(c.name) == typedKey).firstOrNull;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(_editing ? l10n.storeEditTitle : l10n.storesAdd, style: AppText.display(24)),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: !_editing,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.storeFormName, hintText: l10n.storeFormNameHint),
            onChanged: (_) => setState(() {}),
          ),
          // Schnellauswahl vorhandener Ketten, damit kein zweiter „Lidl“ entsteht.
          if (!_editing && chains.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in chains)
                  PillChip(
                    label: c.name,
                    dark: false,
                    selected: matchingChain?.id == c.id,
                    onTap: () => setState(() => _name.text = c.name),
                  ),
              ],
            ),
          ],
          if (matchingChain != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.storeFormExists(matchingChain.name),
                    style: AppText.body(13, weight: FontWeight.w600, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          const SizedBox(height: 6),
          FilledButton(
            onPressed: _name.text.trim().isEmpty || _saving ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
