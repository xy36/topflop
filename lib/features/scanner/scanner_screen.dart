import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/domain/product_category.dart';
import '../../core/domain/score.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/product_image.dart';
import '../../data/providers.dart';
import '../../data/remote/open_food_facts_client.dart';
import '../../data/repositories/models.dart';
import '../../l10n/app_localizations.dart';

sealed class _ScanState {
  const _ScanState(this.code);
  final String code;
}

class _Looking extends _ScanState {
  const _Looking(super.code);
}

/// Product is already in the local database.
class _Known extends _ScanState {
  const _Known(super.code, this.summary);
  final ProductSummary summary;
}

/// Product comes fresh from Open Food Facts.
class _Remote extends _ScanState {
  const _Remote(super.code, this.product);
  final OffProduct product;
}

class _NotFound extends _ScanState {
  const _NotFound(super.code, {required this.offline});
  final bool offline;
}

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> with SingleTickerProviderStateMixin {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
    ],
  );
  late final AnimationController _scanLine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);
  _ScanState? _state;
  bool _torch = false;

  @override
  void dispose() {
    _scanLine.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
    if (code == null || _state != null) return;
    HapticFeedback.mediumImpact();
    _lookup(code);
  }

  Future<void> _lookup(String code) async {
    setState(() => _state = _Looking(code));
    final repo = ref.read(productRepositoryProvider);
    final known = await repo.findByBarcode(code);
    if (!mounted) return;
    if (known != null) {
      setState(() => _state = _Known(code, known));
      return;
    }
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final off = await ref.read(openFoodFactsProvider).lookup(code, languageCode: lang);
      if (!mounted) return;
      setState(() => _state = off == null ? _NotFound(code, offline: false) : _Remote(code, off));
    } on OffLookupException {
      if (mounted) setState(() => _state = _NotFound(code, offline: true));
    }
  }

  Future<void> _enterCode() async {
    final l10n = AppLocalizations.of(context);
    final input = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.enterCodeTitle),
        content: TextField(
          controller: input,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(hintText: l10n.enterCodeHint),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, input.text), child: Text(l10n.search)),
        ],
      ),
    );
    input.dispose();
    if (code != null && code.trim().isNotEmpty) _lookup(code.trim());
  }

  Future<void> _rateRemote(OffProduct product) async {
    final id = await ref.read(productRepositoryProvider).upsertFromOff(product);
    if (mounted) context.pushReplacement('/product/$id/rate?then=detail');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = _state;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.scannerBackground,
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.cameraUnavailable,
                    textAlign: TextAlign.center,
                    style: AppText.body(15, color: Colors.white70),
                  ),
                ),
              ),
            ),
            // Dimmed overlay with viewfinder frame.
            AnimatedBuilder(
              animation: _scanLine,
              builder: (context, _) => CustomPaint(
                painter: _ViewfinderPainter(progress: _scanLine.value, active: state == null),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final frame = _ViewfinderPainter.frameFor(constraints.biggest);
                return Stack(
                  children: [
                    Positioned(
                      top: frame.bottom + 24,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Text(
                            l10n.scanHint,
                            textAlign: TextAlign.center,
                            style: AppText.body(15, color: Colors.white.withValues(alpha: 0.78)),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _OutlineButton(
                                icon: Icons.dialpad_rounded,
                                label: l10n.scanEnterCode,
                                onPressed: _enterCode,
                              ),
                              _OutlineButton(
                                icon: Icons.edit_outlined,
                                label: l10n.scanWithoutBarcode,
                                onPressed: () => context.pushReplacement('/product/new'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      _GlassButton(icon: Icons.close_rounded, tooltip: l10n.scanClose, onPressed: () => context.pop()),
                      Expanded(
                        child: Text(
                          l10n.scanTitle,
                          textAlign: TextAlign.center,
                          style: AppText.body(16, weight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                      _GlassButton(
                        icon: Icons.flash_on_rounded,
                        tooltip: l10n.scanTorch,
                        active: _torch,
                        onPressed: () async {
                          await _controller.toggleTorch();
                          setState(() => _torch = !_torch);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (state != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: _ResultSheet(
                  state: state,
                  onDismiss: () => setState(() => _state = null),
                  onRateRemote: _rateRemote,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultSheet extends StatelessWidget {
  const _ResultSheet({required this.state, required this.onDismiss, required this.onRateRemote});

  final _ScanState state;
  final VoidCallback onDismiss;
  final ValueChanged<OffProduct> onRateRemote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    final Widget content = switch (state) {
      _Looking() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
            const SizedBox(width: 12),
            Text(l10n.scanLooking, style: AppText.body(15, weight: FontWeight.w600)),
          ],
        ),
      ),
      _Known(:final summary) => _ProductResult(
        name: summary.product.name,
        subtitle: [summary.product.brand, summary.product.quantity].whereType<String>().join(' · '),
        category: ProductCategory.fromName(summary.product.category),
        imageUrl: summary.product.imageUrl,
        verdict: summary.isRated ? _Verdict(summary) : null,
        primaryLabel: summary.isRated ? l10n.ratingChange : l10n.rate,
        onPrimary: () => context.pushReplacement('/product/${summary.product.id}/rate?then=detail'),
        onDetails: () => context.pushReplacement('/product/${summary.product.id}'),
      ),
      _Remote(:final product) => _ProductResult(
        name: product.name,
        subtitle: [product.brand, product.quantity].whereType<String>().join(' · '),
        category: product.category,
        imageUrl: product.imageUrl,
        primaryLabel: l10n.rate,
        onPrimary: () => onRateRemote(product),
      ),
      _NotFound(:final offline) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.scanNotFoundTitle, style: AppText.display(22)),
          const SizedBox(height: 6),
          Text(
            offline ? l10n.scanOffline : l10n.scanNotFoundBody,
            style: AppText.body(14, color: context.colors.muted).copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: onDismiss, child: Text(l10n.scanAgain)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  onPressed: () => context.pushReplacement(
                    Uri(path: '/product/new', queryParameters: {'barcode': state.code}).toString(),
                  ),
                  child: Text(l10n.scanCreateProduct),
                ),
              ),
            ],
          ),
        ],
      ),
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: context.colors.chipBorder, borderRadius: BorderRadius.circular(3)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state is _NotFound ? const Color(0xFFC0632F) : const Color(0xFF2F8A5B),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.scanDetected(state.code),
                style: AppText.body(13, weight: FontWeight.w600, color: context.colors.muted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedSize(duration: const Duration(milliseconds: 200), child: content),
        ],
      ),
    );
  }
}

class _ProductResult extends StatelessWidget {
  const _ProductResult({
    required this.name,
    required this.subtitle,
    required this.category,
    required this.imageUrl,
    required this.primaryLabel,
    required this.onPrimary,
    this.verdict,
    this.onDetails,
  });

  final String name;
  final String subtitle;
  final ProductCategory category;
  final String? imageUrl;
  final Widget? verdict;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ProductImage(category: category, imageUrl: imageUrl, size: 72, radius: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppText.display(22)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppText.body(14, color: context.colors.muted)),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (verdict != null) ...[const SizedBox(height: 16), verdict!],
        const SizedBox(height: 16),
        Row(
          children: [
            if (onDetails != null) ...[
              Expanded(
                child: OutlinedButton(onPressed: onDetails, child: Text(l10n.details)),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: onPrimary,
                child: Text(primaryLabel),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          l10n.dataSourceOff,
          textAlign: TextAlign.center,
          style: AppText.body(12, color: context.colors.muted),
        ),
      ],
    );
  }
}

/// "Already rated" hint – the real value in front of the shelf.
class _Verdict extends StatelessWidget {
  const _Verdict(this.summary);

  final ProductSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final score = summary.score!;
    final again = summary.wouldBuyAgain == true ? l10n.scanLastAgainYes : l10n.scanLastAgainNo;
    final store = summary.storeName;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: summary.wouldBuyAgain == true ? context.colors.limeSoft : context.colors.scoreLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(Score.emoji(score), style: const TextStyle(fontSize: 30, height: 1)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.scanAlreadyRated(score), style: AppText.body(15, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  store == null ? again : '$again · ${l10n.scanLastAt(store)}',
                  style: AppText.body(13, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          if (summary.product.isFavorite)
            Icon(Icons.favorite_rounded, color: context.colors.primary, size: 22, semanticLabel: l10n.favorite),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.tooltip, required this.onPressed, this.active = false});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? AppColors.lime : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 44,
            child: Icon(icon, color: active ? AppColors.onLime : Colors.white, size: 21),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 44),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 18),
      ),
    );
  }
}

/// Dims everything except the viewfinder and draws corners and scan line.
class _ViewfinderPainter extends CustomPainter {
  _ViewfinderPainter({required this.progress, required this.active});

  static const width = 290.0;
  static const height = 190.0;

  final double progress;
  final bool active;

  /// Position of the viewfinder; hint text and buttons align to it.
  static Rect frameFor(Size size) {
    final top = (size.height - height) * 0.36;
    return Rect.fromLTWH((size.width - width) / 2, top, width, height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final frame = frameFor(size);
    final rrect = RRect.fromRectAndRadius(frame, const Radius.circular(18));

    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRRect(rrect)),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    final corner = Paint()
      ..color = AppColors.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const len = 34.0;
    const r = 18.0;
    final l = frame.left, t = frame.top, rt = frame.right, b = frame.bottom;
    canvas
      ..drawPath(
        Path()
          ..moveTo(l, t + len)
          ..lineTo(l, t + r)
          ..arcToPoint(Offset(l + r, t), radius: const Radius.circular(r))
          ..lineTo(l + len, t),
        corner,
      )
      ..drawPath(
        Path()
          ..moveTo(rt - len, t)
          ..lineTo(rt - r, t)
          ..arcToPoint(Offset(rt, t + r), radius: const Radius.circular(r))
          ..lineTo(rt, t + len),
        corner,
      )
      ..drawPath(
        Path()
          ..moveTo(l, b - len)
          ..lineTo(l, b - r)
          ..arcToPoint(Offset(l + r, b), radius: const Radius.circular(r), clockwise: false)
          ..lineTo(l + len, b),
        corner,
      )
      ..drawPath(
        Path()
          ..moveTo(rt - len, b)
          ..lineTo(rt - r, b)
          ..arcToPoint(Offset(rt, b - r), radius: const Radius.circular(r), clockwise: false)
          ..lineTo(rt, b - len),
        corner,
      );

    if (active) {
      final y = frame.top + 20 + (frame.height - 40) * Curves.easeInOut.transform(progress);
      final line = Rect.fromLTWH(frame.left + 18, y, frame.width - 36, 2);
      canvas
        ..drawRect(
          line.inflate(4),
          Paint()
            ..color = AppColors.lime.withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        )
        ..drawRect(line, Paint()..color = AppColors.lime);
    }
  }

  @override
  bool shouldRepaint(_ViewfinderPainter old) => old.progress != progress || old.active != active;
}
