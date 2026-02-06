import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:yaml/yaml.dart';
import 'package:xrooster/api/myx.dart';
import 'package:xrooster/pages/attendees/attendees.dart';
import 'package:xrooster/pages/schedule/schedule.dart';
import 'package:xrooster/pages/schedule/timetable.dart';
import 'package:xrooster/pages/settings/settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MyxApi api;
  late SharedPreferencesAsync prefs;

  setUpAll(() async {
    await loadAppFonts();

    final version = loadYaml(File('pubspec.yaml').readAsStringSync())['version'].toString().split('+').first;

    PackageInfo.setMockInitialValues(
      appName: 'xrooster',
      packageName: 'nl.phoebesoftware.xrooster',
      version: version,
      buildNumber: '0',
      buildSignature: 'abc123',
    );

    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          'selectedAttendee': 101,
          'pinned_attendees': <String>["1", "102"],
        });

    prefs = SharedPreferencesAsync();
    final cache = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(),
    );

    api = MyxApi(
      baseUrl: 'https://demo.local/api/',
      cache: cache,
      prefs: prefs,
      scaffoldKey: GlobalKey<ScaffoldMessengerState>(),
      isOnlineNotifier: ValueNotifier(true),
      demoMode: true,
    );

    ScreenshotDevice.screenshotsFolder =
        '../fastlane/metadata/android/en-US/images/phoneScreenshots/';
  });

  Future<void> takeScreenshot(
    WidgetTester tester,
    Widget page,
    String name,
  ) async {
    for (final target in _screenshotTargets()) {
      final device = target.device;
      await _pumpScreenshotApp(tester, device, page);
      await tester.expectScreenshot(device, name);
    }
  }

  group('Screenshots', () {
    testGoldens('Schedule', (tester) async {
      final timetableKey = GlobalKey<TimetableState>();
      await takeScreenshot(
        tester,
        Scaffold(
          appBar: AppBar(title: const Text('Schedule')),
          body: SchedulePage(
            timetableKey: timetableKey,
            api: api,
            useModernScheduleLayout: true,
          ),
        ),
        '1',
      );
    });

    testGoldens('Schedule Detail', (tester) async {
      final timetableKey = GlobalKey<TimetableState>();
      final page = Scaffold(
        appBar: AppBar(title: const Text('Schedule')),
        body: SchedulePage(
          timetableKey: timetableKey,
          api: api,
          useModernScheduleLayout: true,
        ),
      );

      await _pumpScreenshotApp(tester, _screenshotTargets().first.device, page);

      final finder = find.text('NED');
      await tester.tap(finder.first);
      await tester.pumpAndSettle();

      await tester.expectScreenshot(_screenshotTargets().first.device, '2');
    });

    testGoldens('Attendees', (tester) async {
      await takeScreenshot(
        tester,
        Scaffold(
          appBar: AppBar(title: const Text('Attendees')),
          body: AttendeePage(
            api: api,
            prefs: prefs,
            onClassSelected: () {},
            useModernScheduleLayout: true,
          ),
        ),
        '3',
      );
    });

    testGoldens('Settings', (tester) async {
      await takeScreenshot(tester, const SettingsPage(), '4');
    });
  });
}

class _ScreenshotTarget {
  final String name;
  final ScreenshotDevice device;
  const _ScreenshotTarget(this.name, this.device);
}

List<_ScreenshotTarget> _screenshotTargets() => const [
  _ScreenshotTarget(
    'androidPhone',
    ScreenshotDevice(
      platform: TargetPlatform.android,
      resolution: Size(1280, 2856),
      pixelRatio: 3,
      goldenSubFolder: './',
      frameBuilder: ScreenshotFrame.androidPhone,
    ),
  ),
];

Future<void> _pumpScreenshotApp(WidgetTester tester, ScreenshotDevice device, Widget home) async {
  await tester.pumpWidget(
    ScreenshotApp(
      device: device,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: home,
    ),
  );

  await tester.loadAssets();
  await tester.pump();
  await tester.pumpFrames(
    tester.widget(find.byType(ScreenshotApp)),
    const Duration(seconds: 1),
  );
}