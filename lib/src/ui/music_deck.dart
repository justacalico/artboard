import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../drawing/drawing_controller.dart';
import '../music/music_controller.dart';
import 'deck_button.dart';
import 'picker_sheets.dart';
import 'piano_strip.dart';

/// Third deck: piano strip for the key, octave shift, timbre and scale.
class MusicDeck extends StatelessWidget {
  const MusicDeck({super.key, required this.music, required this.drawing});

  final MusicController music;
  final DrawingController drawing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: PianoStrip(
              rootMidi: music.rootMidi,
              onSelect: music.selectRoot,
            ),
          ),
        ),
        const SizedBox(width: 8),
        DeckButton(
          icon: Icons.keyboard_arrow_up,
          tooltip: l10n.octaveUp,
          onPressed: music.octaveShift < MusicController.maxOctave
              ? () => music.bumpOctave(1)
              : null,
        ),
        DeckButton(
          icon: Icons.keyboard_arrow_down,
          tooltip: l10n.octaveDown,
          onPressed: music.octaveShift > MusicController.minOctave
              ? () => music.bumpOctave(-1)
              : null,
        ),
        DeckButton(
          icon: Icons.waves,
          tooltip: l10n.chooseTimbre,
          onPressed: () => showTimbrePicker(context, music, drawing.colorValue),
        ),
        DeckButton(
          icon: Icons.piano,
          tooltip: l10n.chooseScale,
          onPressed: () => showScalePicker(context, music),
        ),
      ],
    );
  }
}
