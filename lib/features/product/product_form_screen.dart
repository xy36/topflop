import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/product_category.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/category_picker.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// Create a product manually – when Open Food Facts doesn't know it or it
/// has no barcode (deli counter, farmers' market …).
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.barcode});

  final String? barcode;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _quantity = TextEditingController();
  ProductCategory _category = ProductCategory.other;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _quantity.dispose();
    super.dispose();
  }

  String? _trimmed(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final id = await ref
        .read(productRepositoryProvider)
        .createManual(
          name: _name.text.trim(),
          brand: _trimmed(_brand),
          quantity: _trimmed(_quantity),
          barcode: widget.barcode,
          category: _category,
        );
    if (mounted) context.pushReplacement('/product/$id/rate?then=detail');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                children: [
                  SquareIconButton(icon: Icons.close_rounded, tooltip: l10n.cancel, onPressed: () => context.pop()),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.productFormTitle, style: AppText.display(24))),
                ],
              ),
              if (widget.barcode != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.scanDetected(widget.barcode!),
                  style: AppText.body(13, weight: FontWeight.w600, color: context.colors.muted),
                ),
              ],
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(labelText: l10n.productFormName),
                      validator: (v) => v == null || v.trim().isEmpty ? l10n.productFormNameRequired : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _brand,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(labelText: '${l10n.productFormBrand} ${l10n.optional}'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _quantity,
                      decoration: InputDecoration(labelText: '${l10n.productFormQuantity} ${l10n.optional}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SectionHeader(l10n.productFormCategory),
              const SizedBox(height: 10),
              CategoryGrid(selected: _category, onSelected: (c) => setState(() => _category = c)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colors.background,
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom + 16,
        ),
        child: FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.continueToRating)),
      ),
    );
  }
}
