import 'package:flutter/material.dart';

import '../drawing/stroke.dart';
import '../playback/trigger_engine.dart';

/// Paints the drawing, the scan line and the live note dots.
class StrokesPainter extends CustomPainter {
  const StrokesPainter({
    required this.strokes,
    required this.draft,
    required this.playheadX,
    required this.playing,
    required this.hits,
  });

  final List<Stroke> strokes;
  final Stroke? draft;
  final double playheadX;
  final bool playing;
  final List<ScanHit> hits;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke);
    }
    final draft = this.draft;
    if (draft != null) _paintStroke(canvas, draft);

    if (playing) {
      canvas.drawLine(
        Offset(playheadX, 0),
        Offset(playheadX, size.height),
        Paint()
          ..color = const Color(0xDD1C1B1A)
          ..strokeWidth = 1.5,
      );
      final dot = Paint()..color = const Color(0xFF1C1B1A);
      for (final hit in hits) {
        canvas.drawCircle(hit.point, 5, dot);
      }
    }
  }

  void _paintStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;
    final paint = Paint()
      ..color = Color(stroke.colorValue)
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    if (stroke.points.length == 1) {
      canvas.drawCircle(stroke.points.first, stroke.width / 2, paint..style = PaintingStyle.fill);
      return;
    }
    final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (final p in stroke.points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(StrokesPainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.draft != draft ||
      oldDelegate.playheadX != playheadX ||
      oldDelegate.playing != playing ||
      oldDelegate.hits != hits;
}
