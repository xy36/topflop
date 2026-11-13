// Renders the app icon and splash logo as PNG to assets/brand/ and the
// Play Store graphics to store/play/.
//
//   fvm flutter test tool/render_brand_assets.dart
//   fvm dart run flutter_launcher_icons
//   fvm dart run flutter_native_splash:create
//
// The fonts for the store graphic live in tool/fonts/ (SIL Open Font License).
//
// Motif: a price tag (supermarket shelf) with an arrow pointing up – "Top".

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:topflop/core/theme/app_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Markenassets rendern', () async {
    final dir = Directory('assets/brand')..createSync(recursive: true);

    // iOS / legacy Android: full bleed, without transparency.
    await _render('${dir.path}/icon.png', 1024, background: AppPalette.light.primary, tagScale: 0.62);
    // Android adaptive icon: flutter_launcher_icons adds a 16 % margin,
    // which puts the tag inside the safe zone (middle 66 %).
    await _render('${dir.path}/icon_foreground.png', 1024, tagScale: 0.62);
    // Android 13 themed icons: monochrome.
    await _render('${dir.path}/icon_monochrome.png', 1024, tagScale: 0.62, tagColor: Colors.white);
    // Splash: logo centred, generous margin (Android 12 crops to a circle).
    await _render('${dir.path}/splash_logo.png', 1152, tagScale: 0.42);
  });

  test('Play-Store-Grafiken rendern', () async {
    final dir = Directory('store/play')..createSync(recursive: true);

    // App icon for the store listing: 512 × 512, full bleed; Google Play
    // applies the rounding itself.
    await _render('${dir.path}/icon_512.png', 512, background: AppPalette.light.primary, tagScale: 0.62);

    // Feature graphic: 1024 × 500, Play requires it without alpha channel.
    await _loadFont('Bricolage', 'tool/fonts/BricolageGrotesque_800.ttf');
    await _loadFont('Figtree', 'tool/fonts/Figtree_600.ttf');
    await _featureGraphic('${dir.path}/feature_graphic.png');
  });
}

Future<void> _loadFont(String family, String path) async {
  final loader = FontLoader(family)..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await loader.load();
}

Future<void> _featureGraphic(String path) async {
  const w = 1024.0, h = 500.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(const Rect.fromLTWH(0, 0, w, h), Paint()..color = AppPalette.light.primary);

  // Large, cropped tag as background motif on the right.
  canvas
    ..save()
    ..translate(w - 170, h / 2 + 20);
  _paintTag(canvas, 500, AppColors.lime);
  canvas.restore();

  TextPainter text(String s, TextStyle style) => TextPainter(
    text: TextSpan(text: s, style: style),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: 500);

  final title = text(
    'TopFlop',
    const TextStyle(fontFamily: 'Bricolage', fontSize: 112, height: 1, color: Colors.white, letterSpacing: -2),
  );
  final tagline = text(
    'Merk dir, was im Supermarkt top war – und was flop.',
    TextStyle(fontFamily: 'Figtree', fontSize: 32, height: 1.3, color: Colors.white.withValues(alpha: 0.82)),
  );
  const left = 72.0;
  final top = (h - title.height - 28 - tagline.height) / 2;
  title.paint(canvas, Offset(left, top));
  tagline.paint(canvas, Offset(left, top + title.height + 28));

  final image = await recorder.endRecording().toImage(w.toInt(), h.toInt());
  final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final rgb = img.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: rgba!.buffer,
    numChannels: 4,
  ).convert(numChannels: 3);
  File(path).writeAsBytesSync(img.encodePng(rgb));
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

  canvas
    ..save()
    ..translate(s / 2, s / 2);
  _paintTag(canvas, s * tagScale, tagColor);
  canvas.restore();

  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// Draws the price tag with hole and arrow, centred on the origin;
/// [width] is the width of the unrotated tag.
void _paintTag(Canvas canvas, double width, Color tagColor) {
  // Tag on its own layer so that the hole and arrow can be cut out.
  canvas.saveLayer(null, Paint());
  canvas.rotate(-14 * math.pi / 180);
  canvas.scale(width / 520);
  // Tag coordinates: 0..520 x 0..340, centre shifted slightly right so
  // that the visual weight (body rather than tip) looks centred.
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

  // Rotate the arrow against the tag's tilt: it always points straight up.
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
}
