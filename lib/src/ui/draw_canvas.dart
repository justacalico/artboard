import 'package:flutter/material.dart';

import '../drawing/drawing_controller.dart';
import '../playback/playback_controller.dart';
import 'paper_painter.dart';
import 'strokes_painter.dart';

/// The graph-paper drawing surface with the scan line on top.
class DrawCanvas extends StatelessWidget {
  const DrawCanvas({super.key, required this.drawing, required this.playback});

  final DrawingController drawing;
  final PlaybackController playback;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        playback.configure(Size(constraints.maxWidth, constraints.maxHeight));
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: GestureDetector(
            onPanStart: (d) => drawing.beginStroke(d.localPosition),
            onPanUpdate: (d) => drawing.extendStroke(d.localPosition),
            onPanEnd: (_) => drawing.endStroke(),
            child: Container(
              color: const Color(0xFFFDFCF8),
              child: CustomPaint(
                painter: const PaperPainter(),
                foregroundPainter: null,
                child: ListenableBuilder(
                  listenable: Listenable.merge([drawing, playback]),
                  builder: (context, _) => CustomPaint(
                    size: Size.infinite,
                    painter: StrokesPainter(
                      strokes: drawing.allStrokes,
                      draft: drawing.draft,
                      playheadX: playback.x,
                      playing: playback.playing,
                      hits: playback.hits,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
