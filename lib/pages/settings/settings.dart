import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _themeMode = 'system';
  String _language = 'system';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Color Theme'),
            subtitle: Text(_themeMode == 'system'
                ? 'System Default'
                : _themeMode == 'light'
                    ? 'Light'
                    : _themeMode == 'dark'
                        ? 'Dark'
                        : 'Material You'),
            trailing: DropdownButton<String>(
              value: _themeMode,
              items: const [
                DropdownMenuItem(
                  value: 'system',
                  child: Text('System Default'),
                ),
                DropdownMenuItem(
                  value: 'light',
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: 'dark',
                  child: Text('Dark'),
                ),
                DropdownMenuItem(
                  value: 'material_you',
                  child: Text('Material You'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _themeMode = value;
                  });
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(_language == 'system'
                ? 'System Default'
                : _language == 'en'
                    ? 'English'
                    : 'Dutch'),
            trailing: DropdownButton<String>(
              value: _language,
              items: const [
                DropdownMenuItem(
                  value: 'system',
                  child: Text('System Default'),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'nl',
                  child: Text('Nederlands'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _language = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}