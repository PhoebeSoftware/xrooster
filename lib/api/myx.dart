import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

import 'package:xrooster/models/appointment.dart';
import 'package:xrooster/models/base_attendee.dart';
import 'package:xrooster/models/group_attendee.dart';
import 'package:xrooster/models/location.dart';
import 'package:xrooster/models/teacher_attendee.dart';

var token = "";

void setToken(String newToken) {
  token = newToken;
}

class MyxApi extends ChangeNotifier {
  late final Dio _dio;

  final navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  final SharedPreferencesWithCache cache;
  final SharedPreferencesAsync prefs;

  final ValueNotifier<bool?> isOnlineNotifier;

  final String baseUrl;
  final bool demoMode;
  Map<String, dynamic>? _demoDataCache;
  static List<Map<String, dynamic>>? _schoolsConfigCache;

  /// Create a MyxApi instance. If [tokenOverride] is provided it will be
  /// used instead of the global `token` variable.
  MyxApi({
    required this.baseUrl,
    required this.cache,
    required this.prefs,
    required this.scaffoldKey,
    required this.isOnlineNotifier,
    String? tokenOverride,
    this.demoMode = false,
  }) {
    final usedToken = tokenOverride ?? token;
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {"Authorization": "Bearer $usedToken"},
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );

    // add dio request interceptor for api errors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          isOnlineNotifier.value = true;
          handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.error is SocketException) {
            isOnlineNotifier.value = false;
          }

          if (isOnlineNotifier.value != true) {
            handler.next(e);
            return;
          }

          final statusCode = e.response?.statusCode ?? 000;

          // check if unauthorized
          if (statusCode == 401) {
            debugPrint("Interceptor: MyX Token invalid!");

            // invalidate token & re-render app
            await prefs.remove("token");
            notifyListeners();
          }

          handler.next(e);
        },
      ),
    );

    // Certificate fix for self-signed certificates
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) =>
          true;
      return client;
    };
  }

  Future<Map<String, dynamic>> _loadDemoData() async => _demoDataCache ??= jsonDecode(
    await rootBundle.loadString('assets/demo_schedule.json'),
  );

  Future<String> _resolveAttendeeSource() async {
    final selectedSchool = await prefs.getString('selectedSchool');
    if (selectedSchool == null || selectedSchool.isEmpty) return 'attendees';

    _schoolsConfigCache ??=
        (jsonDecode(await rootBundle.loadString('assets/schools.json')) as List<dynamic>)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

    final matchingSchool = _schoolsConfigCache!.cast<Map<String, dynamic>?>().firstWhere(
      (school) => (school?['url'] as String?) == selectedSchool,
      orElse: () => null,
    );
    return (matchingSchool?['attendeeSource'] as String?) ?? 'attendees';
  }

  Future<List<T>> _getDemoList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final list = (await _loadDemoData())[key] as List;

    return list.map((item) => fromJson(Map.from(item as Map))).toList();
  }

  Future<T> _getDemoById<T>(
    String key,
    int id,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final rawList = await _getDemoList<Map<String, dynamic>>(key, (rawItem) => rawItem);
    final matchingItem = rawList.firstWhere(
      (item) => item['id'] == id,
      orElse: () => rawList.first,
    );

    return fromJson(matchingItem);
  }

  Future<List<BaseAttendee>> _getDemoAttendees(AttendeeType type) => _getDemoList(
    type == AttendeeType.teacher ? 'teachers' : 'groups',
    (data) => type == AttendeeType.teacher
        ? TeacherAttendee.fromJson(data..['role'] = 'teacher')
        : GroupAttendee.fromJson(data..['role'] = 'group'),
  );

  Future<Location> _getDemoLocation(int id) =>
      _getDemoById('locations', id, Location.fromJson);

  Future<TeacherAttendee> _getDemoTeacher(int id) => _getDemoById(
    'teachers',
    id,
    (data) => TeacherAttendee.fromJson(data..['role'] = 'teacher'),
  );

  Future<GroupAttendee> _getDemoGroup(int id) => _getDemoById(
    'groups',
    id,
    (data) => GroupAttendee.fromJson(data..['role'] = 'group'),
  );

  Future<Map<String, List<Appointment>>> _getDemoAppointments() async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final rawAppointments = (await _loadDemoData())['appointments'] as List;
    final formatter = DateFormat('yyyy-MM-dd HH:mm');

    final appointments = rawAppointments.map((rawItem) {
      final data = Map<String, dynamic>.from(rawItem);
      final start = dayStart.add(
        Duration(
          days: data['dayOffset'],
          hours: data['startHour'],
          minutes: data['startMinute'],
        ),
      );
      final end = dayStart.add(
        Duration(
          days: data['dayOffset'],
          hours: data['endHour'],
          minutes: data['endMinute'],
        ),
      );

      return Appointment.fromJson({
        ...data,
        'start': formatter.format(start),
        'end': formatter.format(end),
        'startTimeUnit': start.hour * 60 + start.minute,
        'endTimeUnit': end.hour * 60 + end.minute,
      });
    }).toList();

    appointments.sort((first, second) => first.start.compareTo(second.start));

    return {DateFormat('yyyy-MM-dd').format(dayStart): appointments};
  }

  /// Update the authorization token for this API instance
  void updateToken(String newToken) {
    debugPrint("MyxApi: Updating token");
    _dio.options.headers["Authorization"] = "Bearer $newToken";
  }

  BaseAttendee _createAttendeeFromJson(AttendeeType type, Map<String, dynamic> json) {
    switch (type) {
      case AttendeeType.teacher:
        return TeacherAttendee.fromJson(json);
      case AttendeeType.group:
        return GroupAttendee.fromJson(json);
    }
  }

  Future<List<BaseAttendee>> getAllAttendees(AttendeeType type) async {
    if (demoMode) {
      return await _getDemoAttendees(type);
    }

    final cacheKey = 'attendees:${type.name}';
    var cachedJson = cache.getString(cacheKey);
    if (isOnlineNotifier.value != true && cachedJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedJson) as List<dynamic>;
        return decoded
            .map((a) => _createAttendeeFromJson(type, a as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error parsing cached attendees for type $type: $e');
        debugPrint('Invalidating cached attendees and re-fetching.');
        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get('Attendee/Type/${type.name}');
    List<dynamic> attendees = response.data['result'] as List<dynamic>;

    await cache.setString(cacheKey, jsonEncode(attendees));

    return attendees
        .map((a) => _createAttendeeFromJson(type, a as Map<String, dynamic>))
        .toList();
  }

  Future<Location> getLocationById(int locationId) async {
    if (demoMode) {
      return await _getDemoLocation(locationId);
    }

    final cacheKey = 'location:$locationId';
    var cachedJson = cache.getString(cacheKey);
    if (isOnlineNotifier.value != true && cachedJson != null) {
      try {
        return Location.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing cached location with locationId $locationId: $e');
        debugPrint('Invalidating cached location and re-fetching.');

        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get('Attendee/$locationId');
    final locationJson = response.data['result'] as Map<String, dynamic>;

    await cache.setString(cacheKey, jsonEncode(locationJson));
    return Location.fromJson(locationJson);
  }

  Future<TeacherAttendee> getTeacherById(int teacherId) async {
    if (demoMode) {
      return await _getDemoTeacher(teacherId);
    }

    final cacheKey = 'teacher:$teacherId';
    var cachedJson = cache.getString(cacheKey);
    if (isOnlineNotifier.value != true && cachedJson != null) {
      try {
        return TeacherAttendee.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing cached teacher with teacherId $teacherId: $e');
        debugPrint('Invalidating cached teacher and re-fetching.');

        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get('Attendee/$teacherId');
    final teacherJson = response.data['result'] as Map<String, dynamic>;

    await cache.setString(cacheKey, jsonEncode(teacherJson));
    return TeacherAttendee.fromJson(teacherJson);
  }

  Future<GroupAttendee> getGroupById(int groupId) async {
    if (demoMode) {
      return await _getDemoGroup(groupId);
    }

    final cacheKey = 'group:$groupId';
    var cachedJson = cache.getString(cacheKey);
    if (isOnlineNotifier.value != true && cachedJson != null) {
      try {
        return GroupAttendee.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing cached groupAttendee with groupid $groupId: $e');
        debugPrint('Invalidating cached groupAttendee and re-fetching.');

        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get('Attendee/$groupId');
    final groupJson = response.data['result'] as Map<String, dynamic>;

    await cache.setString(cacheKey, jsonEncode(groupJson));
    return GroupAttendee.fromJson(groupJson);
  }

  Future<int?> getAttendeeFromFeed() async {
    if (demoMode) return null;

    final source = await _resolveAttendeeSource();
    if (source != 'settingsFeed') return null;

    final response = await _dio.get('Settings');
    final feeds = (response.data['result']?['feeds'] as Map<String, dynamic>?) ?? {};

    for (final feed in feeds.values.whereType<Map<String, dynamic>>()) {
      final ids = feed['ids'] as List?;
      if (ids?.isNotEmpty ?? false) {
        final first = ids!.first;
        if (first is num) return first.toInt();
        if (first is String) return int.tryParse(first);
      }
    }

    return null;
  }

  Future<Map<String, List<Appointment>>> getAppointmentsForAttendee(
    String startDate,
    String endDate, {
    int? attendeeId,
  }) async {
    if (demoMode) {
      return await _getDemoAppointments();
    }

    var usedAttendeeId = attendeeId ?? await prefs.getInt("selectedAttendee");
    if (usedAttendeeId == null) {
      final fallbackAttendeeId = await getAttendeeFromFeed();
      if (fallbackAttendeeId != null) {
        usedAttendeeId = fallbackAttendeeId;
        await prefs.setInt('selectedAttendee', fallbackAttendeeId);
      }
    }

    if (usedAttendeeId == null) {
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Select an attendee before checking the schedule!'),
          duration: Duration(seconds: 3),
        ),
      );

      return {};
    }
    final cacheKey = 'appointments:$startDate:$endDate:$usedAttendeeId';

    var cachedJson = cache.getString(cacheKey);
    if (isOnlineNotifier.value != true && cachedJson != null) {
      try {
        final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
        return decoded.map((d, a) {
          final appointments = (a as List<dynamic>)
              .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
              .toList();

          return MapEntry(d, appointments);
        });
      } catch (e) {
        debugPrint(
          'Error parsing cached appointments with date starting at $startDate: $e',
        );
        debugPrint('Invalidating cached appointments and re-fetching.');

        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get(
      'Appointment/Date/$startDate/$endDate/Attendee?id=$usedAttendeeId',
    );

    // map week appointments to type
    final weekAppointments = (response.data['result']['appointments'] as Map).values
        .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
        .toList();

    // group week appointments into day appointment lists
    var dayAppointments = weekAppointments.groupListsBy(
      (a) => DateFormat('yyyy-MM-dd').format(a.start),
    );

    // sort appointments within each day by start datetime
    dayAppointments.forEach((_, appointments) {
      appointments.sort((a, b) => a.start.compareTo(b.start));
    });

    // store encoded week json in cache
    await cache.setString(
      cacheKey,
      jsonEncode(
        dayAppointments.map((date, appointments) {
          return MapEntry(date, appointments.map((a) => a.toJson()).toList());
        }),
      ),
    );

    return dayAppointments;
  }
}
