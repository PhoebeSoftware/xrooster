import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XRooster',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const Rooster(title: 'Rooster'),
    );
  }
}

// This widget is the home page of your application.
class Rooster extends StatefulWidget {
  const Rooster({super.key, required this.title});

  final String title;

  @override
  State<Rooster> createState() => RoosterState();
}

void _afspraak() {
  print("someone cooked here");
}

class RoosterState extends State<Rooster> {
  static const List<String> items = ["hoi1", "hoi2", "hoi3"];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        // Let the ListView know how many items it needs to build.
        itemCount: items.length,
        // Provide a builder function. This is where the magic happens.
        // Convert each item into a widget based on the type of item it is.
        itemBuilder: (context, index) {
          final item = items[index];

          return ListTile(title: Text(item), subtitle: Text("Description"));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _afspraak,
        tooltip: 'Afspraak maken',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
