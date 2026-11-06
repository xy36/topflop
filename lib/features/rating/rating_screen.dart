import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/product_category.dart';
import '../../core/domain/score.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/category_picker.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/product_image.dart';
import '../../data/db/database.dart';
import '../../data/location/location_service.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../stores/store_form_sheet.dart';

class RatingScreen extends ConsumerStatefulWidget {
  const RatingScreen({super.key, required this.productId, this.ratingId, this.openDetailAfterSave = false});

  final int productId;

  /// Gesetzt: bestehende Bewertung bearbeiten statt eine neue anzulegen.
  final int? ratingId;

  /// Kommt man vom Scanner, geht es nach dem Speichern zur Produktseite.
  final bool openDetailAfterSave;

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  /// Laden gilt als „hier“, wenn er näher als das ist.
  static const _nearbyMeters = 300.0;

  int _score = 7;
  bool _again = true;
  int? _storeId;
  final _price = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;

  LatLon? _position;
  List<(Store, double?)> _stores = const [];
  bool _locationMatched = false;

  bool get _editing => widget.ratingId != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  /// Beim Bearbeiten zuerst die alte Bewertung laden, damit die Vorauswahl
  /// des nächsten Ladens den gespeicherten Laden nicht überschreibt.
  Future<void> _init() async {
    if (_editing) {
      final r = await ref.read(productRepositoryProvider).findRating(widget.ratingId!);
      if (!mounted) return;
      if (r != null) {
        final locale = Localizations.localeOf(context).toString();
        setState(() {
          _score = r.score;
          _again = r.wouldBuyAgain;
          _storeId = r.storeId;
          _price.text = r.priceCents == null
              ? ''
              : formatPrice(r.priceCents!, locale).replaceAll(RegExp(r'[^0-9.,]'), '');
          _note.text = r.note ?? '';
        });
      }
    }
    await _loadStores();
  }

  @override
  void dispose() {
    _price.dispose();
    _note.dispose();
    super.dispose();
  }

  /// Läden nach Entfernung sortieren und den nächsten vorauswählen.
  Future<void> _loadStores({int? select}) async {
    final stores = await ref.read(storeRepositoryProvider).allStores();
    if (!mounted) return;
    // Läden sofort zeigen; der Standort kann (z. B. nach dem Start) dauern.
    if (_position == null) {
      setState(() {
        _stores = [for (final s in stores) (s, null)]..sort((a, b) => a.$1.name.compareTo(b.$1.name));
        if (select != null) _storeId = select;
      });
    }
    final position = _position ?? await ref.read(currentPositionProvider.future);
    double? distance(Store s) =>
        position == null || s.latitude == null ? null : position.distanceTo(s.latitude!, s.longitude!);

    final sorted = [for (final s in stores) (s, distance(s))]
      ..sort((a, b) => (a.$2 ?? double.infinity).compareTo(b.$2 ?? double.infinity));
    if (!mounted) return;
    setState(() {
      _position = position;
      _stores = sorted;
      if (select != null) {
        _storeId = select;
      } else if (!_editing &&
          _storeId == null &&
          sorted.isNotEmpty &&
          (sorted.first.$2 ?? double.infinity) < _nearbyMeters) {
        _storeId = sorted.first.$1.id;
        _locationMatched = true;
      }
    });
  }

  void _setScore(int value) {
    if (value == _score) return;
    HapticFeedback.selectionClick();
    setState(() => _score = value);
  }

  Future<void> _addStore() async {
    final id = await showStoreForm(context, latitude: _position?.latitude, longitude: _position?.longitude);
    if (id != null) await _loadStores(select: id);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final note = _note.text.trim();
    final repo = ref.read(productRepositoryProvider);
    if (_editing) {
      await repo.updateRating(
        widget.ratingId!,
        score: _score,
        wouldBuyAgain: _again,
        storeId: _storeId,
        priceCents: parsePriceCents(_price.text),
        note: note.isEmpty ? null : note,
      );
      if (mounted) context.pop();
      return;
    }
    await repo.addRating(
      productId: widget.productId,
      score: _score,
      wouldBuyAgain: _again,
      storeId: _storeId,
      priceCents: parsePriceCents(_price.text),
      note: note.isEmpty ? null : note,
      latitude: _position?.latitude,
      longitude: _position?.longitude,
    );
    if (!mounted) return;
    if (widget.openDetailAfterSave) {
      context.pushReplacement('/product/${widget.productId}');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final product = ref.watch(productProvider(widget.productId)).value?.product;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  SquareIconButton(icon: Icons.close_rounded, tooltip: l10n.cancel, onPressed: () => context.pop()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editing ? l10n.ratingEditTitle : l10n.ratingTitle,
                          style: AppText.body(12, weight: FontWeight.w600, color: AppColors.muted),
                        ),
                        Text(
                          [product?.name, product?.brand].whereType<String>().join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(16, weight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  if (product != null) ...[_CategoryRow(product: product), const SizedBox(height: 14)],
                  _ScoreCard(score: _score, onChanged: _setScore),
                  const SizedBox(height: 14),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.ratingBuyAgainQuestion, style: AppText.body(15, weight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        _BuyAgainToggle(
                          value: _again,
                          yesLabel: l10n.ratingYes,
                          noLabel: l10n.ratingNo,
                          onChanged: (v) => setState(() => _again = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(l10n.ratingWhere, style: AppText.body(15, weight: FontWeight.w700)),
                            ),
                            if (_locationMatched)
                              Row(
                                children: [
                                  const Icon(Icons.place_outlined, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.ratingLocationFound,
                                    style: AppText.body(12, weight: FontWeight.w600, color: AppColors.primary),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final (store, distance) in _stores.take(6))
                              PillChip(
                                dark: false,
                                label: store.name,
                                trailing: distance == null ? null : formatDistance(distance, locale),
                                selected: _storeId == store.id,
                                onTap: () => setState(() => _storeId = _storeId == store.id ? null : store.id),
                              ),
                            _DashedButton(label: '+ ${l10n.ratingOtherStore}', onTap: _addStore),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _OptionalLabel(l10n.ratingPrice, l10n.optional)),
                            SizedBox(
                              width: 120,
                              child: TextField(
                                controller: _price,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                                textAlign: TextAlign.right,
                                style: AppText.body(16, weight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: '0,00',
                                  suffixText: '€',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _OptionalLabel(l10n.ratingNote, l10n.optional),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _note,
                          minLines: 3,
                          maxLines: 6,
                          textCapitalization: TextCapitalization.sentences,
                          style: AppText.body(15).copyWith(height: 1.4),
                          decoration: InputDecoration(hintText: l10n.ratingNoteHint),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.paddingOf(context).bottom + 16),
        child: FilledButton(onPressed: _saving ? null : _save, child: Text(l10n.ratingSave)),
      ),
    );
  }
}

/// Zeigt die (meist von Open Food Facts geratene) Kategorie und lässt sie
/// direkt nach dem Scannen ändern.
class _CategoryRow extends ConsumerWidget {
  const _CategoryRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final category = ProductCategory.fromName(product.category);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final picked = await showCategoryPicker(context, category);
          if (picked != null && picked != category) {
            await ref.read(productRepositoryProvider).setCategory(product.id, picked);
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
          child: Row(
            children: [
              ProductImage(category: category, size: 40, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.productFormCategory,
                      style: AppText.body(12, weight: FontWeight.w600, color: AppColors.muted),
                    ),
                    Text(category.label(l10n), style: AppText.body(15, weight: FontWeight.w700)),
                  ],
                ),
              ),
              Text(
                l10n.change,
                style: AppText.body(14, weight: FontWeight.w700, color: AppColors.primary),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Großes Emoji, Zahl, Wort und ein einrastender Slider (1–10) mit Zahlenleiste.
class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score, required this.onChanged});

  final int score;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween(begin: 0.7, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(Score.emoji(score), key: ValueKey(score), style: const TextStyle(fontSize: 76, height: 1)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$score', style: AppText.display(44, weight: FontWeight.w800)),
              const SizedBox(width: 6),
              Text(
                '/ 10',
                style: AppText.body(16, weight: FontWeight.w600, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            Score.word(l10n, score),
            style: AppText.body(16, weight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 10,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.lime.withValues(alpha: 0.4),
              thumbShape: const _RingThumb(),
              tickMarkShape: SliderTickMarkShape.noTickMark,
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              min: Score.min.toDouble(),
              max: Score.max.toDouble(),
              divisions: Score.max - Score.min,
              value: score.toDouble(),
              semanticFormatterCallback: (v) => l10n.ratingTick(v.round()),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Row(
            children: [
              for (var n = Score.min; n <= Score.max; n++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Semantics(
                      button: true,
                      selected: n == score,
                      label: l10n.ratingTick(n),
                      excludeSemantics: true,
                      child: Material(
                        color: n == score ? AppColors.ink : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => onChanged(n),
                          child: SizedBox(
                            height: 44,
                            child: Center(
                              child: Text(
                                '$n',
                                style: AppText.body(
                                  14,
                                  weight: n == score ? FontWeight.w700 : FontWeight.w600,
                                  color: n == score ? AppColors.lime : AppColors.muted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Grüner Daumen mit weißem Ring wie im Entwurf.
class _RingThumb extends SliderComponentShape {
  const _RingThumb();

  static const _radius = 16.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas
      ..drawCircle(
        center + const Offset(0, 2),
        _radius,
        Paint()
          ..color = AppColors.ink.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      ..drawCircle(center, _radius, Paint()..color = Colors.white)
      ..drawCircle(center, _radius - 4, Paint()..color = AppColors.primary);
  }
}

class _BuyAgainToggle extends StatelessWidget {
  const _BuyAgainToggle({required this.value, required this.yesLabel, required this.noLabel, required this.onChanged});

  final bool value;
  final String yesLabel;
  final String noLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment(bool option, IconData icon, String label, Color activeBg) {
      final active = value == option;
      return Expanded(
        child: Semantics(
          button: true,
          selected: active,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 46,
            decoration: BoxDecoration(
              color: active ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: active
                  ? [BoxShadow(color: AppColors.ink.withValues(alpha: 0.15), blurRadius: 3, offset: const Offset(0, 1))]
                  : null,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChanged(option),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: active ? Colors.white : const Color(0xFF3E4A42)),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppText.body(
                      15,
                      weight: FontWeight.w700,
                      color: active ? Colors.white : const Color(0xFF3E4A42),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          segment(true, Icons.check_rounded, yesLabel, AppColors.primary),
          const SizedBox(width: 8),
          segment(false, Icons.close_rounded, noLabel, AppColors.ink),
        ],
      ),
    );
  }
}

class _OptionalLabel extends StatelessWidget {
  const _OptionalLabel(this.label, this.optional);

  final String label;
  final String optional;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: AppText.body(15, weight: FontWeight.w700),
          ),
          TextSpan(
            text: ' $optional',
            style: AppText.body(15, weight: FontWeight.w500, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _DashedButton extends StatelessWidget {
  const _DashedButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFB9C0B2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        // Row statt `alignment`, sonst wird der Knopf im Wrap volle Breite.
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppText.body(14, weight: FontWeight.w600, color: const Color(0xFF3E4A42)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
