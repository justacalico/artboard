import 'dart:ui';

import 'package:artboard/src/drawing/geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('segmentXRange', () {
    test('returns sorted half-open range', () {
      expect(segmentXRange(const Offset(10, 0), const Offset(20, 0)), (10.0, 20.0));
      expect(segmentXRange(const Offset(20, 0), const Offset(10, 0)), (10.0, 20.0));
    });

    test('vertical segment has no range', () {
      expect(segmentXRange(const Offset(5, 0), const Offset(5, 9)), isNull);
    });
  });

  group('segmentYAtX', () {
    test('interpolates y at x', () {
      final y = segmentYAtX(const Offset(0, 0), const Offset(10, 100), 5);
      expect(y, 50);
    });

    test('returns null outside range', () {
      expect(segmentYAtX(const Offset(0, 0), const Offset(10, 100), 10), isNull);
      expect(segmentYAtX(const Offset(0, 0), const Offset(10, 100), -1), isNull);
    });

    test('returns null for vertical segment', () {
      expect(segmentYAtX(const Offset(3, 0), const Offset(3, 9), 3), isNull);
    });
  });

  group('distanceToSegment', () {
    test('point on segment has zero distance', () {
      expect(
        distanceToSegment(const Offset(5, 0), const Offset(0, 0), const Offset(10, 0)),
        0,
      );
    });

    test('perpendicular distance', () {
      expect(
        distanceToSegment(const Offset(5, 4), const Offset(0, 0), const Offset(10, 0)),
        4,
      );
    });

    test('clamps to nearest endpoint', () {
      expect(
        distanceToSegment(const Offset(20, 0), const Offset(0, 0), const Offset(10, 0)),
        10,
      );
    });

    test('degenerate segment measures to its point', () {
      expect(
        distanceToSegment(const Offset(3, 4), const Offset(0, 0), const Offset(0, 0)),
        5,
      );
    });
  });

  test('segmentNearPoint respects radius', () {
    expect(segmentNearPoint(const Offset(5, 2), const Offset(0, 0), const Offset(10, 0), 3), isTrue);
    expect(segmentNearPoint(const Offset(5, 4), const Offset(0, 0), const Offset(10, 0), 3), isFalse);
  });
}
