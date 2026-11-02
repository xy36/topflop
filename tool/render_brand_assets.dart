// Rendert App-Icon und Splash-Logo als PNG nach assets/brand/.
//
//   flutter test tool/render_brand_assets.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// Motiv: ein Preisschild (Supermarktregal) mit einem Pfeil nach oben – „Top“.

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:topflop/core/theme/app_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Markenassets rendern', () async {
    final dir = Directory('assets/brand')..createSync(recursive: true);

    // iOS / Legacy-Android: vollflächig, ohne Transparenz.
    await _render('${dir.path}/icon.png', 1024, background: AppColors.primary, tagScale: 0.62);
    // Android Adaptive Icon: flutter_launcher_icons legt 16 % Rand herum,
    // damit landet das Schild im sicheren Bereich (mittlere 66 %).
    await _render('${dir.path}/icon_foreground.png', 1024, tagScale: 0.62);
    // Android 13 „Themed Icons“: einfarbig.
    await _render('${dir.path}/icon_monochrome.png', 1024, tagScale: 0.62, tagColor: Colors.white);
    // Splash: Logo mittig, viel Rand (Android 12 schneidet kreisförmig zu).
    await _render('${dir.path}/splash_logo.png', 1152, tagScale: 0.42);
  });
}

Future<void> _render(
  String path,
  int size, {
  Color? background,
  required double tagScale,
  Color tagColor = AppColors.lime,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final s = size.toDouble();

  if (background != null) canvas.drawRect(Rect.fromLTWH(0, 0, s, s), Paint()..color = background);

  // Schild in eigener Ebene, damit Loch und Pfeil ausgestanzt werden können.
  canvas.saveLayer(Rect.fromLTWH(0, 0, s, s), Paint());
  canvas.translate(s / 2, s / 2);
  canvas.rotate(-14 * math.pi / 180);
  final scale = s * tagScale / 520;
  canvas.scale(scale);
  // Schildkoordinaten: 0..520 x 0..340, Mittelpunkt leicht nach rechts, damit
  // das optische Gewicht (Körper statt Spitze) zentriert wirkt.
  canvas.translate(-275, -170);

  final body = Path()
    ..moveTo(20, 170)
    ..lineTo(150, 20)
    ..lineTo(500, 20)
    ..lineTo(500, 320)
    ..lineTo(150, 320)
    ..close();
  canvas
    ..drawPath(body, Paint()..color = tagColor)
    ..drawPath(
      body,
      Paint()
        ..color = tagColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40
        ..strokeJoin = StrokeJoin.round,
    );

  canvas.drawCircle(const Offset(128, 170), 30, Paint()..blendMode = BlendMode.clear);

  // Pfeil gegen die Schildneigung drehen: zeigt immer senkrecht nach oben.
  canvas
    ..save()
    ..translate(335, 172)
    ..rotate(14 * math.pi / 180)
    ..drawPath(
      Path()
        ..moveTo(-82, 46)
        ..lineTo(0, -40)
        ..lineTo(82, 46),
      Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.stroke
        ..strokeWidth = 56
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    )
    ..restore();
  canvas.restore();

  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}
