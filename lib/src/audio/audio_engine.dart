import '../music/timbre.dart';
import '../playback/trigger_engine.dart';
import 'note_player.dart';
import 'tone_bank.dart';

/// Turns note triggers into sound through a cached tone bank.
class AudioEngine {
  AudioEngine(this._player, {ToneBank? bank}) : _bank = bank ?? ToneBank();

  final NotePlayer _player;
  final ToneBank _bank;

  void play(NoteTrigger note, Instrument instrument) {
    final midi = note.midi + instrument.octaveOffset * 12;
    _player.play(_bank.tone(midi.clamp(21, 108), instrument));
  }

  void playAll(List<NoteTrigger> notes, Instrument Function(int color) voice) {
    for (final note in notes) {
      play(note, voice(note.colorValue));
    }
  }

  void dispose() => _player.dispose();
}
