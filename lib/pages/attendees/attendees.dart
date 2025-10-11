import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/models/group_attendee.dart';

class AttendeePage extends StatefulWidget {
  AttendeePage({super.key, required this.api, required this.prefs});

  final MyxApi api;
  final SharedPreferencesAsync prefs;
  List<GroupAttendee> items = [];

  @override
  State<AttendeePage> createState() => AttendeeState();
}

class AttendeeState extends State<AttendeePage> {
  @override
  void initState() {
    super.initState();
    widget.api.getAllGroupAttendees().then(
      (attendees) => setState(() => widget.items = attendees),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          const SearchTextField(),
          Expanded(
            child: ListView.separated(
              itemCount: widget.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4.0),
              itemBuilder: (context, index) {
                final item = widget.items[index];

                return ListTile(
                  title: Text(item.code),
                  subtitle: Text(item.role),
                  trailing: TextButton(
                    child: Text("Select"),
                    onPressed: () {
                      widget.prefs.setInt("selectedAttendee", item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Attendee ${item.code} selected'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  tileColor: theme.hoverColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchTextField extends StatelessWidget {
  const SearchTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Search'),
      ),
    );
  }
}
