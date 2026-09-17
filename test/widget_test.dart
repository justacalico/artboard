import 'package:artboard/app.dart';
import 'package:artboard/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app resolves English strings', (tester) async {
    await tester.pumpWidget(const ArtboardApp());
    final context = tester.element(find.byType(Scaffold));
    expect(AppLocalizations.of(context).play, 'Play');
  });

  testWidgets('app resolves Chinese strings', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SizedBox()),
      ),
    );
    final context = tester.element(find.byType(Scaffold));
    expect(AppLocalizations.of(context).play, '播放');
    expect(AppLocalizations.of(context).layerLabel(2), '第 2 层');
  });
}
