import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/models/appointment.dart';
import 'package:xrooster/models/base_attendee.dart';
import 'package:xrooster/models/location.dart';
import 'package:xrooster/models/teacher_attendee.dart';
import 'package:xrooster/models/group_attendee.dart';
import 'package:xrooster/pages/schedule/schedule.dart';

class RoosterItem {
  final Appointment appointment;
  final Location? location;
  final TeacherAttendee? teacher;
  final GroupAttendee? group;

  RoosterItem({
    required this.appointment,
    required this.location,
    required this.teacher,
    required this.group,
  });
}

class Rooster extends StatefulWidget {
  const Rooster({
    super.key,
    required this.title,
    required this.api,
    this.attendeeIdOverride,
  });

  final String title;
  final MyxApi api;
  final int? attendeeIdOverride;

  @override
  State<Rooster> createState() => RoosterState();
}

class RoosterState extends State<Rooster> {
  Map<String, List<RoosterItem>> itemsCache = {};

  final Set<String> loadingDates = {};

  DateTime currentDate = DateTime.now();
  PageController pageController = PageController(initialPage: 1000);

  final ValueNotifier<int> pageIndexNotifier = ValueNotifier<int>(1000);

  DateFormat apiFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _loadCurrentDate();
  }

  @override
  void dispose() {
    pageController.dispose();
    pageIndexNotifier.dispose();
    super.dispose();
  }

  // 1000 = date center point for infinite scrolling
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      onPageChanged: (index) {
        pageIndexNotifier.value = index;
        final dayOffset = index - 1000;
        currentDate = DateTime.now().add(Duration(days: dayOffset));
        _loadCurrentDate();
      },
      itemBuilder: (context, index) {
        final dayOffset = index - 1000;
        final date = DateTime.now().add(Duration(days: dayOffset));
        final dateKey = apiFormat.format(date);
        final items = itemsCache[dateKey] ?? [];

        return _buildScheduleList(items, dateKey);
      },
    );
  }

  Widget _buildScheduleList(List<RoosterItem> items, String dateKey) {
    final theme = Theme.of(context);

    if (items.isEmpty && loadingDates.contains(dateKey)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [CircularProgressIndicator(), SizedBox(height: 12)],
          ),
        ),
      );
    }

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

  void _loadCurrentDate() async {
    final dateKey = apiFormat.format(currentDate);
    if (itemsCache.containsKey(dateKey)) return;

    if (!loadingDates.contains(dateKey)) {
      setState(() {
        loadingDates.add(dateKey);
      });
    }

    final firstDayOfWeek = currentDate.subtract(Duration(days: currentDate.weekday - 1));
    final lastDayOfWeek = currentDate.add(Duration(days: 7 - currentDate.weekday));

    Map<String, List<Appointment>> appointments;
    try {
      appointments = await widget.api.getAppointmentsForAttendee(
        apiFormat.format(firstDayOfWeek),
        apiFormat.format(lastDayOfWeek),
        attendeeId: widget.attendeeIdOverride,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        loadingDates.remove(dateKey);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ApiError: ${e.response?.statusMessage}')));
      return;
    }

    Future<T?> safeGet<T>(Future<T> future) async {
      try {
        return await future;
      } on DioException catch (e) {
        if (!mounted) return null;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ApiError: ${e.response?.statusMessage}')));
        return null;
      }
    }

    final List<Future<MapEntry<String, List<RoosterItem>>>> futures = [];
    for (
      var d = firstDayOfWeek;
      !d.isAfter(lastDayOfWeek);
      d = d.add(const Duration(days: 1))
    ) {
      final dateKey = apiFormat.format(d);
      if (appointments.containsKey(dateKey)) {
        futures.add(
          Future(() async {
            final items = await Future.wait(
              appointments[dateKey]!.map(
                (a) async => RoosterItem(
                  appointment: a,
                  location: a.attendeeIds.classroom.isNotEmpty
                      ? await safeGet(
                          widget.api.getLocationById(a.attendeeIds.classroom[0]),
                        )
                      : null,
                  teacher: a.attendeeIds.teacher.isNotEmpty
                      ? (await widget.api.getAllAttendees(
                              AttendeeType.teacher,
                            )).where((t) => t.id == a.attendeeIds.teacher[0]).first
                            as TeacherAttendee?
                      : null,
                  group: a.attendeeIds.group.isNotEmpty
                      ? (await widget.api.getAllAttendees(
                              AttendeeType.group,
                            )).where((t) => t.id == a.attendeeIds.group[0]).first
                            as GroupAttendee?
                      : null,
                ),
              ),
            );

            return MapEntry(dateKey, items);
          }),
        );
      } else {
        // return empty list for dates with no appointments so you dont get an infinite loading spinner
        futures.add(Future.value(MapEntry(dateKey, <RoosterItem>[])));
      }
    }

    final weekRoosterMap = Map.fromEntries(await Future.wait(futures));

    if (!mounted) return;

    setState(() {
      weekRoosterMap.forEach((date, items) => itemsCache[date] = items);
      for (final d in weekRoosterMap.keys) {
        loadingDates.remove(d);
      }
    });
  }

  void changeDate(String date) async {
    currentDate = apiFormat.parse(date);

    // Calculate the offset from today and update PageController
    final now = DateTime.now();
    final dayOffset = currentDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    final newPage = 1000 + dayOffset;
    pageController.jumpToPage(newPage);
    pageIndexNotifier.value = newPage;
    // debug: changeDate called
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
            Text(item.appointment.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(item.appointment.summary, style: Theme.of(context).textTheme.bodyMedium),
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
                  child: item.teacher != null
                      ? TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () async {
                            final key = GlobalKey<RoosterState>();
                            final dateString = apiFormat.format(item.appointment.start);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(title: Text(item.teacher!.code)),
                                  body: SchedulePage(
                                    rooster: key,
                                    api: widget.api,
                                    attendeeIdOverride: item.teacher!.id,
                                    initialDate: dateString,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text('${item.teacher!.code} (${item.teacher!.login})'),
                        )
                      : const Text('No teacher found'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: item.group != null
                      ? TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () {
                            final key = GlobalKey<RoosterState>();
                            final dateString = apiFormat.format(item.appointment.start);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(title: Text(item.group!.code)),
                                  body: SchedulePage(
                                    rooster: key,
                                    api: widget.api,
                                    attendeeIdOverride: item.group!.id,
                                    initialDate: dateString,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(item.group!.code),
                        )
                      : const Text('No class found'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
