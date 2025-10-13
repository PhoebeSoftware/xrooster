import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/models/appointment.dart';
import 'package:xrooster/models/location.dart';
import 'package:xrooster/models/teacher.dart';
import 'package:xrooster/models/group_attendee.dart';

class RoosterItem {
  final Appointment appointment;
  final Location? location;
  final Teacher? teacher;
  final GroupAttendee? group;

  RoosterItem({
    required this.appointment,
    required this.location,
    required this.teacher,
    required this.group,
  });
}

class Rooster extends StatefulWidget {
  const Rooster({super.key, required this.title, required this.api});

  final String title;
  final MyxApi api;

  @override
  State<Rooster> createState() => RoosterState();
}

class RoosterState extends State<Rooster> {
  Map<String, List<RoosterItem>> itemsCache = {};
  DateTime currentDate = DateTime.now();
  PageController pageController = PageController(initialPage: 1000);

  @override
  void initState() {
    super.initState();
    _loadCurrentDate();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      onPageChanged: (index) {
        final dayOffset = index - 1000;
        currentDate = DateTime.now().add(Duration(days: dayOffset));
        _loadCurrentDate();
      },
      itemBuilder: (context, index) {
        final dayOffset = index - 1000;
        final date = DateTime.now().add(Duration(days: dayOffset));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final items = itemsCache[dateKey] ?? [];

        return _buildScheduleList(items);
      },
    );
  }

  Widget _buildScheduleList(List<RoosterItem> items) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          tileColor: theme.hoverColor,
          onTap: () => _showAppointmentBottomSheet(context, item),
        );
      },
    );
  }

  void _loadCurrentDate() async {
    final dateKey = DateFormat('yyyy-MM-dd').format(currentDate);
    if (itemsCache.containsKey(dateKey)) return;

    var appointments = await widget.api.getAppointmentsForAttendee(dateKey);

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
          group: a.attendeeIds.group.isNotEmpty
              ? await widget.api.getGroupById(a.attendeeIds.group[0])
              : null,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      itemsCache[dateKey] = roosterItems;
    });
  }

  void changeDate(String date) async {
    currentDate = DateFormat('yyyy-MM-dd').parse(date);

    // Calculate the offset from today and update PageController
    final now = DateTime.now();
    final dayOffset = currentDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    final newPage = 1000 + dayOffset;

    pageController.jumpToPage(newPage);
    _loadCurrentDate();
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
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 10),
                Text(DateFormat("MMMM d, yyyy").format(item.appointment.start)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 10),
                Text(item.location?.code ?? 'No location found'),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.teacher != null
                        ? "${item.teacher!.code} (${item.teacher!.login})"
                        : 'No teacher found',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.group != null ? item.group!.code : 'No class found',
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
