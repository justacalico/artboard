// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Artboard';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get penTool => 'Pen';

  @override
  String get eraserTool => 'Eraser';

  @override
  String get undo => 'Undo';

  @override
  String get clearCanvas => 'Clear canvas';

  @override
  String get surpriseMe => 'Surprise me';

  @override
  String get exportLoop => 'Export loop as WAV';

  @override
  String get exportStarted => 'Rendering loop…';

  @override
  String get exportDone => 'Loop exported';

  @override
  String get tempo => 'Tempo';

  @override
  String get decreaseTempo => 'Decrease tempo';

  @override
  String get increaseTempo => 'Increase tempo';

  @override
  String get chooseScale => 'Choose a scale';

  @override
  String get chooseTimbre => 'Choose a sound';

  @override
  String get scaleMajor => 'Major';

  @override
  String get scaleMinor => 'Minor';

  @override
  String get scalePentatonicMajor => 'Major pentatonic';

  @override
  String get scalePentatonicMinor => 'Minor pentatonic';

  @override
  String get scaleDorian => 'Dorian';

  @override
  String get scaleBlues => 'Blues';

  @override
  String get timbreSine => 'Sine';

  @override
  String get timbreTriangle => 'Triangle';

  @override
  String get timbreSquare => 'Square';

  @override
  String get timbreSawtooth => 'Sawtooth';

  @override
  String get octaveUp => 'Octave up';

  @override
  String get octaveDown => 'Octave down';

  @override
  String layerLabel(int number) {
    return 'Layer $number';
  }

  @override
  String get strokeThin => 'Thin stroke';

  @override
  String get strokeMedium => 'Medium stroke';

  @override
  String get strokeThick => 'Thick stroke';

  @override
  String get saveDrawing => 'Save drawing';

  @override
  String get restoreDrawing => 'Restore saved drawing';

  @override
  String get drawingSaved => 'Drawing saved';

  @override
  String get drawingRestored => 'Drawing restored';

  @override
  String get nothingToRestore => 'No saved drawing yet';

  @override
  String get helpTooltip => 'How it works';

  @override
  String get helpBody =>
      'Draw on the paper, then press play. The scan line turns your drawing into music: height is pitch, colour is the instrument.';

  @override
  String get close => 'Close';
}
