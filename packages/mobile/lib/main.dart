import 'package:beta_lister/src/home.dart';
import 'package:beta_lister/src/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  final prefs = await SharedPreferences.getInstance();
  final doneOnboarding = prefs.getBool("doneOnboarding") ?? false;

  runApp(App(
    doneOnboarding: doneOnboarding,
  ));
}

class App extends StatelessWidget {
  final bool doneOnboarding;

  const App({Key key, this.doneOnboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        FlutterI18nDelegate(
          fallbackFile: "en",
          path: "assets/i18n",
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('fr'),
      ],
      title: 'Beta Lister',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: doneOnboarding ? Home() : Onboarding(),
    );
  }
}
