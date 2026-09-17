import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Home screen: drawing paper on top, tool decks below.
class CanvasPage extends StatelessWidget {
  const CanvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(child: Text(l10n.appTitle)),
    );
  }
}
