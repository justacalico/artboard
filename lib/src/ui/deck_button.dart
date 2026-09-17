import 'package:flutter/material.dart';

/// Round outline button used across every deck. Selected state is a
/// filled dark circle, matching the reference app.
class DeckButton extends StatelessWidget {
  const DeckButton({
    super.key,
    this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
    this.iconColor,
    this.child,
  });

  final IconData? icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;
  final Color? iconColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? const Color(0xFF1C1B1A) : Colors.white,
            border: Border.all(
              color: selected ? const Color(0xFF1C1B1A) : const Color(0x33000000),
            ),
          ),
          child: child ??
              Icon(
                icon,
                size: 20,
                color: iconColor ??
                    (selected ? Colors.white : const Color(0xFF1C1B1A)),
              ),
        ),
      ),
    );
  }
}
