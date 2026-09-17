import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../drawing/drawing_controller.dart';
import '../drawing/palette.dart';
import 'deck_button.dart';

enum _SaveAction { save, restore, wipe }

/// Fourth deck: layer tabs, pen widths, then the save/restore menu.
class LayerDeck extends StatelessWidget {
  const LayerDeck({
    super.key,
    required this.drawing,
    required this.onSave,
    required this.onRestore,
    required this.onWipe,
  });

  final DrawingController drawing;
  final VoidCallback onSave;
  final VoidCallback onRestore;
  final VoidCallback onWipe;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        for (var i = 0; i < drawing.layers.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DeckButton(
              tooltip: l10n.layerLabel(i + 1),
              selected: drawing.activeLayer == i,
              onPressed: () => drawing.selectLayer(i),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: drawing.activeLayer == i
                      ? Colors.white
                      : const Color(0xFF1C1B1A),
                ),
              ),
            ),
          ),
        const Spacer(),
        for (var i = 0; i < kStrokeWidths.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DeckButton(
              tooltip: switch (i) {
                0 => l10n.strokeThin,
                1 => l10n.strokeMedium,
                _ => l10n.strokeThick,
              },
              selected: drawing.strokeWidth == kStrokeWidths[i],
              onPressed: () => drawing.selectWidth(kStrokeWidths[i]),
              child: Icon(
                Icons.circle,
                size: 5.0 + i * 5,
                color: drawing.strokeWidth == kStrokeWidths[i]
                    ? Colors.white
                    : const Color(0xFF1C1B1A),
              ),
            ),
          ),
        const Spacer(),
        PopupMenuButton<_SaveAction>(
          tooltip: l10n.saveDrawing,
          icon: const Icon(Icons.cloud_outlined),
          onSelected: (action) => switch (action) {
            _SaveAction.save => onSave(),
            _SaveAction.restore => onRestore(),
            _SaveAction.wipe => onWipe(),
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: _SaveAction.save, child: Text(l10n.saveDrawing)),
            PopupMenuItem(value: _SaveAction.restore, child: Text(l10n.restoreDrawing)),
            PopupMenuItem(value: _SaveAction.wipe, child: Text(l10n.clearCanvas)),
          ],
        ),
      ],
    );
  }
}
