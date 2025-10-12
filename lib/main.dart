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

  var cache = await SharedPreferencesWithCache.create(
    cacheOptions: SharedPreferencesWithCacheOptions(),
  );
  var prefs = SharedPreferencesAsync();

  // Start by showing the InAppWebView to perform authentication and
  // retrieve a token. Once we get the token, build the real app.
  runApp(
    inAppWebViewApp(
      onToken: (token) async {
        var api = MyxApi(cache: cache, prefs: prefs, tokenOverride: token);

        // Load saved theme preference
        final sp = await SharedPreferences.getInstance();
        final theme = sp.getString('theme') ?? 'system';

        runApp(XApp(key: null, api: api, initialTheme: theme));
      },
    ),
  );
}

class XApp extends StatefulWidget {
  XApp({
    super.key,
    required this.api,
    required this.initialTheme,
  });

  static String title = 'XRooster';

  final MyxApi api;
  final String initialTheme;

  final rooster = GlobalKey<RoosterState>();
  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  State<XApp> createState() => XAppState();
}

class XAppState extends State<XApp> {
  int _currentIndex = 0;
  late String _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialTheme;

    // Als geen attendee geselecteerd is dan naar de Attendees pagina
    widget.api.prefs.getInt("selectedAttendee").then((attendeeId) {
      if (attendeeId == null) {
        setState(() => _currentIndex = 1);
      }
    });
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
        return SchedulePage(rooster: widget.rooster, api: widget.api);
      case 1:
        return AttendeePage(
          api: widget.api,
          prefs: widget.api.prefs,
          onClassSelected: () {
            setState(() => _currentIndex = 0);
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
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final bool useMaterialYou = _themeMode == 'material_you';

        final lightScheme = useMaterialYou && lightDynamic != null
            ? lightDynamic.harmonized()
            : ColorScheme.fromSeed(seedColor: Colors.blue);

        final darkScheme = useMaterialYou && darkDynamic != null
            ? darkDynamic.harmonized()
            : ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);

        return MaterialApp(
          title: XApp.title,
          theme: ThemeData(
            colorScheme: lightScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme,
            useMaterial3: true,
          ),
          themeMode: themeMode,
          home: Scaffold(
            key: widget.rootScaffoldMessengerKey,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today), label: 'Schedule'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.school), label: 'Attendees'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
            body: _getPage(_currentIndex),
          ),
        );
      },
    );
  }
}
