import 'package:artboard/src/playback/playhead.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('advance moves at configured speed', () {
    final head = Playhead(width: 100, speed: 50);
    head.advance(const Duration(seconds: 1));
    expect(head.x, 50);
  });

  test('advance wraps at width and reports it', () {
    final head = Playhead(width: 100, speed: 120);
    expect(head.advance(const Duration(seconds: 1)), isTrue);
    expect(head.x, 0);
  });

  test('advance does not wrap mid-sweep', () {
    final head = Playhead(width: 100, speed: 10);
    expect(head.advance(const Duration(milliseconds: 500)), isFalse);
    expect(head.x, 5);
  });

  test('reset returns to start', () {
    final head = Playhead(width: 100, speed: 50);
    head.advance(const Duration(seconds: 1));
    head.reset();
    expect(head.x, 0);
  });
}
