import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Anything that can turn a WAV buffer into sound.
abstract class NotePlayer {
  void play(Uint8List wav);

  void dispose() {}
}

// coverage:ignore-start
/// Round-robin pool of plugin players so overlapping notes mix.
class AudioPlayersNotePlayer extends NotePlayer {
  AudioPlayersNotePlayer({int poolSize = 8})
      : _pool = List.generate(poolSize, (_) => AudioPlayer());

  final List<AudioPlayer> _pool;
  var _next = 0;

  @override
  void play(Uint8List wav) {
    final player = _pool[_next];
    _next = (_next + 1) % _pool.length;
    player.play(BytesSource(wav));
  }

  @override
  void dispose() {
    for (final player in _pool) {
      player.dispose();
    }
  }
}
// coverage:ignore-end
