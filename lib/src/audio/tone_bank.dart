import 'dart:typed_data';

import '../music/timbre.dart';
import 'synth.dart';
import 'wav_encoder.dart';

/// Caches rendered note WAVs so the same pitch+timbre never renders twice.
class ToneBank {
  ToneBank({this.sampleRate = 22050});

  final int sampleRate;
  final Map<String, Uint8List> _cache = {};

  Uint8List tone(int midi, Instrument instrument) {
    final key = '$midi:${instrument.timbre.name}:${instrument.gain}';
    return _cache.putIfAbsent(
      key,
      () => encodeWav(
        renderTone(
          midi: midi,
          timbre: instrument.timbre,
          gain: instrument.gain,
          sampleRate: sampleRate,
        ),
        sampleRate: sampleRate,
      ),
    );
  }

  int get size => _cache.length;
}
