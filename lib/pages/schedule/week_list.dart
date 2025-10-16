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
  PageController? _pageController;
  VoidCallback? _pageListener;
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
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WeekList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rooster != widget.rooster) {
      _attachController();
    }
  }

  void _attachController() {
    final controller = widget.rooster.currentState?.pageController;

    if (identical(controller, _pageController)) return;

    if (_pageController != null && _pageListener != null) {
      _pageController!.removeListener(_pageListener!);
    }

    _pageController = controller;
    _pageListener = null;

    if (_pageController != null) {
      _pageListener = () {
        final pageValue = _pageController!.hasClients
            ? (_pageController!.page ?? _pageController!.initialPage.toDouble())
            : _pageController!.initialPage.toDouble();

        final pageIndex = pageValue.round();
        final dayOffset = pageIndex - 1000;
        final date = DateTime.now().add(Duration(days: dayOffset));
        final dayString = DateFormat('yyyy-MM-dd').format(date);

        if (dayString != selectedDayString) {
          setState(() {
            selectedDayString = dayString;
          });
        }
      };

      _pageController!.addListener(_pageListener!);
    }
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
                            DateFormat.E('nl').format(day),
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
                            DateFormat('d MMM', 'nl').format(day),
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
                        widget.rooster.currentState?.changeDate(dayString);
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
