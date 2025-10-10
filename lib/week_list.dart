import 'package:flutter/material.dart';

class WeekList extends StatefulWidget {
  const WeekList({super.key});

  @override
  State<WeekList> createState() => WeekListState();
}

class WeekListState extends State<WeekList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
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
              child: Text(
                '${index + 1}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
          );
        },
      ),
    );
  }
}
