import 'package:beta_lister/src/home.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<Map<String, AppStatus>> fetchPackages(List<String> packageNames) async {
  try {
    final response = await Dio().post<Map>(
      "https://us-central1-betalister-app.cloudfunctions.net/checkPackages",
      data: {
        "data": {
          "packageNames": packageNames,
        }
      },
    );

    if (!(response.data["result"] is Map)) {
      throw "Results are null, malformed request?";
    }

    final appStatues = new Map<String, AppStatus>();

    (response.data["result"] as Map).forEach((packageName, status) {
      appStatues[packageName] = status == null
          ? AppStatus.error
          : (status ? AppStatus.yes : AppStatus.no);
    });

    return appStatues;
  } catch (error, stackTrack) {
    print("Error fetching packages: $error $stackTrack");
    Crashlytics.instance.recordError(
      error,
      stackTrack,
      context: "fetchPackages",
    );
    return null;
  }
}
