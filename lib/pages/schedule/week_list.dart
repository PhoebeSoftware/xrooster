import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xrooster/pages/schedule/rooster.dart';

class WeekList extends StatefulWidget {
  const WeekList({super.key, required this.rooster});

  final GlobalKey<RoosterState> rooster;

  @override
  State<WeekList> createState() => WeekListState();
}

class WeekListState extends State<WeekList> {
  late String selectedDayString;

  @override
  void initState() {
    super.initState();
    selectedDayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final currentDay = DateFormat('yyyy-MM-dd').format(now);

    final screenWidth = MediaQuery.of(context).size.width;
    const itemCount = 7;
    final buttonWidth = screenWidth / itemCount;

    return Material(
      color: theme.colorScheme.surface,
      child: SizedBox(
        height: 70,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: itemCount,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final monday = now.subtract(
              Duration(days: now.weekday - DateTime.monday),
            );
            final day = monday.add(Duration(days: index));
            final dayString = DateFormat('yyyy-MM-dd').format(day);
            final isToday = dayString == currentDay;
            final isSelected = dayString == selectedDayString;

            return SizedBox(
              width: buttonWidth,
              child: Align(
                alignment: Alignment.center,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isToday
                        ? theme.colorScheme.onPrimary
                        : theme.cardColor,
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 3,
                      style: isSelected ? BorderStyle.solid : BorderStyle.none,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    minimumSize: const Size(70, 70),
                    padding: EdgeInsets.zero,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.E('nl').format(day),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 21.0,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : isToday
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMM', 'nl').format(day),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14.0,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : isToday
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    setState(() => selectedDayString = dayString);
                    widget.rooster.currentState?.changeDate(dayString);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
