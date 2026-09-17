import 'package:flutter/material.dart';

import 'app.dart';
import 'src/audio/note_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ArtboardApp(notePlayer: AudioPlayersNotePlayer()));
}
