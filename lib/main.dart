import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/pages/attendees/attendees.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/pages/login/login.dart';
import 'package:xrooster/pages/schedule/rooster.dart';
import 'package:xrooster/pages/schedule/schedule.dart';
import 'package:xrooster/pages/settings/settings.dart';
import 'package:dynamic_color/dynamic_color.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await initializeDateFormatting('nl');

  // Both main and settings-page logic are preserved.
  // Start by showing the InAppWebView to perform authentication and
  // retrieve a token. Once we get the token, build the real app.
  var cache = await SharedPreferencesWithCache.create(
    cacheOptions: SharedPreferencesWithCacheOptions(),
  );
  var prefs = SharedPreferencesAsync();

  runApp(
    inAppWebViewApp(
      onToken: (token) async {
        var scaffoldKey = GlobalKey<ScaffoldMessengerState>();
        var api = MyxApi(
          cache: cache,
          prefs: prefs,
          tokenOverride: token,
          scaffoldKey: scaffoldKey,
        );

        // Load saved theme preference
        final sp = await SharedPreferences.getInstance();
        final theme = sp.getString('theme') ?? 'system';

        runApp(XApp(key: null, api: api, initialTheme: theme, scaffoldKey: scaffoldKey));
      },
    ),
  );
}

class XApp extends StatefulWidget {
  final MyxApi api;
  final String initialTheme;

  XApp({
    super.key,
    required this.api,
    required this.scaffoldKey,
    required this.initialTheme,
  });

  static String title = 'XRooster';

  final navigatorKey = GlobalKey<NavigatorState>();
  final rooster = GlobalKey<RoosterState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;

  @override
  State<XApp> createState() => XAppState();
}

class XAppState extends State<XApp> {
  // standaard de Schedule pagina
  int _currentIndex = 0;
  late String _themeMode;
  var prefs = SharedPreferencesAsync();
  late MyxApi _api;

  // cached future so FutureBuilder doesn't recreate a new future each build
  late Future<MyxApi?> _apiFuture;

  // ensure we only check selectedAttendee once to avoid setState loops
  bool _checkedSelectedAttendee = false;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialTheme;
    _api = widget.api;

    // initialize cached future
    _apiFuture = _buildApiFuture();

    // Als geen attendee geselecteerd is dan naar de Attendees pagina
    widget.api.prefs.getInt("selectedAttendee").then((attendeeId) {
      if (attendeeId == null) {
        setState(() => _currentIndex = 1);
      }
    });
  }

  Future<MyxApi?> _buildApiFuture() async {
    final token = await prefs.getString("token");
    if (token == null) return null;

    final cache = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(),
    );

    return MyxApi(
      cache: cache,
      prefs: prefs,
      tokenOverride: token,
      scaffoldKey: widget.scaffoldKey,
    );
  }

  ThemeMode get themeMode {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> _updateTheme(String newTheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', newTheme);
    setState(() => _themeMode = newTheme);
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return SchedulePage(rooster: widget.rooster, api: _api);
      case 1:
        return AttendeePage(
          api: _api,
          prefs: _api.prefs,
          onClassSelected: () {
            setState(() => _currentIndex = 0); // ga naar Schedule pagina
          },
        );
      case 2:
        return SettingsPage(onThemeChanged: _updateTheme);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MyxApi?>(
      future: _apiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator()); // api not ready
        }

        final api = snapshot.data;

        // login if no token = no api
        if (api == null) {
          return inAppWebViewApp(
            onToken: (t) async {
              await prefs.setString("token", t);
              // refresh cached future and trigger a single rebuild
              _apiFuture = _buildApiFuture();
              setState(() {});
            },
          );
        }

        _api = api;

        // Only check selectedAttendee once to avoid triggering repeated rebuilds
        if (!_checkedSelectedAttendee) {
          _checkedSelectedAttendee = true;
          _api.prefs.getInt("selectedAttendee").then((attendeeId) {
            if (!mounted) return;
            if (attendeeId == null && _currentIndex != 1) {
              setState(() => _currentIndex = 1);
            }
          });
        }

        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            final usingMaterialYou = _themeMode == 'material_you';

            final lightScheme = (usingMaterialYou && lightDynamic != null)
                ? lightDynamic
                : ColorScheme.fromSeed(seedColor: Colors.blue);

            final darkScheme = (usingMaterialYou && darkDynamic != null)
                ? darkDynamic
                : ColorScheme.fromSeed(
                    seedColor: Colors.blue,
                    brightness: Brightness.dark,
                  );

            return MaterialApp(
              title: XApp.title,
              navigatorKey: widget.navigatorKey,
              scaffoldMessengerKey: widget.scaffoldKey,
              theme: ThemeData(colorScheme: lightScheme, useMaterial3: true),
              darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
              themeMode: themeMode,
              home: Scaffold(
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_today),
                      label: 'Schedule',
                    ),
                    BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Attendees'),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                ),
                body: _getPage(_currentIndex),
              ),
            );
          },
        );
      },
    );
  }
}
