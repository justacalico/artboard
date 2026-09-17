import 'dart:typed_data';

import 'package:artboard/src/audio/loop_renderer.dart';
import 'package:artboard/src/drawing/stroke.dart';
import 'package:artboard/src/music/pitch_mapper.dart';
import 'package:artboard/src/music/scale.dart';
import 'package:artboard/src/music/timbre.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final mapper = PitchMapper(scale: ScaleType.major);
  const voice = Instrument(Timbre.sine);
  Instrument voiceFor(int _) => voice;
  const strokes = [
    Stroke(points: [Offset(50, 25), Offset(100, 75)], colorValue: 1, width: 4),
    Stroke(points: [Offset(150, 50), Offset(180, 50)], colorValue: 2, width: 4),
  ];

  test('loopSeconds is four beats at the given tempo', () {
    expect(loopSeconds(120), 2);
    expect(loopSeconds(60), 4);
  });

  test('scheduleLoop emits sorted events inside the loop', () {
    final events = scheduleLoop(
      strokes: strokes,
      mapper: mapper,
      instrumentFor: voiceFor,
      tempo: 90,
      width: 200,
      height: 100,
    );
    expect(events, hasLength(2));
    expect(events.first.atSeconds, lessThan(events.last.atSeconds));
    for (final e in events) {
      expect(e.atSeconds, inInclusiveRange(0, loopSeconds(90)));
      expect(e.seconds, inInclusiveRange(0.08, 0.6));
    }
  });

  test('vertical strokes are skipped', () {
    final events = scheduleLoop(
      strokes: const [
        Stroke(points: [Offset(50, 10), Offset(50, 90)], colorValue: 1, width: 4),
      ],
      mapper: mapper,
      instrumentFor: voiceFor,
      tempo: 90,
      width: 200,
      height: 100,
    );
    expect(events, isEmpty);
  });

  test('renderLoopWav produces a playable file', () {
    final wav = renderLoopWav(
      strokes: strokes,
      mapper: mapper,
      instrumentFor: voiceFor,
      tempo: 90,
      width: 200,
      height: 100,
    );
    expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
    final data = ByteData.view(wav.buffer);
    expect(data.getUint32(24, Endian.little), 22050);
    // One 90 bpm loop at 22.05 kHz plus a small tail.
    expect(wav.length, greaterThan(44 + 2 * 22050 * 2));
  });

  test('an empty drawing renders silence', () {
    final wav = renderLoopWav(
      strokes: const [],
      mapper: mapper,
      instrumentFor: voiceFor,
      tempo: 90,
      width: 200,
      height: 100,
    );
    final data = ByteData.view(wav.buffer);
    var peak = 0;
    for (var i = 44; i + 1 < wav.length; i += 2) {
      final s = data.getInt16(i, Endian.little).abs();
      if (s > peak) peak = s;
    }
    expect(peak, 0);
  });
}
