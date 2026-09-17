import 'package:artboard/src/music/scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScaleType', () {
    test('major scale has seven degrees', () {
      expect(ScaleType.major.degreeCount, 7);
      expect(ScaleType.major.intervals, [0, 2, 4, 5, 7, 9, 11]);
    });

    test('all scales start on the root', () {
      for (final scale in ScaleType.values) {
        expect(scale.intervals.first, 0);
      }
    });

    test('semitoneOffset wraps past one octave', () {
      final scale = ScaleType.major;
      expect(scale.semitoneOffset(7), 12);
      expect(scale.semitoneOffset(8), 14);
      expect(scale.semitoneOffset(-1), -1);
      expect(scale.semitoneOffset(-7), -12);
    });

    test('semitoneOffset for pentatonic scale', () {
      final scale = ScaleType.pentatonicMinor;
      expect(scale.semitoneOffset(0), 0);
      expect(scale.semitoneOffset(4), 10);
      expect(scale.semitoneOffset(5), 12);
    });

    test('degreesInOctaves counts inclusively', () {
      expect(ScaleType.major.degreesInOctaves(2), 15);
      expect(ScaleType.blues.degreesInOctaves(1), 7);
    });
  });
}
