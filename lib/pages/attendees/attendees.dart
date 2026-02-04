import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/models/base_attendee.dart';
import 'package:xrooster/pages/schedule/schedule.dart';
import 'package:xrooster/pages/schedule/timetable.dart';

class AttendeePage extends StatefulWidget {
  const AttendeePage({
    super.key,
    required this.api,
    required this.prefs,
    required this.onClassSelected,
    required this.useModernScheduleLayout,
  });

  final MyxApi api;
  final SharedPreferencesAsync prefs;
  final VoidCallback onClassSelected;
  final bool useModernScheduleLayout;

  @override
  State<AttendeePage> createState() => AttendeeState();
}

class AttendeeState extends State<AttendeePage> {
  List<BaseAttendee> _allItems = [];
  List<BaseAttendee> _filteredItems = [];
  Set<int> _pinned = {};
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _loadPinned() async {
    final ids = await widget.prefs.getStringList('pinned_attendees') ?? [];
    setState(() {
      _pinned = ids.map(int.parse).toSet();
    });
  }

  Future<void> _savePinned() async {
    await widget.prefs.setStringList('pinned_attendees', _pinned.map((e) => e.toString()).toList());
  }

  Future<void> _togglePin(BaseAttendee item) async {
    setState(() {
      _pinned.remove(item.id) || _pinned.add(item.id);
    });
  
    await _savePinned();
  }

  void _openQuickView(BaseAttendee item) {
    final key = GlobalKey<TimetableState>();
    final dateString = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(item.code),
          ),
          body: SchedulePage(
            timetableKey: key,
            api: widget.api,
            attendeeIdOverride: item.id,
            initialDate: dateString,
            useModernScheduleLayout: widget.useModernScheduleLayout,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPinned().then((_) {
      _loadAttendees();
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _loadAttendees() async {
    try {
      final results = await Future.wait([
        widget.api.getAllAttendees(AttendeeType.group),
        widget.api.getAllAttendees(AttendeeType.teacher),
      ]);

      if (!mounted) return;

      setState(() {
        _allItems = [...results[0], ...results[1]];
        _filteredItems = _allItems;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to get attendees: ${e.response?.statusMessage ?? e.error?.toString()}",
          ),
        ),
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
            item.role.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // turn the _filteredItems into a list with the pinned at the top
    final pinned = _filteredItems.where((a) => _pinned.contains(a.id)).toList();
    final unpinned = _filteredItems.where((a) => !_pinned.contains(a.id)).toList();
    final displayList = [...pinned, ...unpinned];

    return SafeArea(
      child: Column(
        children: [
          SearchTextField(controller: _searchController),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : displayList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'No attendees found',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: displayList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 4.0),
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      final pinned = _pinned.contains(item.id);

                      return ListTile(
                        title: Text(item.code),
                        subtitle: Text(item.role.name),
                        onTap: () => _openQuickView(item),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                              pinned ? Icons.push_pin : Icons.push_pin_outlined,
                              color: pinned ? theme.colorScheme.primary : null,
                              ),
                              onPressed: () => _togglePin(item),
                            ),
                            TextButton(
                              child: Text("Select"),
                              onPressed: () {
                              widget.prefs.setInt("selectedAttendee", item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                content: Text(
                                  '${item.role} ${item.code} selected',
                                ),
                                duration: Duration(seconds: 3),
                                ),
                              );
                              widget.onClassSelected();
                              },
                            ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        tileColor: pinned ? theme.colorScheme.primary.withValues(alpha: .15) : theme.hoverColor,
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
