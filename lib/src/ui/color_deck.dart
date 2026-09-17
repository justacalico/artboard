import 'package:flutter/material.dart';

import '../drawing/drawing_controller.dart';
import '../drawing/palette.dart';

/// Second deck: the nine pen colours.
class ColorDeck extends StatelessWidget {
  const ColorDeck({super.key, required this.drawing});

  final DrawingController drawing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final color in kStrokeColors)
          _ColorDot(
            color: color,
            selected: drawing.colorValue == color.toARGB32(),
            onTap: () => drawing.selectColor(color.toARGB32()),
          ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: selected
              ? Border.all(color: const Color(0x66000000), width: 2)
              : null,
        ),
        padding: const EdgeInsets.all(3),
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
