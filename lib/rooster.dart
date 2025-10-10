import 'package:flutter/material.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/models/appointment.dart';

class Rooster extends StatefulWidget {
  Rooster({super.key, required this.title, required this.api, required this.items});

  final String title;
  final MyxApi api;
  List<Appointment> items;

  @override
  State<Rooster> createState() => RoosterState();
}

class RoosterState extends State<Rooster> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];

          return ListTile(
            title: Text(item.name),
            subtitle: Text(item.summary),
            trailing: Text("${item.start.hour}:${item.start.minute.toString().padLeft(2, '0')}"),
          );
        },
      ),
    );
  }

  void changeDate(String date) async {
    var appointments = await widget.api.getAppointmentsForAttendee(date, 28497);

    setState(() {
      widget.items = appointments;
    });
  }
}
