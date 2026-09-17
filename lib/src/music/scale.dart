/// Musical scale definitions used to snap drawn positions to notes.
enum ScaleType {
  major,
  minor,
  pentatonicMajor,
  pentatonicMinor,
  dorian,
  blues;

  /// Semitone offsets from the root for one octave of this scale.
  List<int> get intervals => switch (this) {
        ScaleType.major => const [0, 2, 4, 5, 7, 9, 11],
        ScaleType.minor => const [0, 2, 3, 5, 7, 8, 10],
        ScaleType.pentatonicMajor => const [0, 2, 4, 7, 9],
        ScaleType.pentatonicMinor => const [0, 3, 5, 7, 10],
        ScaleType.dorian => const [0, 2, 3, 5, 7, 9, 10],
        ScaleType.blues => const [0, 3, 5, 6, 7, 10],
      };

  int get degreeCount => intervals.length;

  /// Semitone offset for [degree], which may exceed one octave or be
  /// negative; wraps through the scale in both directions.
  int semitoneOffset(int degree) {
    final n = degreeCount;
    final octave = (degree / n).floor();
    final index = degree - octave * n;
    return octave * 12 + intervals[index];
  }

  /// Total number of scale degrees contained in [octaves] octaves.
  int degreesInOctaves(int octaves) => degreeCount * octaves + 1;
}
