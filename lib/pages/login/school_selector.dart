import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SchoolSelectorPage extends StatefulWidget {
  final ValueChanged<String>? onSchoolSelected;
  const SchoolSelectorPage({super.key, this.onSchoolSelected});

  @override
  State<SchoolSelectorPage> createState() => _SchoolSelectorPageState();
}

class _SchoolSelectorPageState extends State<SchoolSelectorPage> {
  String? _selectedSchool;

  Future<List<Map<String, dynamic>>> _loadSchools() async {
    final jsonStr = await rootBundle.loadString('assets/schools.json');
    final List<dynamic> data = jsonDecode(jsonStr);

    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select School')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadSchools(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final schools = snapshot.data!;
            if (schools.isEmpty) {
              return const Center(child: Text('No schools available'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('School', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSchool,
                  items: [
                    for (final s in schools)
                      DropdownMenuItem(value: s['url'] as String, child: Text(s['name'] as String)),
                  ],
                  onChanged: (v) => setState(() => _selectedSchool = v),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectedSchool == null
                      ? null
                      : () => widget.onSchoolSelected?.call(_selectedSchool!),
                  child: const Text('Continue'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
