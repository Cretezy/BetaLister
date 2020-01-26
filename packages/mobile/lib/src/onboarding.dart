import 'package:beta_lister/src/analytics.dart';
import 'package:beta_lister/src/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

const titleStyle = TextStyle(fontSize: 30);
const bodyStyle = TextStyle(fontSize: 18);

class _OnboardingState extends State<Onboarding> {
  @override
  void initState() {
    super.initState();
    analytics.logTutorialBegin();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <PageViewModel>[
      PageViewModel(
        pageColor: Colors.redAccent,
        title: Text(
          FlutterI18n.translate(context, "title"),
          style: titleStyle,
        ),
        mainImage: Image.asset("assets/onboarding/1.png"),
        body: Text(
          FlutterI18n.translate(context, "onboarding.welcomeText"),
          style: bodyStyle,
        ),
      ),
      PageViewModel(
        pageColor: Colors.blueAccent,
        title: Text(
          FlutterI18n.translate(context, "onboarding.enrollTitle"),
          style: titleStyle,
        ),
        mainImage: Image.asset("assets/onboarding/2.png"),
        body: Text(
          FlutterI18n.translate(context, "info.tap"),
          style: bodyStyle,
        ),
      ),
    ];

    return IntroViewsFlutter(
      pages,
      onTapDoneButton: () {
        analytics.logTutorialComplete();

        SharedPreferences.getInstance()
            .then((prefs) => prefs.setBool("doneOnboarding", true));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );
      },
      showSkipButton: false,
      doneText: Text(FlutterI18n.translate(context, "onboarding.done")),
      columnMainAxisAlignment: MainAxisAlignment.center,
    );
  }
}
