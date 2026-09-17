import 'scale.dart';

/// Root notes selectable on the piano strip, in display order.
const kRootNotes = [
  ('C', 60),
  ('C#', 61),
  ('D', 62),
  ('D#', 63),
  ('E', 64),
  ('F', 65),
  ('F#', 66),
  ('G', 67),
  ('G#', 68),
  ('A', 69),
  ('A#', 70),
  ('B', 71),
];

/// Maps a vertical canvas position to a MIDI note inside the selected key.
class PitchMapper {
  PitchMapper({
    required this.scale,
    this.rootMidi = 60,
    this.octaveShift = 0,
    this.spanOctaves = 2,
  });

  final ScaleType scale;
  final int rootMidi;
  final int octaveShift;
  final int spanOctaves;

  /// [fraction] is 0 at the top of the canvas and 1 at the bottom.
  /// Higher positions produce higher pitches snapped to the scale.
  int midiAt(double fraction) {
    final span = scale.degreesInOctaves(spanOctaves) - 1;
    final degree = ((1 - fraction.clamp(0.0, 1.0)) * span).round();
    return rootMidi + octaveShift * 12 + scale.semitoneOffset(degree);
  }

  /// Inverse of [midiAt] for the nearest scale degree, used to place
  /// generated doodles on exact pitch lines.
  double fractionForMidi(int midi) {
    final span = scale.degreesInOctaves(spanOctaves) - 1;
    var best = 0;
    var bestDiff = 1 << 30;
    for (var d = 0; d <= span; d++) {
      final diff = (rootMidi + octaveShift * 12 + scale.semitoneOffset(d) - midi).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        best = d;
      }
    }
    return 1 - best / span;
  }
}
