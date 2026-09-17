import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../music/pitch_mapper.dart';
import 'geometry.dart';
import 'palette.dart';
import 'stroke.dart';

enum DrawTool { pen, eraser }

class _Edit {
  const _Edit.added(this.layer, this.stroke) : erased = null;
  const _Edit.erased(this.layer, this.erased) : stroke = null;

  final int layer;
  final Stroke? stroke;
  final List<Stroke>? erased;
}

/// Holds every drawn stroke across the layers plus tool state.
class DrawingController extends ChangeNotifier {
  DrawingController({int layerCount = 3})
      : layers = List.generate(layerCount, (_) => <Stroke>[]);

  /// All strokes, outer list indexed by layer.
  final List<List<Stroke>> layers;

  final List<_Edit> _history = [];

  int _activeLayer = 0;
  DrawTool _tool = DrawTool.pen;
  int _colorValue = kStrokeColors[2].toARGB32();
  double _strokeWidth = kStrokeWidths[0];

  Stroke? _draft;

  int get activeLayer => _activeLayer;
  DrawTool get tool => _tool;
  int get colorValue => _colorValue;
  double get strokeWidth => _strokeWidth;
  Stroke? get draft => _draft;
  bool get canUndo => _history.isNotEmpty;
  bool get isEmpty => layers.every((l) => l.isEmpty);

  /// Every stroke from every layer, in draw order.
  List<Stroke> get allStrokes => layers.expand((l) => l).toList();

  void selectLayer(int index) {
    if (index == _activeLayer) return;
    _activeLayer = index;
    notifyListeners();
  }

  void selectTool(DrawTool tool) {
    if (tool == _tool) return;
    _tool = tool;
    notifyListeners();
  }

  void selectColor(int argb) {
    if (argb == _colorValue) return;
    _colorValue = argb;
    notifyListeners();
  }

  void selectWidth(double width) {
    if (width == _strokeWidth) return;
    _strokeWidth = width;
    notifyListeners();
  }

  void beginStroke(Offset point) {
    if (_tool == DrawTool.eraser) {
      eraseAt(point);
      return;
    }
    _draft = Stroke(points: [point], colorValue: _colorValue, width: _strokeWidth);
    notifyListeners();
  }

  void extendStroke(Offset point) {
    if (_tool == DrawTool.eraser) {
      eraseAt(point);
      return;
    }
    final draft = _draft;
    if (draft == null) return;
    final last = draft.points.last;
    if ((point - last).distance < 1.5) return;
    _draft = draft.copyWith(points: [...draft.points, point]);
    notifyListeners();
  }

  void endStroke() {
    final draft = _draft;
    if (draft == null) return;
    _draft = null;
    if (draft.points.isEmpty) return;
    layers[_activeLayer].add(draft);
    _history.add(_Edit.added(_activeLayer, draft));
    notifyListeners();
  }

  /// Removes strokes passing within [radius] of [point] on the active layer.
  void eraseAt(Offset point, {double radius = 14}) {
    final layer = layers[_activeLayer];
    final removed = <Stroke>[];
    layer.removeWhere((stroke) {
      final hit = _strokeNearPoint(stroke, point, radius + stroke.width / 2);
      if (hit) removed.add(stroke);
      return hit;
    });
    if (removed.isNotEmpty) {
      _history.add(_Edit.erased(_activeLayer, removed));
      notifyListeners();
    }
  }

  bool _strokeNearPoint(Stroke stroke, Offset point, double radius) {
    for (var i = 0; i + 1 < stroke.points.length; i++) {
      if (segmentNearPoint(point, stroke.points[i], stroke.points[i + 1], radius)) {
        return true;
      }
    }
    return stroke.points.length == 1 &&
        (stroke.points.first - point).distance <= radius;
  }

  void undo() {
    final edit = _history.isEmpty ? null : _history.removeLast();
    if (edit == null) return;
    if (edit.stroke != null) {
      layers[edit.layer].remove(edit.stroke);
    } else {
      layers[edit.layer].addAll(edit.erased!);
    }
    notifyListeners();
  }

  void clearAll() {
    for (final layer in layers) {
      layer.clear();
    }
    _history.clear();
    _draft = null;
    notifyListeners();
  }

  /// Draws a short random melody snapped to the current key.
  void doodle(Random random, PitchMapper mapper, Size size) {
    const minNote = 57;
    const maxNote = 79;
    var midi = minNote + random.nextInt(12);
    for (var s = 0; s < 3; s++) {
      final points = <Offset>[];
      var x = size.width * (0.1 + random.nextDouble() * 0.2);
      final endX = size.width * (0.7 + random.nextDouble() * 0.25);
      while (x < endX) {
        midi = (midi + random.nextInt(7) - 3).clamp(minNote, maxNote);
        points.add(Offset(x, mapper.fractionForMidi(midi) * size.height));
        x += size.width * (0.06 + random.nextDouble() * 0.1);
      }
      if (points.length > 1) {
        final stroke = Stroke(
          points: points,
          colorValue: kStrokeColors[random.nextInt(kStrokeColors.length)].toARGB32(),
          width: kStrokeWidths[random.nextInt(kStrokeWidths.length)],
        );
        layers[_activeLayer].add(stroke);
        _history.add(_Edit.added(_activeLayer, stroke));
      }
    }
    notifyListeners();
  }

  List<dynamic> toJson() => [
        for (final layer in layers) [for (final s in layer) s.toJson()],
      ];

  void loadJson(List<dynamic> data) {
    clearAll();
    for (var i = 0; i < data.length && i < layers.length; i++) {
      for (final raw in data[i] as List) {
        layers[i].add(Stroke.fromJson(Map<String, dynamic>.from(raw as Map)));
      }
    }
    notifyListeners();
  }
}
