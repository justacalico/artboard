import '../drawing/palette.dart';

/// Waveform shapes the synthesizer can render.
enum Timbre { sine, triangle, square, sawtooth }

/// How a colour sounds: waveform, octave offset and loudness.
class Instrument {
  const Instrument(this.timbre, {this.octaveOffset = 0, this.gain = 0.5});

  final Timbre timbre;
  final int octaveOffset;
  final double gain;
}

/// Default voice for each pen colour, keyed by ARGB value.
Map<int, Instrument> defaultInstruments() => {
      kStrokeColors[0].toARGB32(): const Instrument(Timbre.triangle),
      kStrokeColors[1].toARGB32(): const Instrument(Timbre.square, gain: 0.35),
      kStrokeColors[2].toARGB32(): const Instrument(Timbre.sine, octaveOffset: 1),
      kStrokeColors[3].toARGB32(): const Instrument(Timbre.sawtooth, gain: 0.35),
      kStrokeColors[4].toARGB32(): const Instrument(Timbre.sine),
      kStrokeColors[5].toARGB32(): const Instrument(Timbre.triangle, octaveOffset: 1),
      kStrokeColors[6].toARGB32(): const Instrument(Timbre.sine, octaveOffset: -1, gain: 0.6),
      kStrokeColors[7].toARGB32(): const Instrument(Timbre.square, octaveOffset: -1, gain: 0.3),
      kStrokeColors[8].toARGB32(): const Instrument(Timbre.sawtooth, octaveOffset: 1, gain: 0.3),
    };
