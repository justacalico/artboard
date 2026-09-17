import 'package:artboard/src/drawing/palette.dart';
import 'package:artboard/src/music/music_controller.dart';
import 'package:artboard/src/music/pitch_mapper.dart';
import 'package:artboard/src/music/scale.dart';
import 'package:artboard/src/music/timbre.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MusicController', () {
    test('defaults to C pentatonic major at 90', () {
      final m = MusicController();
      expect(m.rootMidi, 60);
      expect(m.scale, ScaleType.pentatonicMajor);
      expect(m.tempo, 90);
      expect(m.octaveShift, 0);
    });

    test('selectRoot changes the mapper root', () {
      final m = MusicController();
      m.selectRoot(kRootNotes[7].$2);
      expect(m.mapper.rootMidi, 67);
    });

    test('selectScale changes the mapper scale', () {
      final m = MusicController();
      m.selectScale(ScaleType.blues);
      expect(m.mapper.scale, ScaleType.blues);
    });

    test('tempo clamps inside its range', () {
      final m = MusicController();
      m.bumpTempo(500);
      expect(m.tempo, MusicController.maxTempo);
      m.bumpTempo(-999);
      expect(m.tempo, MusicController.minTempo);
    });

    test('octave clamps inside its range', () {
      final m = MusicController();
      m.bumpOctave(10);
      expect(m.octaveShift, MusicController.maxOctave);
      m.bumpOctave(-10);
      expect(m.octaveShift, MusicController.minOctave);
    });

    test('every palette colour has a default instrument', () {
      final m = MusicController();
      for (final color in kStrokeColors) {
        expect(m.instrumentFor(color.toARGB32()), isA<Instrument>());
      }
    });

    test('unknown colours fall back to sine', () {
      final m = MusicController();
      expect(m.instrumentFor(0xFF123456).timbre, Timbre.sine);
    });

    test('selectInstrument overrides the colour voice', () {
      final m = MusicController();
      final color = kStrokeColors[0].toARGB32();
      m.selectInstrument(color, const Instrument(Timbre.sawtooth));
      expect(m.instrumentFor(color).timbre, Timbre.sawtooth);
    });

    test('same value selections do not notify', () {
      final m = MusicController();
      var notified = 0;
      m.addListener(() => notified++);
      m.selectRoot(m.rootMidi);
      m.selectScale(m.scale);
      expect(notified, 0);
    });
  });
}
