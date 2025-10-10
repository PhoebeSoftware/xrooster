import 'package:flutter/material.dart';
import 'package:xrooster/rooster.dart';
import 'package:intl/intl.dart';

class WeekList extends StatefulWidget {
  const WeekList({super.key, required this.rooster});

  final GlobalKey<RoosterState> rooster;

  @override
  State<WeekList> createState() => WeekListState();
}

class WeekListState extends State<WeekList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8.0);
        },
        itemBuilder: (context, index) {
          final now = DateTime.now();
          final monday = now.subtract(Duration(days: now.weekday - DateTime.monday));
          final day = monday.add(Duration(days: index));

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[300],
              ),
              alignment: Alignment.center,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  minimumSize: Size(60, 60),
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
                onPressed: () {
                  widget.rooster.currentState?.changeDate(DateFormat('yyyy-MM-dd').format(day));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
