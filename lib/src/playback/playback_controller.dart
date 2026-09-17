import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../drawing/stroke.dart';
import '../music/pitch_mapper.dart';
import 'playhead.dart';
import 'trigger_engine.dart';

/// Drives the scan line and forwards note events to the audio layer.
class PlaybackController extends ChangeNotifier {
  PlaybackController(
    this._strokes,
    this._mapper,
    this._onNotes, {
    double Function()? tempo,
  }) : _tempo = tempo ?? (() => 90);

  final List<Stroke> Function() _strokes;
  final PitchMapper Function() _mapper;
  final void Function(List<NoteTrigger>) _onNotes;
  final double Function() _tempo;

  /// Length of one sweep, in beats.
  static const loopBeats = 4;

  Playhead? _head;
  TriggerEngine? _engine;
  Timer? _timer;
  Size _size = Size.zero;

  bool _playing = false;
  double _x = 0;
  List<ScanHit> _hits = const [];

  bool get playing => _playing;
  double get x => _x;
  List<ScanHit> get hits => _hits;
  Size get size => _size;

  /// Rebuilds the engine when the canvas is laid out or resized.
  void configure(Size size) {
    if (size == _size) return;
    _size = size;
    _engine = TriggerEngine(mapper: _mapper(), canvasHeight: size.height);
    _head = Playhead(width: size.width, speed: _speed());
    if (!_playing) _x = 0;
  }

  double _speed() => _size.width * _tempo() / (60 * loopBeats);

  void play() {
    if (_playing || _size == Size.zero) return;
    _playing = true;
    _timer ??= Timer.periodic(const Duration(milliseconds: 16), _tick);
    notifyListeners();
  }

  void pause() {
    _playing = false;
    _timer?.cancel();
    _timer = null;
    _hits = const [];
    notifyListeners();
  }

  void toggle() => _playing ? pause() : play();

  void _tick(Timer timer) => step(const Duration(milliseconds: 16));

  /// Advances the scan line; exposed for tests.
  void step(Duration dt) {
    final head = _head;
    final engine = _engine;
    if (!_playing || head == null || engine == null) return;
    head.speed = _speed();
    final prev = head.x;
    final strokes = _strokes();
    final triggers = <NoteTrigger>[];

    if (head.advance(dt)) {
      triggers.addAll(engine.scan(strokes, prev, _size.width).triggers);
      engine.reset();
      final result = engine.scan(strokes, 0, head.x);
      triggers.addAll(result.triggers);
      _hits = result.hits;
    } else {
      final result = engine.scan(strokes, prev, head.x);
      triggers.addAll(result.triggers);
      _hits = result.hits;
    }

    _x = head.x;
    if (triggers.isNotEmpty) _onNotes(triggers);
    notifyListeners();
  }

  /// Called when the drawing changes so a wiped canvas goes silent.
  void refresh() {
    if (_playing) notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
