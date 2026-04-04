import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/open_products_service.dart';
import 'add_food_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  String? _lastScannedBarcode;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first.rawValue;
    if (barcode == null || barcode == _lastScannedBarcode) return;

    setState(() {
      _isProcessing = true;
      _lastScannedBarcode = barcode;
    });

    await _controller.stop();

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Produktinformationen werden geladen...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final product = await OpenProductsService().getProductByBarcode(barcode);

    if (mounted) {
      Navigator.of(context).pop(); // Dialog schließen

      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => AddFoodScreen(
            barcode: barcode,
            initialName: product?.name,
            initialBrand: product?.brand,
            initialImageUrl: product?.imageUrl,
            initialCategory: product?.category,
            initialIngredients: product?.ingredients,
            initialProductType: product?.productType,
          ),
        ),
      );

      if (result == true) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isProcessing = false;
          _lastScannedBarcode = null;
        });
        await _controller.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode scannen'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, _) => Icon(
                state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
              ),
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(controller: _controller, onDetect: _onBarcodeDetected),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, size: 48,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('Halte den Barcode in den Rahmen',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'Wird in Lebensmittel-, Kosmetik- und Haushaltsdatenbanken gesucht',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _controller.stop();
          if (mounted) {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const AddFoodScreen(barcode: '')),
            );
            if (result == true) {
              if (mounted) Navigator.of(context).pop(true);
            } else {
              await _controller.start();
            }
          }
        },
        icon: const Icon(Icons.edit),
        label: const Text('Manuell eingeben'),
      ),
    );
  }
}
