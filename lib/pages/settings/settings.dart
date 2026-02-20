import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gif/gif.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatefulWidget {
  final void Function(String theme)? onThemeChanged;
  final void Function(Color color)? onSeedColorChanged;
  final void Function(bool useModernScheduleLayout)? onScheduleLayoutChanged;

  const SettingsPage({
    super.key,
    this.onThemeChanged,
    this.onSeedColorChanged,
    this.onScheduleLayoutChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _themeMode = 'system';
  String _language = 'system';
  bool _useModernScheduleLayout = true;
  bool _loading = true;
  Color _seedColor = Colors.blue;
  String _userName = '';
  String _timeLeft = '';
  String _expiryTime = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    var prefs = SharedPreferencesAsync();
    final theme = await prefs.getString('theme');
    final language = await prefs.getString('language');
    final scheduleLayout = await prefs.getBool('use_better_schedule');
    final seedColor = await prefs.getInt('theme_seed_color');
    final userName = await prefs.getString('userName');
    final tokenExp = await prefs.getInt('tokenExp');

    String timeLeft = '1h 45m';
    String expiryTime = '21:48';
    if (tokenExp != null) {
      final expTime = DateTime.fromMillisecondsSinceEpoch(tokenExp * 1000, isUtc: true).toLocal();
      final duration = expTime.difference(DateTime.now());

      timeLeft = '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
      expiryTime = DateFormat('HH:mm').format(expTime);
    }

    setState(() {
      _themeMode = theme ?? 'system';
      _language = language ?? 'system';
      _useModernScheduleLayout = scheduleLayout ?? true;
      _seedColor = Color(seedColor ?? Colors.blue.toARGB32());
      _userName = userName ?? 'John Doe';
      _timeLeft = timeLeft;
      _expiryTime = expiryTime;
      _loading = false;
    });
  }

  Future<void> _saveThemeMode(String value) async {
    var prefs = SharedPreferencesAsync();
    await prefs.setString('theme', value);
    widget.onThemeChanged?.call(value);
  }

  Future<void> _saveLanguage(String value) async {
    var prefs = SharedPreferencesAsync();
    await prefs.setString('language', value);
  }

  Future<void> _saveScheduleLayout(bool value) async {
    var prefs = SharedPreferencesAsync();
    await prefs.setBool('use_better_schedule', value);
    widget.onScheduleLayoutChanged?.call(value);
  }

  Future<void> _saveSeedColor(Color value) async {
    var prefs = SharedPreferencesAsync();
    await prefs.setInt('theme_seed_color', value.toARGB32());
    widget.onSeedColorChanged?.call(value);
  }

  void _showSeedColorPicker() {
    Color tempColor = _seedColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: tempColor,
                  onColorChanged: (color) {
                    setState(() => tempColor = color);
                  },
                  enableAlpha: false,
                  pickerAreaHeightPercent: 0.7,
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _seedColor = tempColor);
                _saveSeedColor(tempColor);
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
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
                ListTile(
                  title: Text('Account'),
                  subtitle: Text(
                    'Logged in as $_userName\nLogin token expires in $_timeLeft at $_expiryTime',
                  ),
                ),
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
                if (_themeMode == 'system' ||
                    _themeMode == 'light' ||
                    _themeMode == 'dark')
                  ListTile(
                    title: const Text('Accent color'),
                    trailing: Container(
                      width: 25,
                      decoration: BoxDecoration(
                        color: _seedColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    onTap: _showSeedColorPicker,
                  ),
                Divider(),
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
                Divider(),
                SwitchListTile(
                  title: const Text('Modern schedule'),
                  subtitle: const Text('Use the better schedule layout'),
                  value: _useModernScheduleLayout,
                  onChanged: (value) {
                    setState(() => _useModernScheduleLayout = value);
                    _saveScheduleLayout(value);
                  },
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
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('xrooster'),
                        // epic easter egg
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
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Version $version'),
                                  Text('Developed by Phoebe Software'),
                                  const SizedBox(height: 12),
                                  const Text('Contributors:'),
                                  const Text('   • AlexJonker'),
                                  const Text('   • kietelmuis'),
                                ],
                              ),
                            );
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
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
