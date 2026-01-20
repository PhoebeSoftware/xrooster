import 'package:flutter/cupertino.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/pages/schedule/day_selector.dart';
import 'package:xrooster/pages/schedule/timetable.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({
    super.key,
    required this.timetableKey,
    required this.api,
    this.attendeeIdOverride,
    this.initialDate,
    required this.useModernScheduleLayout,
  });

  final GlobalKey<TimetableState> timetableKey;
  final MyxApi api;
  final int? attendeeIdOverride;
  final String? initialDate;
  final bool useModernScheduleLayout;

  @override
  State<SchedulePage> createState() => ScheduleState();
}

class ScheduleState extends State<SchedulePage> {
  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.timetableKey.currentState?.changeDate(widget.initialDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          DaySelector(timetableKey: widget.timetableKey),
          Expanded(
            child: TimetableView(
              key: widget.timetableKey,
              title: 'Schedule',
              api: widget.api,
              attendeeIdOverride: widget.attendeeIdOverride,
              useModernLayout: widget.useModernScheduleLayout,
            ),
          ),
        ],
      ),
    );
  }
}
