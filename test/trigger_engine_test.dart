import 'dart:ui';

import 'package:artboard/src/drawing/stroke.dart';
import 'package:artboard/src/music/pitch_mapper.dart';
import 'package:artboard/src/music/scale.dart';
import 'package:artboard/src/playback/trigger_engine.dart';
import 'package:flutter_test/flutter_test.dart';

TriggerEngine engine() => TriggerEngine(
      mapper: PitchMapper(scale: ScaleType.major),
      canvasHeight: 100,
    );

Stroke line(List<Offset> points, {int color = 0xFF000000}) =>
    Stroke(points: points, colorValue: color, width: 4);

void main() {
  group('TriggerEngine', () {
    test('fires a note when the playhead enters a segment', () {
      final strokes = [line([const Offset(10, 50), const Offset(30, 50)])];
      final e = engine();
      final result = e.scan(strokes, 0, 15);
      expect(result.triggers, hasLength(1));
      expect(result.triggers.single.midi, engine().mapper.midiAt(0.5));
    });

    test('does not refire a segment inside its range', () {
      final strokes = [line([const Offset(10, 50), const Offset(30, 50)])];
      final e = engine();
      e.scan(strokes, 0, 15);
      final result = e.scan(strokes, 15, 25);
      expect(result.triggers, isEmpty);
    });

    test('reset clears fired segments for the next sweep', () {
      final strokes = [line([const Offset(10, 50), const Offset(30, 50)])];
      final e = engine();
      e.scan(strokes, 0, 15);
      e.reset();
      final result = e.scan(strokes, 0, 15);
      expect(result.triggers, hasLength(1));
    });

    test('fast sweep still fires segments it jumps over', () {
      final strokes = [line([const Offset(10, 50), const Offset(12, 50)])];
      final e = engine();
      final result = e.scan(strokes, 0, 90);
      expect(result.triggers, hasLength(1));
    });

    test('reports hits only where the line currently crosses', () {
      final strokes = [line([const Offset(10, 50), const Offset(30, 70)])];
      final e = engine();
      final result = e.scan(strokes, 0, 20);
      expect(result.hits, hasLength(1));
      expect(result.hits.single.point, const Offset(20, 60));
    });

    test('vertical strokes produce no triggers or hits', () {
      final strokes = [line([const Offset(20, 10), const Offset(20, 90)])];
      final e = engine();
      final result = e.scan(strokes, 0, 50);
      expect(result.triggers, isEmpty);
      expect(result.hits, isEmpty);
    });

    test('polyline fires each segment once per sweep', () {
      final strokes = [
        line([
          const Offset(10, 20),
          const Offset(30, 80),
          const Offset(50, 20),
        ])
      ];
      final e = engine();
      final result = e.scan(strokes, 0, 60);
      expect(result.triggers, hasLength(2));
    });

    test('carries the stroke colour onto the note', () {
      final strokes = [line([const Offset(10, 50), const Offset(30, 50)], color: 0xFF123456)];
      final e = engine();
      final result = e.scan(strokes, 0, 15);
      expect(result.triggers.single.colorValue, 0xFF123456);
    });
  });
}
