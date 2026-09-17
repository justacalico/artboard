import 'dart:math';
import 'dart:typed_data';

import '../drawing/geometry.dart';
import '../drawing/stroke.dart';
import '../music/pitch_mapper.dart';
import '../music/timbre.dart';
import 'synth.dart';
import 'wav_encoder.dart';

/// One scheduled note inside a rendered loop.
class LoopEvent {
  const LoopEvent({required this.atSeconds, required this.midi, required this.instrument, required this.seconds});

  final double atSeconds;
  final int midi;
  final Instrument instrument;
  final double seconds;
}

/// Seconds one full sweep takes at [tempo] (four beats per loop).
double loopSeconds(double tempo) => 240 / tempo;

/// Timeline of every note a drawing produces in one sweep.
List<LoopEvent> scheduleLoop({
  required List<Stroke> strokes,
  required PitchMapper mapper,
  required Instrument Function(int color) instrumentFor,
  required double tempo,
  required double width,
  required double height,
  int maxEvents = 512,
}) {
  final pxPerSecond = width * tempo / (60 * 4);
  final events = <LoopEvent>[];
  for (final stroke in strokes) {
    for (var i = 0; i + 1 < stroke.points.length; i++) {
      final a = stroke.points[i];
      final b = stroke.points[i + 1];
      final range = segmentXRange(a, b);
      if (range == null) continue;
      final y = segmentYAtX(a, b, range.$1) ?? a.dy;
      final span = (range.$2 - range.$1) / pxPerSecond;
      events.add(LoopEvent(
        atSeconds: range.$1 / pxPerSecond,
        midi: mapper.midiAt(y / height),
        instrument: instrumentFor(stroke.colorValue),
        seconds: span.clamp(0.08, 0.6),
      ));
      if (events.length >= maxEvents) return events;
    }
  }
  events.sort((a, b) => a.atSeconds.compareTo(b.atSeconds));
  return events;
}

/// Offline-mixes one full sweep into a WAV file for export.
Uint8List renderLoopWav({
  required List<Stroke> strokes,
  required PitchMapper mapper,
  required Instrument Function(int color) instrumentFor,
  required double tempo,
  required double width,
  required double height,
  int sampleRate = 22050,
}) {
  final events = scheduleLoop(
    strokes: strokes,
    mapper: mapper,
    instrumentFor: instrumentFor,
    tempo: tempo,
    width: width,
    height: height,
  );
  final pxPerSecond = width * tempo / (60 * 4);
  final total = (width / pxPerSecond * sampleRate).round() + sampleRate ~/ 2;
  final mix = Float64List(total);

  for (final event in events) {
    final pcm = renderTone(
      midi: (event.midi + event.instrument.octaveOffset * 12).clamp(21, 108),
      timbre: event.instrument.timbre,
      seconds: event.seconds,
      sampleRate: sampleRate,
      gain: event.instrument.gain,
    );
    final start = (event.atSeconds * sampleRate).round();
    for (var i = 0; i < pcm.length && start + i < total; i++) {
      mix[start + i] += pcm[i];
    }
  }

  var peak = 1.0;
  for (final s in mix) {
    peak = max(peak, s.abs());
  }
  final out = Int16List(total);
  for (var i = 0; i < total; i++) {
    out[i] = (mix[i] / peak * 30000).round();
  }
  return encodeWav(out, sampleRate: sampleRate);
}
