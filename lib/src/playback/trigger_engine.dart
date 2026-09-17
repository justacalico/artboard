import 'dart:ui';

import '../drawing/geometry.dart';
import '../drawing/stroke.dart';
import '../music/pitch_mapper.dart';

/// One note fired by the scan line.
class NoteTrigger {
  const NoteTrigger({required this.midi, required this.colorValue});

  final int midi;
  final int colorValue;
}

/// A visible dot where the scan line currently crosses a stroke.
class ScanHit {
  const ScanHit({required this.point});

  final Offset point;
}

class ScanResult {
  const ScanResult({required this.triggers, required this.hits});

  final List<NoteTrigger> triggers;
  final List<ScanHit> hits;
}

/// Converts stroke geometry into note events as the playhead sweeps.
///
/// A segment fires once per sweep when the playhead enters its x range,
/// even when a fast sweep jumps completely over the segment.
class TriggerEngine {
  TriggerEngine({required this.mapper, required this.canvasHeight});

  final PitchMapper mapper;
  final double canvasHeight;

  final Set<int> _firedThisSweep = {};

  /// Scans [strokes] between [prevX] and [x]. Call [reset] when the
  /// playhead wraps back to the left edge.
  ScanResult scan(List<Stroke> strokes, double prevX, double x) {
    final triggers = <NoteTrigger>[];
    final hits = <ScanHit>[];

    for (var s = 0; s < strokes.length; s++) {
      final stroke = strokes[s];
      for (var i = 0; i + 1 < stroke.points.length; i++) {
        final a = stroke.points[i];
        final b = stroke.points[i + 1];
        final range = segmentXRange(a, b);
        if (range == null) continue;

        final key = s * 100000 + i;
        if (range.$1 >= prevX && range.$1 < x && !_firedThisSweep.contains(key)) {
          _firedThisSweep.add(key);
          final triggerX = range.$1 < x ? range.$1.clamp(prevX, x) : x;
          final y = segmentYAtX(a, b, triggerX) ?? a.dy;
          triggers.add(NoteTrigger(
            midi: mapper.midiAt(y / canvasHeight),
            colorValue: stroke.colorValue,
          ));
        }

        final hitY = segmentYAtX(a, b, x);
        if (hitY != null) hits.add(ScanHit(point: Offset(x, hitY)));
      }
    }
    return ScanResult(triggers: triggers, hits: hits);
  }

  void reset() => _firedThisSweep.clear();
}
