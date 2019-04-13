import 'package:beta_lister/src/utils.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

enum Status { error, no, yes }
enum Action {
  refresh,
  support,
  review,
  website,
}

const actionLabel = <Action, String>{
  Action.refresh: "menu.refresh",
  Action.support: "menu.support",
  Action.review: "menu.review",
  Action.website: "menu.website",
};

const actionIcons = <Action, IconData>{
  Action.refresh: Icons.refresh,
  Action.support: Icons.email,
  Action.review: Icons.star,
  Action.website: Icons.web,
};

void main() => runApp(App());

class App extends StatelessWidget {
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
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Application> _apps;
  Map<String, Status> _appStatues;
  var _loading = true;
  var _error = false;

  @override
  void initState() {
    super.initState();

    _fetchApps();
  }

  Future<void> _fetchApps() async {
    setState(() {
      _loading = true;
      _error = false;
      _appStatues = null;
    });

    // Get system apps
    final apps = await DeviceApps.getInstalledApplications(
      includeSystemApps: true,
      onlyAppsWithLaunchIntent: true,
      includeAppIcons: true,
    );

    apps.sort((app1, app2) {
      return app1.appName.compareTo(app2.appName);
    });

    setState(() {
      _apps = apps;
    });

    final appStatues =
        await fetchPackages(apps.map((app) => app.packageName).toList());

    setState(() {
      _appStatues = appStatues;
      _loading = false;
      _error = appStatues == null;

      // Sort app by beta -> error -> no beta
      if (appStatues != null) {
        _apps.sort((app1, app2) {
          final app1Info = appStatues[app1.packageName];
          final app2Info = appStatues[app2.packageName];
          return app1Info == Status.yes && app2Info == Status.no
              ? -1
              : app1Info == app2Info
                  ? (app1.appName.compareTo(app2.appName))
                  : app1Info == Status.yes ? -1 : 1;
        });
      }
    });
  }

  void _showAppSheet(Application app) {
    // Building icon out of building to avoid flashing on rebuild (drag/tap)
    final icon = _buildAppIcon(app);

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        final status =
            _appStatues != null ? _appStatues[app.packageName] : null;

        final statusText = status == null
            ? FlutterI18n.translate(context, "status.fetching")
            : status == Status.yes
                ? FlutterI18n.translate(context, "status.available")
                : status == Status.no
                    ? FlutterI18n.translate(context, "status.unavailable")
                    : FlutterI18n.translate(context, "status.error");

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
              _appStatues != null ? _appStatues[app.packageName] : null,
            ),
            title: Text(statusText),
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

  Widget _buildAppIcon(Application app) {
    return app is ApplicationWithIcon
        ? Image.memory(
            app.icon,
            width: 32,
          )
        : Icon(Icons.not_interested);
    ;
  }

  Widget _buildAppTile(Application app) {
    final beta =
        _appStatues != null && _appStatues[app.packageName] == Status.yes;

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
        _appStatues != null ? _appStatues[app.packageName] : null,
      ),
      onTap: beta
          ? () => launchUrl(
              "https://play.google.com/apps/testing/${app.packageName}")
          : null,
      onLongPress: () => _showAppSheet(app),
    );
  }

  Widget _buildAppStatusIcon(Status status) {
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
      case Action.refresh:
        _fetchApps();
        break;
      case Action.support:
        launchUrl("mailto:support@betalister.app");
        break;
      case Action.review:
        launchUrl(
          "https://play.google.com/store/apps/details?id=app.betalister",
        );
        break;
      case Action.website:
        launchUrl("https://betalister.app");
        break;
    }
  }

  Widget _buildFirstTile(BuildContext context) {
    final firstTileTitle = _loading
        ? FlutterI18n.translate(context, "info.fetching")
        : _error
            ? FlutterI18n.translate(context, "info.error")
            : FlutterI18n.translate(context, "info.fetched");

    final firstTileLeading = Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Center(
          child: _loading
              ? CircularProgressIndicator(strokeWidth: 3)
              : _error ? Icon(Icons.error) : Icon(Icons.cloud_done),
        ),
      ),
    );

    return ListTile(
      isThreeLine: true,
      leading: firstTileLeading,
      title: Text(firstTileTitle),
      subtitle: Text(FlutterI18n.translate(context, "info.tap")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = Action.values
        .map<PopupMenuItem<Action>>(
          (action) => PopupMenuItem<Action>(
                value: action,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(actionIcons[action]),
                  title:
                      Text(FlutterI18n.translate(context, actionLabel[action])),
                ),
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
          offset: const Offset(0, 4),
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: ListView.builder(
            itemCount: (_apps?.length ?? 0) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildFirstTile(context);
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
