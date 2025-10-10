import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/models/appointment.dart';
import 'package:xrooster/rooster.dart';
import 'package:xrooster/week_list.dart';
import 'package:xrooster/api/myx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // blend with background
      statusBarIconBrightness: Brightness.light, // white icons
    ),
  );

  var prefs = await SharedPreferences.getInstance();
  var api = MyxApi(prefs: prefs);
  var appointments = await api.getAppointmentsForAttendee("2025-10-09", 28497);

  runApp(XApp(key: null, api: api, items: appointments));
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
      home: Scaffold(
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: 'Rooster'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(XApp.title)),
        body: Column(
          children: [
            WeekList(rooster: widget.rooster),
            Rooster(key: widget.rooster, title: 'Rooster', api: widget.api, items: widget.items),
          ],
        ),
      ),
    );
  }
}
