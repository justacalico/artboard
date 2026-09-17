import 'package:flutter/material.dart';

import 'app.dart';
import 'src/audio/note_player.dart';

void main() {
  runApp(ArtboardApp(notePlayer: AudioPlayersNotePlayer()));
}
