import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/pages/attendees/attendees.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/pages/login/login.dart';
import 'package:xrooster/pages/login/offline.dart';
import 'package:xrooster/pages/login/school_selector.dart';
import 'package:xrooster/pages/schedule/rooster.dart';
import 'package:xrooster/pages/schedule/schedule.dart';
import 'package:xrooster/pages/settings/settings.dart';
import 'package:dynamic_color/dynamic_color.dart';

String apiBaseUrl = '';
String selectedSchoolUrl = '';

// Global connectivity state that can be shared across the app
final ValueNotifier<bool?> isOnlineNotifier = ValueNotifier<bool?>(null);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await initializeDateFormatting('nl');

  var prefs = SharedPreferencesAsync();
  final selectedSchool = await prefs.getString('selectedSchool');
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  // handle connection changes
  isOnlineNotifier.addListener(() {
    debugPrint('Connection status changed');
    if (isOnlineNotifier.value == true) {
      scaffoldKey.currentState?.clearMaterialBanners();
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        if (isOnlineNotifier.value == false) {
          scaffoldKey.currentState?.showMaterialBanner(
            const MaterialBanner(
              content: Text('No internet connection'),
              leading: Icon(Icons.signal_wifi_connected_no_internet_4),
              backgroundColor: Colors.red,
              actions: <Widget>[SizedBox()],
            ),
          );
        }
      });
    }
  });

  // initialize state
  isOnlineNotifier.value = _isDeviceOnline(
    await Connectivity().checkConnectivity(),
  );

  // listen to connection changes
  Connectivity().onConnectivityChanged.listen((
    List<ConnectivityResult> results,
  ) {
    final newOnlineStatus = _isDeviceOnline(results);
    if (isOnlineNotifier.value != newOnlineStatus) {
      isOnlineNotifier.value = newOnlineStatus;
    }
  });

  var cache = await SharedPreferencesWithCache.create(
    cacheOptions: SharedPreferencesWithCacheOptions(),
  );

  String normalizeApiBase(String url) {
    var s = url.trim();
    if (s.endsWith('/api/')) return s;
    s = s.replaceAll(RegExp(r'/+$'), '');
    return '$s/api/';
  }

  // creates the main app with an token for the api
  void startAppFlow(String token) async {
    if ((await prefs.getString('selectedSchool') ?? '').isEmpty &&
        selectedSchoolUrl.isNotEmpty) {
      await prefs.setString('selectedSchool', selectedSchoolUrl);
    }

    // Persist the token so the app's cached future builder can pick it up
    // immediately. Without this the `XApp` instance created below will
    // still try to read the token from prefs and may remain in the
    // login flow requiring a second token entry on some platforms.
    await prefs.setString('token', token);
    var api = MyxApi(
      baseUrl: apiBaseUrl,
      cache: cache,
      prefs: prefs,
      tokenOverride: token,
      scaffoldKey: scaffoldKey,
      isOnlineNotifier: isOnlineNotifier,
    );

    // Load saved theme preference
    final theme = await prefs.getString('theme') ?? 'system';

    runApp(
      XApp(
        api: api,
        initialTheme: theme,
        scaffoldKey: scaffoldKey,
        isOnlineNotifier: isOnlineNotifier,
      ),
    );
  }

  // creates the login page and redirects to main flow after login
  void startLoginFlow() async {
    runApp(
      inAppWebViewApp(baseWebUrl: selectedSchoolUrl, onToken: startAppFlow),
    );
  }

  void startSchoolSelectedFlow(String selectedSchool) async {
    selectedSchoolUrl = selectedSchool;
    apiBaseUrl = normalizeApiBase(selectedSchool);

    if (isOnlineNotifier.value != true) {
      final token = await prefs.getString('token');
      if (token != null) {
        // device is offline and token already exists,
        // just start app and wait for connection update
        startAppFlow(token);
      } else {
        // device is offline and token does not exist,
        // creating the login or app would be worthless
        void onlineListener() {
          if (isOnlineNotifier.value == true) {
            isOnlineNotifier.removeListener(onlineListener);
            startLoginFlow();
          }
        }

        isOnlineNotifier.addListener(onlineListener);
        runApp(offlinePage());
      }
    } else {
      // device is online, start regular old flow
      startLoginFlow();
    }
  }

  // main if-statement
  if (selectedSchool == null) {
    runApp(
      MaterialApp(
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: SchoolSelectorPage(onSchoolSelected: startSchoolSelectedFlow),
      ),
    );
  } else {
    startSchoolSelectedFlow(selectedSchool);
  }
}

bool _isDeviceOnline(List<ConnectivityResult> states) {
  if (states.contains(ConnectivityResult.wifi) ||
      states.contains(ConnectivityResult.mobile) ||
      states.contains(ConnectivityResult.ethernet)) {
    return true;
  }
  return false;
}

class XApp extends StatefulWidget {
  final MyxApi api;
  final String initialTheme;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  final ValueNotifier<bool?> isOnlineNotifier;

  XApp({
    super.key,
    required this.api,
    required this.initialTheme,
    required this.scaffoldKey,
    required this.isOnlineNotifier,
  });

  static String title = 'XRooster';

  final navigatorKey = GlobalKey<NavigatorState>();
  final rooster = GlobalKey<RoosterState>();

  @override
  State<XApp> createState() => XAppState();
}

class XAppState extends State<XApp> {
  // standaard de Schedule pagina
  int _currentIndex = 0;

  final _prefs = SharedPreferencesAsync();
  late String _themeMode;
  late MyxApi _api;
  bool _useModernScheduleLayout = true;

  // cached future so FutureBuilder doesn't recreate a new future each build
  late Future<MyxApi?> _apiFuture;

  // ensure we only check selectedAttendee once to avoid setState loops
  bool _checkedSelectedAttendee = false;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialTheme;
    _api = widget.api;

    _loadScheduleLayoutPreference();

    // listen for token invalidation
    _api.addListener(_onApiChange);

    // initialize cached future
    _apiFuture = _buildApiFuture();

    // Als geen attendee geselecteerd is dan naar de Attendees pagina
    widget.api.prefs.getInt("selectedAttendee").then((attendeeId) {
      if (attendeeId == null) {
        setState(() => _currentIndex = 1);
      }
    });
  }

  @override
  void dispose() {
    _api.removeListener(_onApiChange);
    super.dispose();
  }

  // rebuild on token invalidation
  void _onApiChange() {
    setState(() {
      _apiFuture = _buildApiFuture();
    });
  }

  Future<MyxApi?> _buildApiFuture() async {
    final token = await _prefs.getString("token");
    if (token == null) {
      return null;
    }

    _api.updateToken(token);
    return _api;
  }

  ThemeMode get themeMode {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> _updateTheme(String newTheme) async {
    await _prefs.setString('theme', newTheme);
    setState(() => _themeMode = newTheme);
  }

  Future<void> _loadScheduleLayoutPreference() async {
    final storedValue = await _prefs.getBool('use_better_schedule');
    if (!mounted) return;
    setState(() => _useModernScheduleLayout = storedValue ?? true);
  }

  Future<void> _updateScheduleLayout(bool useModern) async {
    await _prefs.setBool('use_better_schedule', useModern);
    setState(() => _useModernScheduleLayout = useModern);
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return SchedulePage(
          rooster: widget.rooster,
          api: _api,
          useModernScheduleLayout: _useModernScheduleLayout,
        );
      case 1:
        return AttendeePage(
          api: _api,
          prefs: _api.prefs,
          onClassSelected: () {
            setState(() => _currentIndex = 0); // ga naar Schedule pagina
          },
        );
      case 2:
        return SettingsPage(
          onThemeChanged: _updateTheme,
          onScheduleLayoutChanged: _updateScheduleLayout,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MyxApi?>(
      future: _apiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(),
          ); // api not ready
        }

        final api = snapshot.data;

        // login if no token = no api
        if (api == null) {
          return inAppWebViewApp(
            baseWebUrl: selectedSchoolUrl,
            onToken: (t) async {
              if ((await _prefs.getString('selectedSchool') ?? '').isEmpty &&
                  selectedSchoolUrl.isNotEmpty) {
                await _prefs.setString('selectedSchool', selectedSchoolUrl);
              }

              await _prefs.setString("token", t);
              // refresh cached future and trigger a single rebuild
              _apiFuture = _buildApiFuture();
              setState(() {});
            },
          );
        }

        _api = api;

        // Only check selectedAttendee once to avoid triggering repeated rebuilds
        if (!_checkedSelectedAttendee) {
          _checkedSelectedAttendee = true;
          _api.prefs.getInt("selectedAttendee").then((attendeeId) {
            if (!mounted) return;
            if (attendeeId == null && _currentIndex != 1) {
              setState(() => _currentIndex = 1);
            }
          });
        }

        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            final usingMaterialYou = _themeMode == 'material_you';

            final lightScheme = (usingMaterialYou && lightDynamic != null)
                ? lightDynamic
                : ColorScheme.fromSeed(seedColor: Colors.blue);

            final darkScheme = (usingMaterialYou && darkDynamic != null)
                ? darkDynamic
                : ColorScheme.fromSeed(
                    seedColor: Colors.blue,
                    brightness: Brightness.dark,
                  );

            return MaterialApp(
              title: XApp.title,
              navigatorKey: widget.navigatorKey,
              scaffoldMessengerKey: widget.scaffoldKey,
              theme: ThemeData(colorScheme: lightScheme, useMaterial3: true),
              darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
              themeMode: themeMode,
              home: Scaffold(
                appBar: AppBar(toolbarHeight: 0),
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_today),
                      label: 'Schedule',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.school),
                      label: 'Attendees',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                ),
                body: _getPage(_currentIndex),
              ),
            );
          },
        );
      },
    );
  }
}
