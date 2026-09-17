import 'dart:ui';

import 'package:artboard/src/drawing/stroke.dart';
import 'package:artboard/src/playback/trigger_engine.dart';
import 'package:artboard/src/ui/paper_painter.dart';
import 'package:artboard/src/ui/strokes_painter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PaperPainter never repaints', () {
    const painter = PaperPainter();
    expect(painter.shouldRepaint(const PaperPainter()), isFalse);
  });

  test('StrokesPainter paints strokes, dots and the scan line', () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    const painter = StrokesPainter(
      strokes: [
        Stroke(points: [Offset(0, 0), Offset(50, 50)], colorValue: 0xFF000000, width: 4),
        Stroke(points: [Offset(70, 70)], colorValue: 0xFF123456, width: 6),
        Stroke(points: [], colorValue: 0xFF000000, width: 4),
      ],
      draft: Stroke(points: [Offset(10, 80), Offset(30, 90)], colorValue: 0xFF000000, width: 4),
      playheadX: 25,
      playing: true,
      hits: [ScanHit(point: Offset(25, 25))],
    );
    painter.paint(canvas, const Size(100, 100));
    expect(recorder.endRecording(), isNotNull);
  });

  group('StrokesPainter.shouldRepaint', () {
    const base = StrokesPainter(
      strokes: [],
      draft: null,
      playheadX: 0,
      playing: false,
      hits: [],
    );

    test('identical painter does not repaint', () {
      expect(base.shouldRepaint(base), isFalse);
    });

    test('stroke change repaints', () {
      const other = StrokesPainter(
        strokes: [Stroke(points: [Offset(0, 0)], colorValue: 1, width: 2)],
        draft: null,
        playheadX: 0,
        playing: false,
        hits: [],
      );
      expect(other.shouldRepaint(base), isTrue);
    });

    test('draft change repaints', () {
      const other = StrokesPainter(
        strokes: [],
        draft: Stroke(points: [Offset(0, 0)], colorValue: 1, width: 2),
        playheadX: 0,
        playing: false,
        hits: [],
      );
      expect(other.shouldRepaint(base), isTrue);
    });

    test('playhead change repaints', () {
      const other = StrokesPainter(
        strokes: [],
        draft: null,
        playheadX: 10,
        playing: false,
        hits: [],
      );
      expect(other.shouldRepaint(base), isTrue);
    });

    test('playing change repaints', () {
      const other = StrokesPainter(
        strokes: [],
        draft: null,
        playheadX: 0,
        playing: true,
        hits: [],
      );
      expect(other.shouldRepaint(base), isTrue);
    });

    test('hits change repaints', () {
      const other = StrokesPainter(
        strokes: [],
        draft: null,
        playheadX: 0,
        playing: false,
        hits: [ScanHit(point: Offset(1, 1))],
      );
      expect(other.shouldRepaint(base), isTrue);
    });
  });
}
