import 'dart:ui';

import 'package:artboard/src/drawing/stroke.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('json round trip preserves the stroke', () {
    const stroke = Stroke(
      points: [Offset(1, 2), Offset(3.5, 4.25)],
      colorValue: 0xFFAABBCC,
      width: 6,
    );
    final restored = Stroke.fromJson(stroke.toJson());
    expect(restored.colorValue, stroke.colorValue);
    expect(restored.width, stroke.width);
    expect(restored.points, stroke.points);
  });

  test('copyWith replaces points only', () {
    const stroke = Stroke(points: [Offset(0, 0)], colorValue: 1, width: 2);
    final moved = stroke.copyWith(points: [const Offset(9, 9)]);
    expect(moved.points, [const Offset(9, 9)]);
    expect(moved.colorValue, 1);
    expect(moved.width, 2);
  });
}
