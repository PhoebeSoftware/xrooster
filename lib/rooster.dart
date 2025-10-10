import 'package:flutter/material.dart';
import 'package:xrooster/models/appointment.dart';

class Rooster extends StatefulWidget {
  const Rooster({super.key, required this.title, required this.items});

  final String title;
  final List<Appointment> items;

  @override
  State<Rooster> createState() => AppState();
}

class AppState extends State<Rooster> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.items[index].name),
            subtitle: Text(widget.items[index].summary),
          );
        },
      ),
    );
  }
}
