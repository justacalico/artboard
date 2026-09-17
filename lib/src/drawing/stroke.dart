import 'dart:ui';

/// A single drawn line: ordered points, a colour and a thickness.
class Stroke {
  const Stroke({
    required this.points,
    required this.colorValue,
    required this.width,
  });

  final List<Offset> points;
  final int colorValue;
  final double width;

  Stroke copyWith({List<Offset>? points}) =>
      Stroke(points: points ?? this.points, colorValue: colorValue, width: width);

  Map<String, dynamic> toJson() => {
        'color': colorValue,
        'width': width,
        'points': [for (final p in points) [p.dx, p.dy]],
      };

  factory Stroke.fromJson(Map<String, dynamic> json) => Stroke(
        colorValue: json['color'] as int,
        width: (json['width'] as num).toDouble(),
        points: [
          for (final p in json['points'] as List)
            Offset((p[0] as num).toDouble(), (p[1] as num).toDouble()),
        ],
      );
}
