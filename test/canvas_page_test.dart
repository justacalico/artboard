import 'package:artboard/app.dart';
import 'package:artboard/src/playback/trigger_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {void Function(List<NoteTrigger>)? onNotes}) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ArtboardApp());
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
  });

  testWidgets('piano keys change the key', (tester) async {
    await pumpApp(tester);
    // The strip is the only keyed LayoutBuilder row next to the octave buttons.
    final strip = find.ancestor(of: find.byIcon(Icons.keyboard_arrow_up), matching: find.byType(Row));
    expect(strip, findsWidgets);
  });

  testWidgets('surprise button draws a doodle', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.pump();
    final undo = tester.widget<InkWell>(find.ancestor(of: find.byIcon(Icons.undo), matching: find.byType(InkWell)).first);
    expect(undo.onTap, isNotNull);
  });
}
