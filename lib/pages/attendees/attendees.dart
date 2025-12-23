import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/models/group_attendee.dart';

class AttendeePage extends StatefulWidget {
  const AttendeePage({
    super.key,
    required this.api,
    required this.prefs,
    required this.onClassSelected,
  });

  final MyxApi api;
  final SharedPreferencesAsync prefs;
  final VoidCallback onClassSelected;

  @override
  State<AttendeePage> createState() => AttendeeState();
}

class AttendeeState extends State<AttendeePage> {
  List<GroupAttendee> _allItems = [];
  List<GroupAttendee> _filteredItems = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAttendees();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadAttendees() async {
    try {
      final results = await Future.wait([
        widget.api.getAllAttendees("group"),
        widget.api.getAllAttendees("teacher"),
      ]);

      if (!mounted) return;

      setState(() {
        _allItems = [...results[0], ...results[1]];
        _filteredItems = _allItems;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      debugPrint("ApiError: ${e.response?.statusMessage}");

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ApiError: ${e.response?.statusMessage}")),
      );
    }
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text('No attendees found', style: theme.textTheme.bodyMedium),
                        ),
                      )
                    : ListView.separated(
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
                                    content: Text('${item.role} ${item.code} selected'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                widget.onClassSelected();
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
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
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Search',
        ),
      ),
    );
  }
}
