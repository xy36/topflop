import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/db/database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Öffnet das Formular für einen neuen Laden – oder, mit [existing], zum
/// Bearbeiten eines vorhandenen. Liefert die ID oder `null`.
Future<int?> showStoreForm(
  BuildContext context, {
  Store? existing,
  String? initialName,
  String? initialAddress,
  double? latitude,
  double? longitude,
}) {
  return showModalBottomSheet<int>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => _StoreForm(
      existing: existing,
      initialName: initialName ?? existing?.name,
      initialAddress: initialAddress ?? existing?.address,
      latitude: latitude,
      longitude: longitude,
    ),
  );
}

class _StoreForm extends ConsumerStatefulWidget {
  const _StoreForm({this.existing, this.initialName, this.initialAddress, this.latitude, this.longitude});

  final Store? existing;
  final String? initialName;
  final String? initialAddress;
  final double? latitude;
  final double? longitude;

  @override
  ConsumerState<_StoreForm> createState() => _StoreFormState();
}

class _StoreFormState extends ConsumerState<_StoreForm> {
  late final _name = TextEditingController(text: widget.initialName);
  late final _address = TextEditingController(text: widget.initialAddress);

  /// Beim Bearbeiten bleibt der gespeicherte Standort, solange man ihn nicht bewusst ersetzt.
  late bool _useLocation = widget.existing == null;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);

    double? lat = widget.latitude;
    double? lon = widget.longitude;
    if (_useLocation && lat == null) {
      final pos = await ref.read(currentPositionProvider.future);
      lat = pos?.latitude;
      lon = pos?.longitude;
    }
    final address = _address.text.trim();
    final existing = widget.existing;
    if (existing != null) {
      await ref
          .read(storeRepositoryProvider)
          .updateStore(
            existing.id,
            name: name,
            address: address.isEmpty ? null : address,
            latitude: _useLocation ? lat : existing.latitude,
            longitude: _useLocation ? lon : existing.longitude,
          );
      if (mounted) Navigator.pop(context, existing.id);
      return;
    }
    final id = await ref
        .read(storeRepositoryProvider)
        .addStore(
          name: name,
          address: address.isEmpty ? null : address,
          latitude: _useLocation ? lat : null,
          longitude: _useLocation ? lon : null,
        );
    if (mounted) Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          Text(widget.existing == null ? l10n.storesAdd : l10n.storeEditTitle, style: AppText.display(24)),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: widget.initialName == null,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.storeFormName),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _address,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.storeFormAddress),
          ),
          const SizedBox(height: 6),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _useLocation,
            activeTrackColor: AppColors.primary,
            onChanged: (v) => setState(() => _useLocation = v),
            title: Text(
              widget.existing == null ? l10n.storeFormUseLocation : l10n.storeFormUpdateLocation,
              style: AppText.body(15, weight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
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
