import 'package:flutter/cupertino.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/pages/schedule/rooster.dart';
import 'package:xrooster/pages/schedule/week_list.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({
    super.key,
    required this.rooster,
    required this.api,
    this.attendeeIdOverride,
    this.initialDate,
  });

  final GlobalKey<RoosterState> rooster;
  final MyxApi api;
  final int? attendeeIdOverride;
  final String? initialDate;

  @override
  State<SchedulePage> createState() => ScheduleState();
}

class ScheduleState extends State<SchedulePage> {
  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.rooster.currentState?.changeDate(widget.initialDate!);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          WeekList(rooster: widget.rooster),
          Expanded(
            child: Rooster(
              key: widget.rooster,
              title: 'Rooster',
              api: widget.api,
              attendeeIdOverride: widget.attendeeIdOverride,
            ),
          ),
        ],
      ),
    );
  }
}
