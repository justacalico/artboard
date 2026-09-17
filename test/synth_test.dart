import 'package:artboard/src/audio/synth.dart';
import 'package:artboard/src/music/timbre.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('A4 is 440 Hz and C4 sits near 261.6 Hz', () {
    expect(midiToFreq(69), 440);
    expect(midiToFreq(60), closeTo(261.63, 0.01));
  });

  test('renderTone produces the requested number of samples', () {
    final pcm = renderTone(midi: 60, timbre: Timbre.sine, seconds: 0.5, sampleRate: 8000);
    expect(pcm.length, 4000);
  });

  test('samples stay inside 16-bit range', () {
    for (final timbre in Timbre.values) {
      final pcm = renderTone(midi: 45, timbre: timbre, gain: 1.0);
      for (final s in pcm) {
        expect(s, inInclusiveRange(-32768, 32767));
      }
    }
  });

  test('attack envelope starts near silence', () {
    final pcm = renderTone(midi: 60, timbre: Timbre.square, sampleRate: 8000);
    expect(pcm.first.abs(), lessThan(5000));
  });

  test('each waveform sounds different', () {
    final sine = renderTone(midi: 60, timbre: Timbre.sine, sampleRate: 8000);
    final square = renderTone(midi: 60, timbre: Timbre.square, sampleRate: 8000);
    var diff = 0;
    for (var i = 0; i < sine.length; i++) {
      diff += (sine[i] - square[i]).abs();
    }
    expect(diff, greaterThan(0));
  });
}
