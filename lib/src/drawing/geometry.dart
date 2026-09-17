import 'dart:ui';

/// Half-open crossing range [start, end) of a segment on the x axis.
/// Returns null when the segment is a point or fully vertical.
(double, double)? segmentXRange(Offset a, Offset b) {
  final lo = a.dx < b.dx ? a.dx : b.dx;
  final hi = a.dx > b.dx ? a.dx : b.dx;
  if (hi - lo < 1e-9) return null;
  return (lo, hi);
}

/// Y coordinate where segment ab crosses the vertical line [x],
/// or null when x is outside the segment's half-open x range.
double? segmentYAtX(Offset a, Offset b, double x) {
  final range = segmentXRange(a, b);
  if (range == null) return null;
  if (x < range.$1 || x >= range.$2) return null;
  final t = (x - a.dx) / (b.dx - a.dx);
  return a.dy + t * (b.dy - a.dy);
}

/// Distance from [p] to segment ab, used by the eraser.
double distanceToSegment(Offset p, Offset a, Offset b) {
  final dx = b.dx - a.dx;
  final dy = b.dy - a.dy;
  final lengthSq = dx * dx + dy * dy;
  if (lengthSq < 1e-9) return (p - a).distance;
  final t = ((p.dx - a.dx) * dx + (p.dy - a.dy) * dy) / lengthSq;
  final clamped = t.clamp(0.0, 1.0);
  return (p - Offset(a.dx + clamped * dx, a.dy + clamped * dy)).distance;
}

/// Does the segment ab come within [radius] of [p]?
bool segmentNearPoint(Offset p, Offset a, Offset b, double radius) =>
    distanceToSegment(p, a, b) <= radius;
