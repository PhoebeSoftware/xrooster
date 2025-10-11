import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/models/appointment.dart';
import 'package:xrooster/models/location.dart';

class RoosterItem {
  final Appointment appointment;
  final Location? location;

  RoosterItem({required this.appointment, required this.location});
}

class Rooster extends StatefulWidget {
  Rooster({super.key, required this.title, required this.api});

  final String title;
  final MyxApi api;
  List<RoosterItem> items = [];

  @override
  State<Rooster> createState() => RoosterState();
}

class RoosterState extends State<Rooster> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      itemCount: widget.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4.0),
      itemBuilder: (context, index) {
        final item = widget.items[index];

        return ListTile(
          title: Text(
            "${item.appointment.name}${item.location?.code != null ? ' - ${item.location!.code}' : ''}",
          ),
          subtitle: Text(item.appointment.summary),
          trailing: Text(
            "${DateFormat("HH:mm").format(item.appointment.start)}\n${DateFormat("HH:mm").format(item.appointment.end)}",
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          tileColor: theme.hoverColor,
        );
      },
    );
  }

  void changeDate(String date) async {
    var appointments = await widget.api.getAppointmentsForAttendee(date);

    var roosterItems = await Future.wait(
      appointments.map(
        (a) async => RoosterItem(
          appointment: a,
          location: a.attendeeIds.classroom.isNotEmpty
              ? await widget.api.getLocationById(a.attendeeIds.classroom[0])
              : null,
        ),
      ),
    );

    // error fix
    if (!mounted) return;

    setState(() {
      widget.items = roosterItems;
    });
  }
}
