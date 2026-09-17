import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../drawing/drawing_controller.dart';
import '../music/music_controller.dart';
import '../playback/playback_controller.dart';
import 'deck_button.dart';

/// First deck: transport, tools, undo, surprise, export and tempo.
class ToolDeck extends StatelessWidget {
  const ToolDeck({
    super.key,
    required this.drawing,
    required this.music,
    required this.playback,
    required this.onSurprise,
    this.onExport,
  });

  final DrawingController drawing;
  final MusicController music;
  final PlaybackController playback;
  final VoidCallback onSurprise;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        DeckButton(
          icon: playback.playing ? Icons.pause : Icons.play_arrow,
          tooltip: playback.playing ? l10n.pause : l10n.play,
          onPressed: playback.toggle,
        ),
        DeckButton(
          icon: Icons.edit,
          tooltip: l10n.penTool,
          selected: drawing.tool == DrawTool.pen,
          onPressed: () => drawing.selectTool(DrawTool.pen),
        ),
        DeckButton(
          icon: Icons.auto_fix_normal,
          tooltip: l10n.eraserTool,
          selected: drawing.tool == DrawTool.eraser,
          onPressed: () => drawing.selectTool(DrawTool.eraser),
        ),
        DeckButton(
          icon: Icons.undo,
          tooltip: l10n.undo,
          onPressed: drawing.canUndo ? drawing.undo : null,
        ),
        DeckButton(
          icon: Icons.shuffle,
          tooltip: l10n.surpriseMe,
          onPressed: onSurprise,
        ),
        const Spacer(),
        DeckButton(
          tooltip: l10n.exportLoop,
          onPressed: onExport,
          child: const Icon(Icons.circle, size: 16, color: Color(0xFFE0442A)),
        ),
        _TempoPill(music: music),
      ],
    );
  }
}

class _TempoPill extends StatelessWidget {
  const _TempoPill({required this.music});

  final MusicController music;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 44,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x33000000)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TempoButton(
            icon: Icons.remove,
            tooltip: l10n.decreaseTempo,
            onPressed: music.tempo > MusicController.minTempo
                ? () => music.bumpTempo(-MusicController.tempoStep)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '${music.tempo.round()}',
              semanticsLabel: l10n.tempo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          _TempoButton(
            icon: Icons.add,
            tooltip: l10n.increaseTempo,
            onPressed: music.tempo < MusicController.maxTempo
                ? () => music.bumpTempo(MusicController.tempoStep)
                : null,
          ),
        ],
      ),
    );
  }
}

class _TempoButton extends StatelessWidget {
  const _TempoButton({required this.icon, required this.tooltip, this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 44,
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}
