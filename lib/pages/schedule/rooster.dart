import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/models/appointment.dart';
import 'package:xrooster/models/location.dart';
import 'package:xrooster/models/teacher.dart';

class RoosterItem {
  final Appointment appointment;
  final Location? location;
  final Teacher? teacher;

  RoosterItem({required this.appointment, required this.location, required this.teacher});
}

class Rooster extends StatefulWidget {
  const Rooster({super.key, required this.title, required this.api});

  final String title;
  final MyxApi api;

  @override
  State<Rooster> createState() => RoosterState();
}

class RoosterState extends State<Rooster> {
  List<RoosterItem> items = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4.0),
      itemBuilder: (context, index) {
        final item = items[index];

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
          onTap: () => _showAppointmentBottomSheet(context, item),
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
          teacher: a.attendeeIds.teacher.isNotEmpty
              ? await widget.api.getTeacherById(a.attendeeIds.teacher[0])
              : null,
        ),
      ),
    );

    // error fix
    if (!mounted) return;

    setState(() => items = roosterItems);
  }

  void _showAppointmentBottomSheet(BuildContext context, RoosterItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              item.appointment.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              item.appointment.summary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 10),
                Text(
                  "${DateFormat("HH:mm").format(item.appointment.start)} - ${DateFormat("HH:mm").format(item.appointment.end)}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 10),
                Text(
                  item.location!.code,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${item.teacher!.code} (${item.teacher!.login})",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}