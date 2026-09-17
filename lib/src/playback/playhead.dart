/// A vertical scan line sweeping left to right across the canvas.
class Playhead {
  Playhead({required this.width, required this.speed});

  /// Sweep distance in logical pixels.
  final double width;

  /// Speed in pixels per second, derived from the tempo control.
  double speed;

  double _x = 0;
  double get x => _x;

  /// Advances by [dt]. Returns true when the head wrapped to the start.
  bool advance(Duration dt) {
    _x += speed * dt.inMicroseconds / Duration.microsecondsPerSecond;
    if (_x >= width) {
      _x = 0;
      return true;
    }
    return false;
  }

  void reset() => _x = 0;
}
