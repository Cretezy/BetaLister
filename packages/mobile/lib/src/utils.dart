import 'package:beta_lister/src/home.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
    final Map results = await CloudFunctions.instance.call(
      functionName: 'checkPackages',
      parameters: {
        "packageNames": packageNames,
      },
    );

    if (results == null) {
      throw "Results are null, malformed request?";
    }

    final appStatues = new Map<String, AppStatus>();

    results.forEach((packageName, status) {
      appStatues[packageName] = status == null
          ? AppStatus.error
          : (status ? AppStatus.yes : AppStatus.no);
    });

    return appStatues;
  } catch (error) {
    print("Error fetching packages: $error");
    return null;
  }
}