import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final theme = Theme.of(context);

    return Expanded(
      child: ListView.separated(
        itemCount: widget.items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 4.0),
        itemBuilder: (context, index) {
          final item = widget.items[index];

          return ListTile(
            title: Text(item.name),
            subtitle: Text(item.summary),
            trailing: Text(DateFormat("HH:mm").format(item.start)),
            contentPadding: EdgeInsetsGeometry.symmetric(horizontal: 15.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            tileColor: theme.hoverColor,
          );
        },
      ),
    );
  }

  void changeDate(String date, int attendeeId) async {
    var appointments = await widget.api.getAppointmentsForAttendee(date, attendeeId);

    setState(() {
      widget.items = appointments;
    });
  }
}
