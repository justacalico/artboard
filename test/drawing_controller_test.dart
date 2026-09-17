import 'dart:math';
import 'dart:ui' show Size;

import 'package:artboard/src/drawing/drawing_controller.dart';
import 'package:artboard/src/drawing/palette.dart';
import 'package:artboard/src/music/pitch_mapper.dart';
import 'package:artboard/src/music/scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DrawingController', () {
    test('a drag produces a stroke on the active layer', () {
      final c = DrawingController();
      c.beginStroke(const Offset(10, 10));
      c.extendStroke(const Offset(20, 20));
      c.extendStroke(const Offset(30, 20));
      c.endStroke();
      expect(c.layers[0], hasLength(1));
      expect(c.layers[0].single.points, hasLength(3));
      expect(c.draft, isNull);
    });

    test('draft is visible while drawing', () {
      final c = DrawingController();
      c.beginStroke(const Offset(10, 10));
      c.extendStroke(const Offset(20, 20));
      expect(c.draft, isNotNull);
      c.endStroke();
    });

    test('tap leaves a single dot stroke', () {
      final c = DrawingController();
      c.beginStroke(const Offset(10, 10));
      c.endStroke();
      expect(c.layers[0].single.points, hasLength(1));
    });

    test('tiny moves do not grow the draft', () {
      final c = DrawingController();
      c.beginStroke(const Offset(10, 10));
      c.extendStroke(const Offset(10.5, 10.5));
      expect(c.draft!.points, hasLength(1));
      c.endStroke();
    });

    test('eraser removes a single dot stroke', () {
      final c = DrawingController();
      c.beginStroke(const Offset(50, 50));
      c.endStroke();
      expect(c.layers[0], hasLength(1));
      c.selectTool(DrawTool.eraser);
      c.beginStroke(const Offset(52, 52));
      expect(c.isEmpty, isTrue);
    });

    test('eraser keeps working while dragging', () {
      final c = DrawingController();
      c.beginStroke(const Offset(10, 50));
      c.extendStroke(const Offset(90, 50));
      c.endStroke();
      c.selectTool(DrawTool.eraser);
      c.beginStroke(const Offset(5, 90));
      expect(c.layers[0], hasLength(1));
      c.extendStroke(const Offset(50, 50));
      expect(c.isEmpty, isTrue);
    });

    test('endStroke without a draft is a no-op', () {
      final c = DrawingController();
      c.endStroke();
      expect(c.isEmpty, isTrue);
    });

    test('undo removes the last stroke', () {
      final c = DrawingController();
      c.beginStroke(const Offset(10, 10));
      c.extendStroke(const Offset(20, 20));
      c.endStroke();
      expect(c.canUndo, isTrue);
      c.undo();
      expect(c.isEmpty, isTrue);
      expect(c.canUndo, isFalse);
    });

    test('undo on empty history is a no-op', () {
      final c = DrawingController();
      c.undo();
      expect(c.isEmpty, isTrue);
    });

    test('eraser removes strokes it touches', () {
      final c = DrawingController();
      c.selectTool(DrawTool.pen);
      c.beginStroke(const Offset(10, 50));
      c.extendStroke(const Offset(90, 50));
      c.endStroke();
      c.selectTool(DrawTool.eraser);
      c.beginStroke(const Offset(50, 50));
      expect(c.isEmpty, isTrue);
    });

    test('eraser keeps strokes it misses', () {
      final c = DrawingController();
      c.beginStroke(const Offset(10, 10));
      c.extendStroke(const Offset(90, 10));
      c.endStroke();
      c.selectTool(DrawTool.eraser);
      c.beginStroke(const Offset(50, 80));
      expect(c.layers[0], hasLength(1));
    });

    test('undo after erase restores the strokes', () {
      final c = DrawingController();
      c.beginStroke(const Offset(10, 50));
      c.extendStroke(const Offset(90, 50));
      c.endStroke();
      c.selectTool(DrawTool.eraser);
      c.beginStroke(const Offset(50, 50));
      c.undo();
      expect(c.layers[0], hasLength(1));
    });

    test('layers keep strokes separate', () {
      final c = DrawingController();
      c.beginStroke(const Offset(10, 10));
      c.extendStroke(const Offset(20, 20));
      c.endStroke();
      c.selectLayer(1);
      c.beginStroke(const Offset(30, 30));
      c.extendStroke(const Offset(40, 40));
      c.endStroke();
      expect(c.layers[0], hasLength(1));
      expect(c.layers[1], hasLength(1));
      expect(c.layers[2], isEmpty);
      expect(c.allStrokes, hasLength(2));
    });

    test('clearAll wipes strokes and history', () {
      final c = DrawingController();
      c.beginStroke(const Offset(10, 10));
      c.extendStroke(const Offset(20, 20));
      c.endStroke();
      c.clearAll();
      expect(c.isEmpty, isTrue);
      expect(c.canUndo, isFalse);
    });

    test('selections update tool, colour and width', () {
      final c = DrawingController();
      c.selectColor(kStrokeColors[4].toARGB32());
      c.selectWidth(kStrokeWidths[2]);
      c.selectTool(DrawTool.eraser);
      c.selectLayer(2);
      expect(c.colorValue, kStrokeColors[4].toARGB32());
      expect(c.strokeWidth, kStrokeWidths[2]);
      expect(c.tool, DrawTool.eraser);
      expect(c.activeLayer, 2);
    });

    test('reselecting the same values does not notify', () {
      final c = DrawingController();
      var notified = 0;
      c.addListener(() => notified++);
      c.selectLayer(0);
      c.selectTool(DrawTool.pen);
      c.selectColor(c.colorValue);
      c.selectWidth(c.strokeWidth);
      expect(notified, 0);
    });

    test('doodle adds strokes snapped to the key', () {
      final c = DrawingController();
      final mapper = PitchMapper(scale: ScaleType.major);
      c.doodle(Random(7), mapper, const Size(400, 300));
      expect(c.isEmpty, isFalse);
      for (final stroke in c.allStrokes) {
        for (final p in stroke.points) {
          expect(p.dx, inInclusiveRange(0, 400));
          expect(p.dy, inInclusiveRange(0, 300));
        }
      }
    });

    test('json round trip rebuilds every layer', () {
      final c = DrawingController();
      c.beginStroke(const Offset(10, 10));
      c.extendStroke(const Offset(20, 20));
      c.endStroke();
      c.selectLayer(1);
      c.selectColor(kStrokeColors[1].toARGB32());
      c.beginStroke(const Offset(5, 5));
      c.extendStroke(const Offset(15, 15));
      c.endStroke();

      final restored = DrawingController()..loadJson(c.toJson());
      expect(restored.layers[0].single.points, c.layers[0].single.points);
      expect(restored.layers[1].single.colorValue, kStrokeColors[1].toARGB32());
      expect(restored.layers[2], isEmpty);
    });
  });
}
