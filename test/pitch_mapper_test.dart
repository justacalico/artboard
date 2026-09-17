import 'package:artboard/src/music/pitch_mapper.dart';
import 'package:artboard/src/music/scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PitchMapper', () {
    test('top of canvas maps to highest note of span', () {
      final mapper = PitchMapper(scale: ScaleType.major);
      expect(mapper.midiAt(0), 60 + 24);
    });

    test('bottom of canvas maps to root', () {
      final mapper = PitchMapper(scale: ScaleType.major);
      expect(mapper.midiAt(1), 60);
    });

    test('middle of canvas snaps to a scale degree', () {
      final mapper = PitchMapper(scale: ScaleType.major);
      final midi = mapper.midiAt(0.5);
      expect([0, 2, 4, 5, 7, 9, 11].contains((midi - 60) % 12), isTrue);
    });

    test('root note shifts everything', () {
      final c = PitchMapper(scale: ScaleType.major, rootMidi: 60);
      final a = PitchMapper(scale: ScaleType.major, rootMidi: 69);
      expect(a.midiAt(1) - c.midiAt(1), 9);
    });

    test('octave shift moves the whole span', () {
      final base = PitchMapper(scale: ScaleType.major);
      final up = PitchMapper(scale: ScaleType.major, octaveShift: 1);
      expect(up.midiAt(0.3) - base.midiAt(0.3), 12);
    });

    test('out of range fractions are clamped', () {
      final mapper = PitchMapper(scale: ScaleType.major);
      expect(mapper.midiAt(-0.5), mapper.midiAt(0));
      expect(mapper.midiAt(1.5), mapper.midiAt(1));
    });

    test('fractionForMidi inverts midiAt on degree lines', () {
      final mapper = PitchMapper(scale: ScaleType.major);
      for (var d = 0; d < 15; d += 2) {
        final midi = 60 + ScaleType.major.semitoneOffset(d);
        final f = mapper.fractionForMidi(midi);
        expect(mapper.midiAt(f), midi);
      }
    });
  });
}
