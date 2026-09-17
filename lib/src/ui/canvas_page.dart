import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../drawing/drawing_controller.dart';
import '../music/music_controller.dart';
import '../playback/playback_controller.dart';
import '../playback/trigger_engine.dart';
import 'color_deck.dart';
import 'deck_button.dart';
import 'draw_canvas.dart';
import 'layer_deck.dart';
import 'music_deck.dart';
import 'tool_deck.dart';

/// Home screen: drawing paper on top, tool decks below.
class CanvasPage extends StatefulWidget {
  const CanvasPage({super.key, this.onNotes});

  /// Sink for triggered notes; the audio layer plugs in here.
  final void Function(List<NoteTrigger>)? onNotes;

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  late final DrawingController _drawing;
  late final MusicController _music;
  late final PlaybackController _playback;
  final _random = Random();
  List<dynamic>? _saved;

  @override
  void initState() {
    super.initState();
    _drawing = DrawingController();
    _music = MusicController();
    _playback = PlaybackController(
      () => _drawing.allStrokes,
      () => _music.mapper,
      (notes) => widget.onNotes?.call(notes),
      tempo: () => _music.tempo,
    );
  }

  @override
  void dispose() {
    _playback.dispose();
    _drawing.dispose();
    _music.dispose();
    super.dispose();
  }

  void _showHelp() {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.helpBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([_drawing, _music, _playback]),
          builder: (context, _) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: DeckButton(
                    icon: Icons.question_mark,
                    tooltip: l10n.helpTooltip,
                    onPressed: _showHelp,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: DrawCanvas(drawing: _drawing, playback: _playback),
                ),
                const SizedBox(height: 14),
                ToolDeck(
                  drawing: _drawing,
                  music: _music,
                  playback: _playback,
                  onSurprise: () =>
                      _drawing.doodle(_random, _music.mapper, _playback.size),
                ),
                const SizedBox(height: 12),
                ColorDeck(drawing: _drawing),
                const SizedBox(height: 12),
                MusicDeck(music: _music, drawing: _drawing),
                const SizedBox(height: 12),
                LayerDeck(
                  drawing: _drawing,
                  onSave: () {
                    _saved = _drawing.toJson();
                    _toast(l10n.drawingSaved);
                  },
                  onRestore: () {
                    final saved = _saved;
                    if (saved == null) {
                      _toast(l10n.nothingToRestore);
                    } else {
                      _drawing.loadJson(saved);
                      _toast(l10n.drawingRestored);
                    }
                  },
                  onWipe: _drawing.clearAll,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
