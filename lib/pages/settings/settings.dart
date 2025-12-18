import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:gif/gif.dart';

class SettingsPage extends StatefulWidget {
  final void Function(String theme)? onThemeChanged;

  const SettingsPage({super.key, this.onThemeChanged});

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
    widget.onThemeChanged?.call(value);
  }

  Future<void> _saveLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Divider(),
                ListTile(
                  title: const Text('Color Theme'),
                  trailing: DropdownButton<String>(
                    value: _themeMode,
                    items: const [
                      DropdownMenuItem(
                        value: 'system',
                        child: Text('System Default'),
                      ),
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'dark', child: Text('Dark')),
                      DropdownMenuItem(
                        value: 'material_you',
                        child: Text('Material You'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _themeMode = value);
                        _saveThemeMode(value);
                      }
                    },
                  ),
                ),
                // Divider(),
                ListTile(
                  title: const Text('Language'),
                  trailing: DropdownButton<String>(
                    value: _language,
                    items: const [
                      DropdownMenuItem(
                        value: 'system',
                        child: Text('System Default'),
                      ),
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
                // Divider(),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.hasData
                    ? snapshot.data!.version
                    : '...';
                const longGitCommit = String.fromEnvironment(
                  'GIT_COMMIT',
                  defaultValue: 'unknown',
                );

                String shortGitCommit = 'unknown';
                if (longGitCommit != 'unknown') {
                  shortGitCommit = longGitCommit.substring(0, 7);
                }
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Full Commit ID'),
                        //epic easter egg
                        content: Builder(
                          builder: (context) {
                            int clickCount = 0;
                            return GestureDetector(
                              onTap: () {
                                clickCount++;
                                if (clickCount == 7) {
                                  clickCount = 0;
                                  showDialog(
                                    context: context,
                                    builder: (context) => _SecretDialog(),
                                  );
                                }
                              },
                              child: Text(longGitCommit),
                            );
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await Clipboard.setData(
                                ClipboardData(text: longGitCommit),
                              );
                            },
                            child: const Text('Copy'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: ListTile(
                    title: const Text('About'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Version $version'),
                        Text('Commit: $shortGitCommit'),
                        Text('Developed by Phoebe Software'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SecretDialog extends StatefulWidget {
  @override
  _SecretDialogState createState() => _SecretDialogState();
}

class _SecretDialogState extends State<_SecretDialog>
    with TickerProviderStateMixin {
  late GifController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: const Text('Easter Egg'),
      content: Gif(
        image: AssetImage('assets/gif.gif'), // epic
        controller: _controller,
        fps: 10,
        autostart: Autostart.loop,
        placeholder: (context) => const Text('Loading...'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
