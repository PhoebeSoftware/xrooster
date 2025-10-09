import 'package:flutter/material.dart';

class Rooster extends StatefulWidget {
  const Rooster({super.key, required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  State<Rooster> createState() => AppState();
}

class AppState extends State<Rooster> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.

    return Expanded(
      child: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.items[index]),
            subtitle: Text("Description of ${index + 1}"),
          );
        },
      ),
    );
  }
}
