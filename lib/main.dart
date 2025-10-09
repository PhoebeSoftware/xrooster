import 'package:flutter/material.dart';
import 'package:xrooster/rooster.dart';
import 'package:xrooster/week_list.dart';

void main() {
  runApp(const XApp());
}

class XApp extends StatefulWidget {
  const XApp({super.key});

  static String title = 'XRooster';
  static List<String> items = [];

  @override
  State<XApp> createState() => XAppState();
}

class XAppState extends State<XApp> {
  void _createAppointment() {
    setState(() {
      XApp.items.add("afpraak ${XApp.items.length + 1}");
    });
  }

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
        floatingActionButton: FloatingActionButton(
          onPressed: _createAppointment,
          tooltip: 'Afspraak maken',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
