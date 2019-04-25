import 'package:beta_lister/src/analytics.dart';
import 'package:beta_lister/src/appTile.dart';
import 'package:beta_lister/src/onboarding.dart';
import 'package:beta_lister/src/utils.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

enum AppStatus { error, no, yes }

enum LoadingStatus { loading, fetching, error, fetched }

const loadingStatusLabel = <LoadingStatus, String>{
  LoadingStatus.loading: "info.loading",
  LoadingStatus.fetching: "info.fetching",
  LoadingStatus.error: "info.error",
  LoadingStatus.fetched: "info.fetched",
};
enum MenuAction {
  refresh,
  support,
  review,
  website,
  onboarding,
}

const menuActionLabel = <MenuAction, String>{
  MenuAction.refresh: "menu.refresh",
  MenuAction.support: "menu.support",
  MenuAction.review: "menu.review",
  MenuAction.website: "menu.website",
  MenuAction.onboarding: "menu.onboarding",
};

const menuActionIcons = <MenuAction, IconData>{
  MenuAction.refresh: Icons.refresh,
  MenuAction.support: Icons.email,
  MenuAction.review: Icons.star,
  MenuAction.website: Icons.web,
  MenuAction.onboarding: Icons.help,
};

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Application> _apps;
  Map<String, AppStatus> _appStatues;
  var _status = LoadingStatus.loading;
  var _search = "";
  var _searching = false;

  @override
  void initState() {
    super.initState();

    _fetchApps();
  }

  Future<void> _fetchApps() async {
    analytics.logEvent(name: "load_betas");

    setState(() {
      _status = LoadingStatus.loading;
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
      _status = LoadingStatus.fetching;
    });

    final appStatues =
        await fetchPackages(apps.map((app) => app.packageName).toList());

    setState(() {
      _appStatues = appStatues;
      _status =
          appStatues == null ? LoadingStatus.error : LoadingStatus.fetched;

      // Sort app by beta -> error -> no beta
      if (appStatues != null) {
        _apps.sort((app1, app2) {
          final app1Info = appStatues[app1.packageName];
          final app2Info = appStatues[app2.packageName];
          return app1Info == AppStatus.yes && app2Info == AppStatus.no
              ? -1
              : app1Info == app2Info
                  ? (app1.appName.compareTo(app2.appName))
                  : app1Info == AppStatus.yes ? -1 : 1;
        });
      }
    });
  }

  void _onAction(MenuAction action) {
    switch (action) {
      case MenuAction.refresh:
        analytics.logEvent(name: "click_refresh");
        _fetchApps();
        break;
      case MenuAction.support:
        analytics.logEvent(name: "click_support");
        launchUrl("mailto:support@betalister.app");
        break;
      case MenuAction.review:
        analytics.logEvent(name: "click_review");
        launchUrl(
          "https://play.google.com/store/apps/details?id=app.betalister",
        );
        break;
      case MenuAction.website:
        analytics.logEvent(name: "click_website");
        launchUrl("https://betalister.app");
        break;
      case MenuAction.onboarding:
        analytics.logEvent(name: "click_onboarding");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Onboarding(),
          ),
        );
        break;
    }
  }

  Widget _buildFirstTile(BuildContext context) {
    final firstTileLeading = Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Center(
          child: _status == LoadingStatus.error
              ? Icon(Icons.error)
              : _status == LoadingStatus.fetched
                  ? Icon(Icons.cloud_done)
                  : CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );

    return ListTile(
      isThreeLine: true,
      leading: firstTileLeading,
      title: Text(FlutterI18n.translate(context, loadingStatusLabel[_status])),
      subtitle: Text(FlutterI18n.translate(context, "info.tap")),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      style: Theme.of(context).textTheme.title.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
      autocorrect: false,
      autofocus: true,
      onChanged: (value) {
        setState(() {
          _search = value;
        });
      },
      decoration: InputDecoration(
        hintText: MaterialLocalizations.of(context).searchFieldLabel + "...",
        hintStyle: Theme.of(context).textTheme.title.copyWith(
              color: Colors.white70,
            ),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildSearchButton() {
    return _searching
        ? IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                _searching = false;
                _search = "";
              });
            },
          )
        : IconButton(
            tooltip: MaterialLocalizations.of(context).searchFieldLabel,
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                _searching = true;
              });
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final actions = MenuAction.values
        .map<PopupMenuItem<MenuAction>>(
          (action) => PopupMenuItem<MenuAction>(
                value: action,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(menuActionIcons[action]),
                  title: Text(
                      FlutterI18n.translate(context, menuActionLabel[action])),
                ),
              ),
        )
        .toList();

    final appBar = AppBar(
      title: !_searching ? Text("Beta Lister") : _buildSearchField(),
      actions: <Widget>[
        _buildSearchButton(),
        PopupMenuButton<MenuAction>(
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

              if (_searching) {
                final search = _search.toLowerCase().replaceAll(" ", "");
                final appName = app.appName.toLowerCase().replaceAll(" ", "");
                final packageName =
                    app.packageName.toLowerCase().replaceAll(" ", "");

                if (!appName.contains(search) &&
                    !packageName.contains(search)) {
                  return Container();
                }
              }

              final appStatus =
                  _appStatues != null ? _appStatues[app.packageName] : null;

              return AppTile(
                key: Key(app.packageName),
                app: app,
                status: appStatus,
              );
            },
          ),
        ),
      ),
    );
  }
}
