import 'dart:typed_data';

import 'package:artboard/src/audio/audio_engine.dart';
import 'package:artboard/src/audio/note_player.dart';
import 'package:artboard/src/audio/tone_bank.dart';
import 'package:artboard/src/music/timbre.dart';
import 'package:artboard/src/playback/trigger_engine.dart';
import 'package:flutter_test/flutter_test.dart';

class _Recorder extends NotePlayer {
  final wavs = <Uint8List>[];
  var disposed = false;

  @override
  void play(Uint8List wav) => wavs.add(wav);

  @override
  void dispose() => disposed = true;
}

void main() {
  test('play sends one rendered wav per note', () {
    final recorder = _Recorder();
    final engine = AudioEngine(recorder);
    engine.play(const NoteTrigger(midi: 60, colorValue: 1), const Instrument(Timbre.sine));
    expect(recorder.wavs, hasLength(1));
    expect(String.fromCharCodes(recorder.wavs.single.sublist(0, 4)), 'RIFF');
  });

  test('octave offset changes the cached key', () {
    final bank = ToneBank();
    final recorder = _Recorder();
    final engine = AudioEngine(recorder, bank: bank);
    engine.play(const NoteTrigger(midi: 60, colorValue: 1), const Instrument(Timbre.sine));
    engine.play(const NoteTrigger(midi: 60, colorValue: 1), const Instrument(Timbre.sine, octaveOffset: 1));
    expect(bank.size, 2);
  });

  test('repeated notes reuse the cached tone', () {
    final bank = ToneBank();
    final engine = AudioEngine(_Recorder(), bank: bank);
    const note = NoteTrigger(midi: 60, colorValue: 1);
    engine.play(note, const Instrument(Timbre.sine));
    engine.play(note, const Instrument(Timbre.sine));
    expect(bank.size, 1);
  });

  test('playAll resolves a voice per colour', () {
    final recorder = _Recorder();
    final engine = AudioEngine(recorder);
    engine.playAll(
      const [
        NoteTrigger(midi: 60, colorValue: 1),
        NoteTrigger(midi: 62, colorValue: 2),
      ],
      (color) => color == 1 ? const Instrument(Timbre.sine) : const Instrument(Timbre.square),
    );
    expect(recorder.wavs, hasLength(2));
    expect(recorder.wavs[0], isNot(equals(recorder.wavs[1])));
  });

  test('dispose forwards to the player', () {
    final recorder = _Recorder();
    AudioEngine(recorder).dispose();
    expect(recorder.disposed, isTrue);
  });
}
