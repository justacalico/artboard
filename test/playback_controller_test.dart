import 'dart:ui' show Offset, Size;

import 'package:artboard/src/drawing/stroke.dart';
import 'package:artboard/src/music/pitch_mapper.dart';
import 'package:artboard/src/music/scale.dart';
import 'package:artboard/src/playback/playback_controller.dart';
import 'package:artboard/src/playback/trigger_engine.dart';
import 'package:flutter_test/flutter_test.dart';

PlaybackController build({
  required List<Stroke> strokes,
  required List<NoteTrigger> sink,
  double tempo = 90,
}) =>
    PlaybackController(
      () => strokes,
      () => PitchMapper(scale: ScaleType.major),
      sink.addAll,
      tempo: () => tempo,
    );

void main() {
  const size = Size(200, 100);
  final strokes = [
    const Stroke(
      points: [Offset(50, 50), Offset(80, 50)],
      colorValue: 0xFF000000,
      width: 4,
    ),
  ];

  test('step forwards note triggers while playing', () {
    final sink = <NoteTrigger>[];
    final p = build(strokes: strokes, sink: sink);
    p.configure(size);
    p.play();
    p.step(const Duration(seconds: 1));
    expect(sink, isNotEmpty);
    p.dispose();
  });

  test('step is a no-op while paused', () {
    final sink = <NoteTrigger>[];
    final p = build(strokes: strokes, sink: sink);
    p.configure(size);
    p.step(const Duration(seconds: 1));
    expect(sink, isEmpty);
    expect(p.x, 0);
    p.dispose();
  });

  test('wrapping resets the engine so notes refire', () {
    final sink = <NoteTrigger>[];
    final p = build(strokes: strokes, sink: sink);
    p.configure(size);
    p.play();
    p.step(const Duration(seconds: 10));
    final firstSweep = sink.length;
    p.step(const Duration(seconds: 10));
    expect(sink.length, greaterThan(firstSweep));
    p.dispose();
  });

  test('higher tempo sweeps further per step', () {
    final sink = <NoteTrigger>[];
    final slow = build(strokes: strokes, sink: sink, tempo: 60)
      ..configure(size)
      ..play();
    final fast = build(strokes: strokes, sink: sink, tempo: 180)
      ..configure(size)
      ..play();
    slow.step(const Duration(milliseconds: 500));
    fast.step(const Duration(milliseconds: 500));
    expect(fast.x, greaterThan(slow.x));
    slow.dispose();
    fast.dispose();
  });

  test('pause clears the hits', () {
    final sink = <NoteTrigger>[];
    final p = build(strokes: strokes, sink: sink);
    p.configure(size);
    p.play();
    p.step(const Duration(milliseconds: 300));
    p.pause();
    expect(p.playing, isFalse);
    expect(p.hits, isEmpty);
    p.dispose();
  });

  test('toggle flips the transport', () {
    final sink = <NoteTrigger>[];
    final p = build(strokes: strokes, sink: sink);
    p.configure(size);
    p.toggle();
    expect(p.playing, isTrue);
    p.toggle();
    expect(p.playing, isFalse);
    p.dispose();
  });

  test('play before layout does nothing', () {
    final sink = <NoteTrigger>[];
    final p = build(strokes: strokes, sink: sink);
    p.play();
    expect(p.playing, isFalse);
    p.dispose();
  });

  test('configure with same size keeps state', () {
    final sink = <NoteTrigger>[];
    final p = build(strokes: strokes, sink: sink);
    p.configure(size);
    p.play();
    p.step(const Duration(milliseconds: 100));
    p.configure(size);
    expect(p.x, greaterThan(0));
    p.dispose();
  });
}
