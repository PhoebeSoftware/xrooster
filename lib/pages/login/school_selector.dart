import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

class SchoolSelectorPage extends StatefulWidget {
  final ValueChanged<String>? onSchoolSelected;
  const SchoolSelectorPage({super.key, this.onSchoolSelected});

  @override
  State<SchoolSelectorPage> createState() => _SchoolSelectorPageState();
}

class _SchoolSelectorPageState extends State<SchoolSelectorPage> {
  List<Map<String, dynamic>> _allSchools = [];
  List<Map<String, dynamic>> _filteredSchools = [];
  String? _selectedSchool;
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSchools();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    final jsonStr = await rootBundle.loadString('assets/schools.json');
    final List<dynamic> data = jsonDecode(jsonStr);

    if (!mounted) return;

    setState(() {
      _allSchools = data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      _filteredSchools = _allSchools;
      _loading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredSchools = _allSchools.where((school) {
        final name = (school['name'] as String? ?? '').toLowerCase();
        final url = (school['url'] as String? ?? '').toLowerCase();

        return name.contains(query) || url.contains(query);
      }).toList();
    });
  }

  void _selectSchool(String url) {
    setState(() => _selectedSchool = url);
    widget.onSchoolSelected?.call(url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Select School')),
      body: SafeArea(
        child: Column(
          children: [
            SearchTextField(controller: _searchController),
            Expanded(
              child: _loading
                  ? ListView(
                      children: [
                        SizedBox(height: 200),
                        Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : _filteredSchools.isEmpty
                  ? ListView(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'No schools found',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      itemCount: _filteredSchools.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 4.0),
                      itemBuilder: (context, index) {
                        final item = _filteredSchools[index];
                        final selected = item['url'] == _selectedSchool;
                        final name = item['name'] as String? ?? '';
                        final subtitleText = item['url'] as String? ?? '';

                        return ListTile(
                          title: Text(name),
                          subtitle: Text(subtitleText),
                          onTap: () => _selectSchool(item['url'] as String),
                          trailing: Row(mainAxisSize: MainAxisSize.min),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          tileColor: selected
                              ? theme.colorScheme.primary.withValues(alpha: .15)
                              : theme.hoverColor,
                        );
                      },
                    ),
            ),
          ],
        ),
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
