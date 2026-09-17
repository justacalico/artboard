import 'package:flutter/material.dart';

import 'l10n/generated/app_localizations.dart';
import 'src/audio/loop_exporter.dart';
import 'src/audio/note_player.dart';
import 'src/drawing/drawing_store.dart';
import 'src/ui/canvas_page.dart';

class ArtboardApp extends StatelessWidget {
  const ArtboardApp({super.key, this.notePlayer, this.exporter, this.store, this.locale});

  final NotePlayer? notePlayer;
  final LoopExporter? exporter;
  final DrawingStore? store;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: locale,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Quicksand',
        scaffoldBackgroundColor: const Color(0xFFF5F3EE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B4BC4),
          surface: const Color(0xFFF5F3EE),
        ),
      ),
      home: CanvasPage(notePlayer: notePlayer, exporter: exporter, store: store),
    );
  }
}
