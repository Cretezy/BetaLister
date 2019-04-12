import 'package:beta_lister/src/utils.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

enum Status { error, no, yes }
enum Action { reload }

const actionLabels = <Action, String>{Action.reload: "Reload"};

void main() => runApp(App());

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  List<Application> _apps;
  var _appStatues = new Map<String, Status>();
  var _loading = true;

  @override
  void initState() {
    super.initState();

    _fetchApps();
  }

  Future<void> _fetchApps() async {
    setState(() {
      this._loading = true;
    });

    // Get system apps
    final apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
      includeAppIcons: true,
    );

    setState(() {
      this._apps = apps;
    });

    final appStatues =
        await fetchPackages(apps.map((app) => app.packageName).toList());

    setState(() {
      this._appStatues = appStatues;
      _loading = false;

      // Sort app by beta -> error -> no beta
      apps.sort((app1, app2) {
        final app1Info = appStatues[app1.packageName];
        final app2Info = appStatues[app2.packageName];
        return app1Info == Status.yes && app2Info == Status.no
            ? -1
            : app1Info == app2Info ? 0 : app1Info == Status.yes ? -1 : 1;
      });
    });
  }

  Widget _buildAppTile(Application app) {
    final onTap = () =>
        launchUrl("https://play.google.com/apps/testing/${app.packageName}");

    return ListTile(
      leading: app is ApplicationWithIcon
          ? Image.memory(
              app.icon,
              width: 32,
            )
          : Icon(Icons.not_interested),
      title: Text(app.appName),
      subtitle: Text("${app.packageName} (${app.versionName})"),
      trailing: _buildTrailing(_appStatues[app.packageName]),
      onTap: _appStatues[app.packageName] == Status.yes ? onTap : null,
      onLongPress: onTap,
    );
  }

  Widget _buildTrailing(Status status) {
    switch (status) {
      case Status.error:
        return Icon(Icons.error);
      case Status.no:
        return Icon(Icons.close);
      case Status.yes:
        return Icon(Icons.check);
      default:
        return null;
    }
  }

  void _onAction(Action action) {
    switch (action) {
      case Action.reload:
        _fetchApps();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Action>[Action.reload]
        .map<PopupMenuItem<Action>>(
          (Action action) => PopupMenuItem<Action>(
                value: action,
                child: Text(actionLabels[action]),
              ),
        )
        .toList();

    final appBar = AppBar(
      title: Text("Beta Lister"),
      actions: <Widget>[
        PopupMenuButton<Action>(
          icon: Icon(Icons.more_horiz),
          onSelected: _onAction,
          itemBuilder: (context) => actions,
        ),
      ],
    );

    final firstTile = ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: _loading
                ? CircularProgressIndicator(strokeWidth: 3)
                : Icon(Icons.cloud_done),
          ),
        ),
      ),
      title: Text(
        _loading ? "Fetching app beta statues..." : "App beta statues loaded!",
      ),
    );

    return MaterialApp(
      title: 'Beta Lister',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: appBar,
        body: Center(
          child: ListView.builder(
            itemCount: (_apps?.length ?? 0) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return firstTile;
              }

              final app = _apps[index - 1];
              return _buildAppTile(app);
            },
          ),
        ),
      ),
    );
  }
}
