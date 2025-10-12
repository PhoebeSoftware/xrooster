import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _themeMode = 'system';
  String _language = 'system';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = prefs.getString('theme') ?? 'system';
      _language = prefs.getString('language') ?? 'system';
      _loading = false;
    });
  }

  Future<void> _saveThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', value);
  }

  Future<void> _saveLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                DropdownMenuItem(value: 'system', child: Text('System Default')),
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
                DropdownMenuItem(value: 'material_you', child: Text('Material You')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _themeMode = value);
                  _saveThemeMode(value);
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
                DropdownMenuItem(value: 'system', child: Text('System Default')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'nl', child: Text('Nederlands')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _language = value);
                  _saveLanguage(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}