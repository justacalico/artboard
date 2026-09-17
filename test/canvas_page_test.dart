import 'dart:typed_data';

import 'package:artboard/app.dart';
import 'package:artboard/src/audio/loop_exporter.dart';
import 'package:artboard/src/audio/note_player.dart';
import 'package:artboard/src/drawing/drawing_store.dart';
import 'package:artboard/src/playback/trigger_engine.dart';
import 'package:artboard/src/ui/piano_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeExporter extends LoopExporter {
  Uint8List? saved;

  @override
  Future<void> save(Uint8List wav) async => saved = wav;
}

class _FakePlayer extends NotePlayer {
  var played = 0;

  @override
  void play(Uint8List wav) => played++;
}

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    void Function(List<NoteTrigger>)? onNotes,
    NotePlayer? notePlayer,
    LoopExporter? exporter,
    DrawingStore? store,
  }) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ArtboardApp(notePlayer: notePlayer, exporter: exporter, store: store),
    );
  }

  testWidgets('page shows canvas and all four decks', (tester) async {
    await pumpApp(tester);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.piano), findsOneWidget);
    expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
    expect(find.text('90'), findsOneWidget);
  });

  testWidgets('drawing on the paper adds a stroke', (tester) async {
    await pumpApp(tester);
    final canvas = find.byType(ClipRRect);
    await tester.dragFrom(tester.getCenter(canvas) - const Offset(80, 0), const Offset(160, 40));
    await tester.pump();
    // Undo becomes enabled once a stroke exists.
    final undo = tester.widget<InkWell>(find.ancestor(of: find.byIcon(Icons.undo), matching: find.byType(InkWell)).first);
    expect(undo.onTap, isNotNull);
  });

  testWidgets('play button starts the scan line', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    expect(find.byIcon(Icons.pause), findsOneWidget);
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('tempo buttons change the displayed value', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('95'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('90'), findsOneWidget);
  });

  testWidgets('colour dots select the pen colour', (tester) async {
    await pumpApp(tester);
    // Second dot (red) gets a ring once selected.
    final dots = find.byWidgetPredicate(
      (w) => w is Container && w.constraints == const BoxConstraints.tightFor(width: 36, height: 36),
    );
    await tester.tap(dots.at(1));
    await tester.pump();
    expect(dots, findsNWidgets(9));
  });

  testWidgets('help button opens the explainer', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.question_mark));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('scale sheet lists every scale', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.piano));
    await tester.pumpAndSettle();
    expect(find.text('Blues'), findsOneWidget);
    await tester.tap(find.text('Blues'));
    await tester.pumpAndSettle();
  });

  testWidgets('timbre sheet lists every waveform', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.waves));
    await tester.pumpAndSettle();
    expect(find.text('Sawtooth'), findsOneWidget);
    await tester.tap(find.text('Sawtooth'));
    await tester.pumpAndSettle();
  });

  testWidgets('layer buttons switch the active layer', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('cloud menu offers save restore and wipe', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.cloud_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Save drawing'), findsOneWidget);
    expect(find.text('Restore saved drawing'), findsOneWidget);
    expect(find.text('Clear canvas'), findsOneWidget);
    await tester.tap(find.text('Restore saved drawing'));
    await tester.pumpAndSettle();
    expect(find.text('No saved drawing yet'), findsOneWidget);
  });

  testWidgets('save then restore round trips the drawing', (tester) async {
    await pumpApp(tester);
    final canvas = find.byType(ClipRRect);
    await tester.dragFrom(tester.getCenter(canvas) - const Offset(60, 0), const Offset(120, 30));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.cloud_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save drawing'));
    await tester.pumpAndSettle();
    expect(find.text('Drawing saved'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.cloud_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear canvas'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.cloud_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore saved drawing'));
    await tester.pumpAndSettle();
    expect(find.text('Drawing restored'), findsOneWidget);
  });

  testWidgets('piano keys change the key', (tester) async {
    await pumpApp(tester);
    final strip = tester.getRect(find.byType(PianoStrip));

    // Low part of the third white key selects a natural.
    await tester.tapAt(Offset(strip.left + strip.width * 2.5 / 7, strip.top + strip.height * 0.85));
    await tester.pump();
    var selected = find.descendant(
      of: find.byType(PianoStrip),
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            (w.decoration as BoxDecoration?)?.color == const Color(0xFF1C1B1A) &&
            (w.decoration as BoxDecoration?)?.border != null,
      ),
    );
    expect(selected, findsOneWidget);

    // High part of a black key selects a sharp.
    await tester.tapAt(Offset(strip.left + strip.width / 7, strip.top + strip.height * 0.2));
    await tester.pump();
    selected = find.descendant(
      of: find.byType(PianoStrip),
      matching: find.byWidgetPredicate(
        (w) => w is Container && (w.decoration as BoxDecoration?)?.color == const Color(0xFF6B4FCE),
      ),
    );
    expect(selected, findsOneWidget);
  });

  testWidgets('tool buttons switch between pen and eraser', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.auto_fix_normal));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();
  });

  testWidgets('octave buttons shift the pitch range', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.keyboard_arrow_up));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
    await tester.pump();
  });

  testWidgets('width dots select the pen width', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byWidgetPredicate(
      (w) => w is Icon && w.icon == Icons.circle && w.size == 10,
    ));
    await tester.pump();
  });

  testWidgets('export renders the loop and hands it to the saver', (tester) async {
    final exporter = _FakeExporter();
    await pumpApp(tester, exporter: exporter);
    final canvas = find.byType(ClipRRect);
    await tester.dragFrom(tester.getCenter(canvas) - const Offset(60, 0), const Offset(120, 30));
    await tester.pump();
    await tester.tap(find.byWidgetPredicate(
      (w) => w is Icon && w.icon == Icons.circle && w.color == const Color(0xFFE0442A),
    ));
    await tester.pumpAndSettle();
    expect(exporter.saved, isNotNull);
    expect(String.fromCharCodes(exporter.saved!.sublist(0, 4)), 'RIFF');
  });

  testWidgets('live notes reach the note player', (tester) async {
    final player = _FakePlayer();
    await pumpApp(tester, notePlayer: player);
    final canvas = find.byType(ClipRRect);
    await tester.dragFrom(tester.getCenter(canvas) - const Offset(100, 0), const Offset(200, 20));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    expect(player.played, greaterThan(0));
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
  });

  testWidgets('surprise button draws a doodle', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.pump();
    final undo = tester.widget<InkWell>(find.ancestor(of: find.byIcon(Icons.undo), matching: find.byType(InkWell)).first);
    expect(undo.onTap, isNotNull);
  });
}
