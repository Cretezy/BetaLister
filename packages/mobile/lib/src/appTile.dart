import 'package:beta_lister/src/home.dart';
import 'package:beta_lister/src/utils.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

const appStatusLabel = <AppStatus, String>{
  AppStatus.yes: "status.available",
  AppStatus.no: "status.unavailable",
  AppStatus.error: "status.error",
  null: "status.fetching"
};

class AppTile extends StatelessWidget {
  final AppStatus status;
  final Application app;

  const AppTile({
    Key key,
    this.app,
    this.status,
  }) : super(key: key);

  Widget _buildAppStatusIcon(AppStatus status) {
    switch (status) {
      case AppStatus.error:
        return Icon(Icons.error);
      case AppStatus.no:
        return Icon(Icons.close);
      case AppStatus.yes:
        return Icon(Icons.check);
      default:
        return null;
    }
  }

  Widget _buildAppIcon(Application app) {
    return app is ApplicationWithIcon
        ? Image.memory(
            app.icon,
            width: 32,
          )
        : Icon(Icons.error);
  }

  void _showAppSheet(BuildContext context, Application app) {
    // Building icon out of building to avoid flashing on rebuild (drag/tap)
    final icon = _buildAppIcon(app);

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        final children = <Widget>[
          ListTile(
            leading: icon,
            title: Text(app.appName),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(app.packageName),
            subtitle: Text("${app.versionName} (${app.versionCode})"),
          ),
          ListTile(
            leading: _buildAppStatusIcon(
              status,
            ),
            title: Text(FlutterI18n.translate(context, appStatusLabel[status])),
            subtitle: Text(FlutterI18n.translate(context, "viewBetaPage")),
            onTap: () => launchUrl(
                "https://play.google.com/apps/testing/${app.packageName}"),
          ),
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final beta = status == AppStatus.yes;

    final leading = _buildAppIcon(app);

    return ListTile(
      leading: leading,
      title: Text(
        app.appName,
        style: TextStyle(
          fontWeight: beta ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: _buildAppStatusIcon(
        status,
      ),
      onTap: beta
          ? () => launchUrl(
              "https://play.google.com/apps/testing/${app.packageName}")
          : null,
      onLongPress: () => _showAppSheet(context, app),
    );
  }
}
