import 'dart:math';
import 'dart:typed_data';

import '../music/timbre.dart';

/// Standard synth tuning.
double midiToFreq(int midi) => 440 * pow(2, (midi - 69) / 12).toDouble();

/// Renders one note as mono 16-bit PCM with a short attack and a
/// gentle release so strokes don't click.
Int16List renderTone({
  required int midi,
  required Timbre timbre,
  double seconds = 0.45,
  int sampleRate = 22050,
  double gain = 0.5,
}) {
  final count = (seconds * sampleRate).round();
  final out = Int16List(count);
  final freq = midiToFreq(midi);
  final attack = (0.008 * sampleRate).round();
  final release = (0.09 * sampleRate).round();

  for (var i = 0; i < count; i++) {
    final t = i / sampleRate;
    final phase = (freq * t) % 1.0;
    final sample = switch (timbre) {
      Timbre.sine => sin(2 * pi * phase),
      Timbre.triangle => 4 * (phase - 0.5).abs() - 1,
      Timbre.square => phase < 0.5 ? 1.0 : -1.0,
      Timbre.sawtooth => 2 * phase - 1,
    };
    var env = 1.0;
    if (i < attack) env = i / attack;
    if (i > count - release) env = (count - i) / release;
    out[i] = (sample * env * gain * 32767).round().clamp(-32768, 32767);
  }
  return out;
}
