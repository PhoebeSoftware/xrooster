import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/models/base_attendee.dart';
import 'package:xrooster/pages/SearchTextField.dart';
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
  Map<int, String> _nicknames = {};
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _loadNicknames() async {
    final nicknames = _decodeNicknames(await widget.prefs.getString('nicknames'));

    setState(() => _nicknames = nicknames);
  }

  Map<int, String> _decodeNicknames(String? raw) {
    if (raw == null || raw.isEmpty) return {};

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(int.parse(key), value as String));
  }

  Future<void> _saveNicknames() async {
    final encoded = jsonEncode(
      _nicknames.map((key, value) => MapEntry(key.toString(), value)),
    );
    await widget.prefs.setString('nicknames', encoded);
  }

  Future<void> _loadPinned() async {
    final ids = await widget.prefs.getStringList('pinned_attendees') ?? [];
    setState(() {
      _pinned = ids.map(int.parse).toSet();
    });
  }

  Future<void> _savePinned() async {
    await widget.prefs.setStringList(
      'pinned_attendees',
      _pinned.map((e) => e.toString()).toList(),
    );
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
    final name = _name(item);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(name)),
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
    Future.wait([_loadPinned(), _loadNicknames()]).then((_) => _loadAttendees());
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

  void _refreshAttendees() {
    setState(() {
      _loading = true;
    });
    _loadAttendees();
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
        final nickname = _nicknames[item.id]?.toLowerCase() ?? '';
        return item.code.toLowerCase().contains(query) ||
            item.role.name.toLowerCase().contains(query) ||
            nickname.contains(query);
      }).toList();
    });
  }

  String _name(BaseAttendee item) =>
      _nicknames[item.id]?.trim().isEmpty ?? true ? item.code : _nicknames[item.id]!;

  Future<void> _editNickname(BaseAttendee item) async {
    final controller = TextEditingController(text: _nicknames[item.id] ?? '');
    final newNickname = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set nickname'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: 'Nickname', hintText: item.code),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text('Save'),
          ),
        ],
      ),
    );

    if (!mounted || newNickname == null) return;

    setState(() {
      newNickname.isEmpty
          ? _nicknames.remove(item.id)
          : _nicknames[item.id] = newNickname;
    });
    await _saveNicknames();
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
            child: RefreshIndicator(
              onRefresh: () async {
                _refreshAttendees();
              },
              child: _loading
                  ? ListView(
                      children: [
                        SizedBox(height: 200),
                        Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : displayList.isEmpty
                  ? ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'No attendees found',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      itemCount: displayList.length,
                      separatorBuilder: (context, index) => SizedBox(height: 4.0),
                      itemBuilder: (context, index) {
                        final item = displayList[index];
                        final pinned = _pinned.contains(item.id);
                        final name = _name(item);
                        final nickname = _nicknames[item.id];
                        final subtitleText = nickname == null || nickname.trim().isEmpty
                            ? item.role.name
                            : '${item.role.name} - ${item.code}';

                        return ListTile(
                          title: Text(name),
                          subtitle: Text(subtitleText),
                          onTap: () => _openQuickView(item),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editNickname(item),
                              ),
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
                                      content: Text('${item.role} $name selected'),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  widget.onClassSelected();
                                },
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          tileColor: pinned
                              ? theme.colorScheme.primary.withValues(alpha: .15)
                              : theme.hoverColor,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
