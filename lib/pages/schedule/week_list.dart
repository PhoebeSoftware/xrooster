import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xrooster/pages/schedule/timetable.dart';

class WeekList extends StatefulWidget {
  const WeekList({super.key, required this.timetableKey});

  final GlobalKey<TimetableState> timetableKey;

  @override
  State<WeekList> createState() => WeekListState();
}

class WeekListState extends State<WeekList> {
  late String selectedDayString;
  ValueNotifier<int>? _pageIndexNotifier;
  VoidCallback? _notifierListener;
  late PageController _weekPageController;

  @override
  void initState() {
    super.initState();
    selectedDayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _weekPageController = PageController(initialPage: 1000);
    WidgetsBinding.instance.addPostFrameCallback((_) => _attachController());
  }

  @override
  void dispose() {
    _weekPageController.dispose();
    if (_pageIndexNotifier != null && _notifierListener != null) {
      _pageIndexNotifier!.removeListener(_notifierListener!);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WeekList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timetableKey != widget.timetableKey) {
      _attachController();
    }
  }

  void _attachController() {
    final rs = widget.timetableKey.currentState;
    if (rs == null) return;

    final notifier = rs.pageIndexNotifier;
    if (_pageIndexNotifier != null && _notifierListener != null) {
      _pageIndexNotifier!.removeListener(_notifierListener!);
    }
    _pageIndexNotifier = notifier;
    _notifierListener = () => _onPageIndexChanged(_pageIndexNotifier!.value);
    _pageIndexNotifier!.addListener(_notifierListener!);
    _notifierListener!();
  }

  void _onPageIndexChanged(int pageIndex) {
    final dayOffset = pageIndex - 1000;
    final now = DateTime.now();
    final date = now.add(Duration(days: dayOffset));
    final dayString = DateFormat('yyyy-MM-dd').format(date);
    if (dayString == selectedDayString) return;
    setState(() => selectedDayString = dayString);

    final selectedMonday = date.subtract(
      Duration(days: date.weekday - DateTime.monday),
    );
    final baseMonday = now.subtract(
      Duration(days: now.weekday - DateTime.monday),
    );
    final weekOffset = selectedMonday.difference(baseMonday).inDays ~/ 7;
    final weekIndex = 1000 + weekOffset;
    if (!_weekPageController.hasClients) return;
    final currentWeekPage =
        (_weekPageController.page ?? _weekPageController.initialPage.toDouble())
            .round();
    if (currentWeekPage == weekIndex) return;
    _weekPageController.animateToPage(
      weekIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final currentDay = DateFormat('yyyy-MM-dd').format(now);

    const itemCount = 7;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth / itemCount;

    return Material(
      color: theme.colorScheme.surface,
      child: SizedBox(
        height: 70,
        child: PageView.builder(
          controller: _weekPageController,
          itemCount: null, // Infinite scrolling
          itemBuilder: (context, weekIndex) {
            final baseMonday = now.subtract(
              Duration(days: now.weekday - DateTime.monday),
            );
            final weekOffset = weekIndex - 1000;
            final weekMonday = baseMonday.add(Duration(days: weekOffset * 7));

            return SizedBox(
              width: screenWidth,
              child: Row(
                children: List.generate(itemCount, (dayIndex) {
                  final day = weekMonday.add(Duration(days: dayIndex));
                  final dayString = DateFormat('yyyy-MM-dd').format(day);
                  final isToday = dayString == currentDay;
                  final isSelected = dayString == selectedDayString;

                  return SizedBox(
                    width: buttonWidth,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isToday
                            ? theme.colorScheme.onPrimary
                            : theme.cardColor,
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 3,
                          style: isSelected
                              ? BorderStyle.solid
                              : BorderStyle.none,
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
                            DateFormat.E('en_US').format(day),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 21.0,
                              color: isSelected || isToday
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d MMM', 'en_US').format(day),
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14.0,
                              color: isSelected || isToday
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        setState(() => selectedDayString = dayString);
                        widget.timetableKey.currentState?.changeDate(dayString);
                      },
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
