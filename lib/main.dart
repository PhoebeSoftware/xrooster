import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/models/appointment.dart';
import 'package:xrooster/rooster.dart';
import 'package:xrooster/week_list.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/inapp_webview_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // blend with background
      statusBarIconBrightness: Brightness.light, // white icons
    ),
  );

  var prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // Start by showing the InAppWebView to perform authentication and
  // retrieve a token. Once we get the token, build the real app.
  runApp(inAppWebViewApp(onToken: (token) async {
    // token received; initialize API and load appointments, then replace
    // the running app with XApp.
    debugPrint('[main] received token: $token');

  var api = MyxApi(prefs: prefs, tokenOverride: token);
    var appointments = await api.getAppointmentsForAttendee(
      DateFormat("yyyy-MM-dd").format(DateTime.now()),
      28497,
    );

    runApp(XApp(key: null, api: api, items: appointments));
  }));
}

class XApp extends StatefulWidget {
  XApp({super.key, required this.api, required this.items});

  static String title = 'XRooster';

  final MyxApi api;
  final List<Appointment> items;
  final rooster = GlobalKey<RoosterState>();

  @override
  State<XApp> createState() => XAppState();
}

class XAppState extends State<XApp> {
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
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: 'Rooster'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        body: Column(
          children: [
            WeekList(rooster: widget.rooster),
            Rooster(
              key: widget.rooster,
              title: 'Rooster',
              api: widget.api,
              items: widget.items,
            ),
          ],
        ),
      ),
    );
  }
}
