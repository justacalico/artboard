import 'package:flutter/material.dart';

/// Graph paper background for the drawing area.
class PaperPainter extends CustomPainter {
  const PaperPainter();

  static const cell = 26.0;

  @override
  void paint(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = const Color(0x14000000)
      ..strokeWidth = 1;
    final major = Paint()
      ..color = const Color(0x24000000)
      ..strokeWidth = 1;

    for (var x = 0.0; x <= size.width; x += cell) {
      final isMajor = (x / cell).round() % 4 == 0;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), isMajor ? major : minor);
    }
    for (var y = 0.0; y <= size.height; y += cell) {
      final isMajor = (y / cell).round() % 4 == 0;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), isMajor ? major : minor);
    }
  }

  @override
  bool shouldRepaint(PaperPainter oldDelegate) => false;
}
