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

final function = CloudFunctions.instance.getHttpsCallable(
  functionName: 'checkPackages',
);

Future<Map<String, AppStatus>> fetchPackages(List<String> packageNames) async {
  try {
    final HttpsCallableResult results = await function.call({
      "packageNames": packageNames,
    });

    if (results.data == null) {
      throw "Results are null, malformed request?";
    }

    final appStatues = new Map<String, AppStatus>();

    (results.data as Map).forEach((packageName, status) {
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
