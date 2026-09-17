import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Application name shown in the title bar
  ///
  /// In en, this message translates to:
  /// **'Artboard'**
  String get appTitle;

  /// Tooltip for the play button
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Tooltip for the pause button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Tooltip for the pen tool
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get penTool;

  /// Tooltip for the eraser tool
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get eraserTool;

  /// Tooltip for the undo button
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Tooltip for the button that wipes every layer
  ///
  /// In en, this message translates to:
  /// **'Clear canvas'**
  String get clearCanvas;

  /// Tooltip for the button that draws a random doodle
  ///
  /// In en, this message translates to:
  /// **'Surprise me'**
  String get surpriseMe;

  /// Tooltip for the button that renders the loop to an audio file
  ///
  /// In en, this message translates to:
  /// **'Export loop as WAV'**
  String get exportLoop;

  /// Snack bar shown while the audio file renders
  ///
  /// In en, this message translates to:
  /// **'Rendering loop…'**
  String get exportStarted;

  /// Snack bar shown when the audio file is ready
  ///
  /// In en, this message translates to:
  /// **'Loop exported'**
  String get exportDone;

  /// Label for the scan speed control
  ///
  /// In en, this message translates to:
  /// **'Tempo'**
  String get tempo;

  /// Tooltip for the slower button
  ///
  /// In en, this message translates to:
  /// **'Decrease tempo'**
  String get decreaseTempo;

  /// Tooltip for the faster button
  ///
  /// In en, this message translates to:
  /// **'Increase tempo'**
  String get increaseTempo;

  /// Title of the scale picker sheet
  ///
  /// In en, this message translates to:
  /// **'Choose a scale'**
  String get chooseScale;

  /// Title of the timbre picker sheet
  ///
  /// In en, this message translates to:
  /// **'Choose a sound'**
  String get chooseTimbre;

  /// Name of the major scale
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get scaleMajor;

  /// Name of the natural minor scale
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get scaleMinor;

  /// Name of the major pentatonic scale
  ///
  /// In en, this message translates to:
  /// **'Major pentatonic'**
  String get scalePentatonicMajor;

  /// Name of the minor pentatonic scale
  ///
  /// In en, this message translates to:
  /// **'Minor pentatonic'**
  String get scalePentatonicMinor;

  /// Name of the dorian mode
  ///
  /// In en, this message translates to:
  /// **'Dorian'**
  String get scaleDorian;

  /// Name of the blues scale
  ///
  /// In en, this message translates to:
  /// **'Blues'**
  String get scaleBlues;

  /// Sine wave timbre name
  ///
  /// In en, this message translates to:
  /// **'Sine'**
  String get timbreSine;

  /// Triangle wave timbre name
  ///
  /// In en, this message translates to:
  /// **'Triangle'**
  String get timbreTriangle;

  /// Square wave timbre name
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get timbreSquare;

  /// Sawtooth wave timbre name
  ///
  /// In en, this message translates to:
  /// **'Sawtooth'**
  String get timbreSawtooth;

  /// Tooltip for the octave up button
  ///
  /// In en, this message translates to:
  /// **'Octave up'**
  String get octaveUp;

  /// Tooltip for the octave down button
  ///
  /// In en, this message translates to:
  /// **'Octave down'**
  String get octaveDown;

  /// Tooltip for a drawing layer button
  ///
  /// In en, this message translates to:
  /// **'Layer {number}'**
  String layerLabel(int number);

  /// Tooltip for the thin pen width
  ///
  /// In en, this message translates to:
  /// **'Thin stroke'**
  String get strokeThin;

  /// Tooltip for the medium pen width
  ///
  /// In en, this message translates to:
  /// **'Medium stroke'**
  String get strokeMedium;

  /// Tooltip for the thick pen width
  ///
  /// In en, this message translates to:
  /// **'Thick stroke'**
  String get strokeThick;

  /// Menu item that stores the drawing on this device
  ///
  /// In en, this message translates to:
  /// **'Save drawing'**
  String get saveDrawing;

  /// Menu item that reloads the stored drawing
  ///
  /// In en, this message translates to:
  /// **'Restore saved drawing'**
  String get restoreDrawing;

  /// Snack bar shown after the drawing is stored
  ///
  /// In en, this message translates to:
  /// **'Drawing saved'**
  String get drawingSaved;

  /// Snack bar shown after the drawing is reloaded
  ///
  /// In en, this message translates to:
  /// **'Drawing restored'**
  String get drawingRestored;

  /// Snack bar shown when there is nothing stored
  ///
  /// In en, this message translates to:
  /// **'No saved drawing yet'**
  String get nothingToRestore;

  /// Tooltip for the help button
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get helpTooltip;

  /// Explanation paragraph inside the help dialog
  ///
  /// In en, this message translates to:
  /// **'Draw on the paper, then press play. The scan line turns your drawing into music: height is pitch, colour is the instrument.'**
  String get helpBody;

  /// Label for the button that dismisses a dialog
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
