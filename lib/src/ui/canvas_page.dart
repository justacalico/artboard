import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../audio/audio_engine.dart';
import '../audio/loop_exporter.dart';
import '../audio/loop_renderer.dart';
import '../audio/note_player.dart';
import '../drawing/drawing_controller.dart';
import '../drawing/drawing_store.dart';
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
  const CanvasPage({super.key, this.notePlayer, this.exporter, this.store});

  /// Sound sink for live notes; null keeps the app silent.
  final NotePlayer? notePlayer;

  /// File sink for the exported loop; defaults to the platform saver.
  final LoopExporter? exporter;

  /// Device storage for the saved drawing.
  final DrawingStore? store;

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  late final DrawingController _drawing;
  late final MusicController _music;
  late final PlaybackController _playback;
  late final LoopExporter _exporter;
  late final DrawingStore _store;
  AudioEngine? _engine;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _drawing = DrawingController();
    _music = MusicController();
    _exporter = widget.exporter ?? LoopExporter();
    _store = widget.store ?? DrawingStore();
    final player = widget.notePlayer;
    if (player != null) _engine = AudioEngine(player);
    _playback = PlaybackController(
      () => _drawing.allStrokes,
      () => _music.mapper,
      _onNotes,
      tempo: () => _music.tempo,
    );
  }

  void _onNotes(List<NoteTrigger> notes) =>
      _engine?.playAll(notes, _music.instrumentFor);

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    _toast(l10n.exportStarted);
    final wav = renderLoopWav(
      strokes: _drawing.allStrokes,
      mapper: _music.mapper,
      instrumentFor: _music.instrumentFor,
      tempo: _music.tempo,
      width: _playback.size.width,
      height: _playback.size.height,
    );
    await _exporter.save(wav);
    if (mounted) _toast(l10n.exportDone);
  }

  @override
  void dispose() {
    _engine?.dispose();
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
                  onExport: _export,
                ),
                const SizedBox(height: 12),
                ColorDeck(drawing: _drawing),
                const SizedBox(height: 12),
                MusicDeck(music: _music, drawing: _drawing),
                const SizedBox(height: 12),
                LayerDeck(
                  drawing: _drawing,
                  onSave: () async {
                    await _store.save(jsonEncode(_drawing.toJson()));
                    if (mounted) _toast(l10n.drawingSaved);
                  },
                  onRestore: () async {
                    final saved = await _store.load();
                    if (!mounted) return;
                    if (saved == null) {
                      _toast(l10n.nothingToRestore);
                    } else {
                      _drawing.loadJson(jsonDecode(saved) as List);
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
