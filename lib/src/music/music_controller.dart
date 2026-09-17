import 'package:flutter/foundation.dart';

import 'pitch_mapper.dart';
import 'scale.dart';
import 'timbre.dart';

/// Everything that decides how the drawing sounds: key, scale, octave,
/// tempo and which instrument each colour plays.
class MusicController extends ChangeNotifier {
  MusicController() : _instruments = defaultInstruments();

  int _rootMidi = kRootNotes.first.$2;
  ScaleType _scale = ScaleType.pentatonicMajor;
  int _octaveShift = 0;
  double _tempo = 90;

  /// Per-colour voice, keyed by ARGB value.
  final Map<int, Instrument> _instruments;

  static const minTempo = 40.0;
  static const maxTempo = 200.0;
  static const tempoStep = 5.0;
  static const minOctave = -2;
  static const maxOctave = 2;

  int get rootMidi => _rootMidi;
  ScaleType get scale => _scale;
  int get octaveShift => _octaveShift;
  double get tempo => _tempo;

  PitchMapper get mapper => PitchMapper(
        scale: _scale,
        rootMidi: _rootMidi,
        octaveShift: _octaveShift,
      );

  Instrument instrumentFor(int colorValue) =>
      _instruments[colorValue] ?? const Instrument(Timbre.sine);

  void selectRoot(int midi) {
    if (midi == _rootMidi) return;
    _rootMidi = midi;
    notifyListeners();
  }

  void selectScale(ScaleType scale) {
    if (scale == _scale) return;
    _scale = scale;
    notifyListeners();
  }

  void selectInstrument(int colorValue, Instrument instrument) {
    _instruments[colorValue] = instrument;
    notifyListeners();
  }

  void bumpTempo(double delta) {
    final next = (_tempo + delta).clamp(minTempo, maxTempo);
    if (next == _tempo) return;
    _tempo = next;
    notifyListeners();
  }

  void bumpOctave(int delta) {
    final next = (_octaveShift + delta).clamp(minOctave, maxOctave);
    if (next == _octaveShift) return;
    _octaveShift = next;
    notifyListeners();
  }
}
