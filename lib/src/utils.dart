import 'package:beta_lister/main.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<Map<String, Status>> fetchPackages(List<String> packageNames) async {
  final Map results = await CloudFunctions.instance.call(
    functionName: 'checkPackages',
    parameters: {
      "packageNames": packageNames,
    },
  );

  final appStatues = new Map<String, Status>();

  results.forEach((packageName, status) {
    appStatues[packageName] =
        status == null ? Status.error : (status ? Status.yes : Status.no);
  });

  return appStatues;
}
