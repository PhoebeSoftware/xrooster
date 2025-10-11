import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/pages/classes/attendees.dart';
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

  var cache = await SharedPreferencesWithCache.create(
    cacheOptions: SharedPreferencesWithCacheOptions(),
  );
  var prefs = SharedPreferencesAsync();

  // Start by showing the InAppWebView to perform authentication and
  // retrieve a token. Once we get the token, build the real app.
  runApp(
    inAppWebViewApp(
      onToken: (token) async {
        // token received; initialize API and load appointments, then replace
        // the running app with XApp.
        // debugPrint('[main] received token: $token');

        var api = MyxApi(cache: cache, prefs: prefs, tokenOverride: token);
        runApp(XApp(key: null, api: api));
      },
    ),
  );
}

class XApp extends StatefulWidget {
  XApp({super.key, required this.api});

  static String title = 'XRooster';

  final MyxApi api;
  final rooster = GlobalKey<RoosterState>();
  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  State<XApp> createState() => XAppState();
}

class XAppState extends State<XApp> {
  int _currentIndex = 1;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return SchedulePage(rooster: widget.rooster, api: widget.api);
      case 1:
        return AttendeePage(api: widget.api, prefs: widget.api.prefs);
      case 2:
        return const SafeArea(child: Center(child: Text("Todo")));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();

    widget.rooster.currentState?.changeDate(
      DateFormat("yyyy-MM-dd").format(DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: XApp.title,
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
        key: widget.rootScaffoldMessengerKey,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
            BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Attendees'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        body: _getPage(_currentIndex),
      ),
    );
  }
}
