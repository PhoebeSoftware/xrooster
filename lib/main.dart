import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/pages/attendees/attendees.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/pages/login/login.dart';
import 'package:xrooster/pages/schedule/rooster.dart';
import 'package:xrooster/pages/schedule/schedule.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // blend with background
      statusBarIconBrightness: Brightness.light, // white icons
    ),
  );

  await initializeDateFormatting('nl');

  WidgetsFlutterBinding.ensureInitialized();
  runApp(XApp());
}

class XApp extends StatefulWidget {
  XApp({super.key});

  static String title = 'XRooster';

  final navigatorKey = GlobalKey<NavigatorState>();
  final rooster = GlobalKey<RoosterState>();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  State<XApp> createState() => XAppState();
}

class XAppState extends State<XApp> {
  // standaard de Schedule pagina
  int _currentIndex = 0;
  var prefs = SharedPreferencesAsync();
  late MyxApi _api;

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
        return const SafeArea(child: Center(child: Text("Todo")));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MyxApi?>(
      future: () async {
        final token = await prefs.getString("token");
        if (token == null) return null;

        final cache = await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(),
        );

        return MyxApi(cache: cache, prefs: prefs, tokenOverride: token);
      }(),
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
              setState(() {}); // triggers rebuild, future reruns with new token
            },
          );
        }

        _api = api;

        _api.prefs.getInt("selectedAttendee").then((attendeeId) {
          if (attendeeId == null) setState(() => _currentIndex = 1);
        });

        return MaterialApp(
          title: XApp.title,
          navigatorKey: widget.navigatorKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: Scaffold(
            key: widget.scaffoldKey,
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
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
              ],
            ),
            body: _getPage(_currentIndex),
          ),
        );
      },
    );
  }
}
