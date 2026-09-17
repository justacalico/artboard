import 'dart:io';
import 'dart:typed_data';

import 'package:artboard/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

File _findIconFont() {
  const relative = 'bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
  var dir = File(Platform.resolvedExecutable).parent;
  while (true) {
    final candidate = File('${dir.path}/$relative');
    if (candidate.existsSync()) return candidate;
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('MaterialIcons-Regular.otf not found above ${Platform.resolvedExecutable}');
    }
    dir = parent;
  }
}

Future<void> _loadFonts() async {
  final quicksand = await File('assets/fonts/Quicksand.ttf').readAsBytes();
  final icons = await _findIconFont().readAsBytes();
  final loader = FontLoader('Quicksand')
    ..addFont(Future.value(ByteData.sublistView(quicksand)));
  final iconLoader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.sublistView(icons)));
  await loader.load();
  await iconLoader.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadFonts);

  Future<void> pump(WidgetTester tester, {Locale? locale}) async {
    tester.view.physicalSize = const Size(430, 930);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(ArtboardApp(locale: locale));
    await tester.pump();
  }

  Future<void> drawPolyline(WidgetTester tester, Offset start, List<Offset> moves) async {
    final gesture = await tester.startGesture(start);
    for (final point in moves) {
      await gesture.moveTo(point);
      await tester.pump(const Duration(milliseconds: 8));
    }
    await gesture.up();
    await tester.pump();
  }

  Offset canvasPoint(WidgetTester tester, double fx, double fy) {
    final rect = tester.getRect(find.byType(ClipRRect));
    return Offset(rect.left + rect.width * fx, rect.top + rect.height * fy);
  }

  Future<void> drawScene(WidgetTester tester) async {
    // Purple mug body.
    await drawPolyline(tester, canvasPoint(tester, 0.22, 0.42), [
      canvasPoint(tester, 0.20, 0.55),
      canvasPoint(tester, 0.22, 0.85),
      canvasPoint(tester, 0.55, 0.88),
      canvasPoint(tester, 0.78, 0.85),
      canvasPoint(tester, 0.80, 0.55),
      canvasPoint(tester, 0.78, 0.42),
    ]);
    // Mug rim.
    await drawPolyline(tester, canvasPoint(tester, 0.22, 0.42), [
      canvasPoint(tester, 0.50, 0.38),
      canvasPoint(tester, 0.78, 0.42),
      canvasPoint(tester, 0.50, 0.46),
      canvasPoint(tester, 0.22, 0.42),
    ]);
    // Handle.
    await drawPolyline(tester, canvasPoint(tester, 0.79, 0.50), [
      canvasPoint(tester, 0.95, 0.50),
      canvasPoint(tester, 0.97, 0.62),
      canvasPoint(tester, 0.90, 0.70),
      canvasPoint(tester, 0.79, 0.72),
    ]);
    // Red heart on the mug.
    await tester.tap(find.byWidgetPredicate(
      (w) => w is Container && w.decoration is BoxDecoration && w.constraints?.maxWidth == 36,
    ).at(1));
    await tester.pump();
    await drawPolyline(tester, canvasPoint(tester, 0.42, 0.60), [
      canvasPoint(tester, 0.38, 0.55),
      canvasPoint(tester, 0.42, 0.52),
      canvasPoint(tester, 0.50, 0.54),
      canvasPoint(tester, 0.58, 0.52),
      canvasPoint(tester, 0.62, 0.55),
      canvasPoint(tester, 0.50, 0.72),
      canvasPoint(tester, 0.42, 0.60),
    ]);
  }

  testWidgets('empty app', (tester) async {
    await pump(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/app_empty.png'));
  });

  testWidgets('drawing being played', (tester) async {
    await pump(tester);
    await drawScene(tester);
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    for (var i = 0; i < 45; i++) {
      await tester.pump(const Duration(milliseconds: 32));
    }
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/app_playing.png'));
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
  });

  testWidgets('chinese locale', (tester) async {
    await pump(tester, locale: const Locale('zh'));
    await tester.tap(find.byIcon(Icons.question_mark));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/app_zh_help.png'));
  });
}
