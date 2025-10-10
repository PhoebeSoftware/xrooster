import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  var api = MyxApi();
  var appointments = await api.getAppointmentsForAttendee("2025-10-09", "2025-10-09", 28497);

  runApp(XApp(key: null, items: appointments));
}

class XApp extends StatefulWidget {
  const XApp({super.key, required this.items});

  static String title = 'XRooster';
  final List<Appointment> items;

  @override
  State<XApp> createState() => XAppState();
}

class XAppState extends State<XApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: XApp.title,
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(XApp.title)),
        body: Column(
          children: [
            WeekList(),
            Rooster(title: 'Rooster', items: widget.items),
          ],
        ),
      ),
    );
  }
}
