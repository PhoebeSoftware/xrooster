import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/models/group_attendee.dart';

class AttendeePage extends StatefulWidget {
  const AttendeePage({super.key, required this.api, required this.prefs});

  final MyxApi api;
  final SharedPreferencesAsync prefs;
  
  @override
  State<AttendeePage> createState() => AttendeeState();
}

class AttendeeState extends State<AttendeePage> {
  List<GroupAttendee> _allItems = [];
  List<GroupAttendee> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.api.getAllGroupAttendees().then(
      (attendees) => setState(() {
        _allItems = attendees;
        _filteredItems = attendees;
      }),
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _allItems.where((item) {
        return item.code.toLowerCase().contains(query) ||
               item.role.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          SearchTextField(controller: _searchController),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4.0),
              itemBuilder: (context, index) {
                final item = _filteredItems[index];

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
  const SearchTextField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Search'),
      ),
    );
  }
}
