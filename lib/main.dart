import 'package:flutter/material.dart';
import 'package:xrooster/rooster.dart';
import 'package:xrooster/week_list.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/models/appointment.dart';

Future<void> main() async {
  runApp(const XApp());

  var api = MyxApi();
  var appointments = await api.getAppointmentsForAttendee(
    "2025-10-09",
    "2025-10-09",
    28497,
  );

  appointments.forEach((appointment) {
    debugPrint(appointment.id.toString());
    debugPrint(appointment.name);
    debugPrint(appointment.summary);
  });
}

class XApp extends StatefulWidget {
  const XApp({super.key});

  static String title = 'XRooster';
  static List<String> items = [];

  @override
  State<XApp> createState() => XAppState();
}

class XAppState extends State<XApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: XApp.title,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(XApp.title),
        ),
        body: Column(
          children: [
            WeekList(),
            Rooster(title: 'Rooster', items: XApp.items),
          ],
        ),
      ),
    );
  }
}
