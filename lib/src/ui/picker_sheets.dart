import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../music/music_controller.dart';
import '../music/scale.dart';
import '../music/timbre.dart';

String scaleName(AppLocalizations l10n, ScaleType scale) => switch (scale) {
      ScaleType.major => l10n.scaleMajor,
      ScaleType.minor => l10n.scaleMinor,
      ScaleType.pentatonicMajor => l10n.scalePentatonicMajor,
      ScaleType.pentatonicMinor => l10n.scalePentatonicMinor,
      ScaleType.dorian => l10n.scaleDorian,
      ScaleType.blues => l10n.scaleBlues,
    };

String timbreName(AppLocalizations l10n, Timbre timbre) => switch (timbre) {
      Timbre.sine => l10n.timbreSine,
      Timbre.triangle => l10n.timbreTriangle,
      Timbre.square => l10n.timbreSquare,
      Timbre.sawtooth => l10n.timbreSawtooth,
    };

/// Bottom sheet listing every scale.
Future<void> showScalePicker(BuildContext context, MusicController music) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: RadioGroup<ScaleType>(
        groupValue: music.scale,
        onChanged: (value) {
          if (value != null) music.selectScale(value);
          Navigator.of(context).pop();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(l10n.chooseScale, style: _sheetTitle)),
            for (final scale in ScaleType.values)
              RadioListTile<ScaleType>(
                title: Text(scaleName(l10n, scale)),
                value: scale,
              ),
          ],
        ),
      ),
    ),
  );
}

/// Bottom sheet picking the instrument of the active colour.
Future<void> showTimbrePicker(
  BuildContext context,
  MusicController music,
  int colorValue,
) {
  final l10n = AppLocalizations.of(context);
  final current = music.instrumentFor(colorValue).timbre;
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: RadioGroup<Timbre>(
        groupValue: current,
        onChanged: (value) {
          if (value != null) {
            final old = music.instrumentFor(colorValue);
            music.selectInstrument(
              colorValue,
              Instrument(value, octaveOffset: old.octaveOffset, gain: old.gain),
            );
          }
          Navigator.of(context).pop();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(l10n.chooseTimbre, style: _sheetTitle)),
            for (final timbre in Timbre.values)
              RadioListTile<Timbre>(
                title: Text(timbreName(l10n, timbre)),
                value: timbre,
              ),
          ],
        ),
      ),
    ),
  );
}

const _sheetTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
