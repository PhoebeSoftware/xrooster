import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dio/io.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

import 'package:xrooster/models/appointment.dart';
import 'package:xrooster/models/group_attendee.dart';
import 'package:xrooster/models/location.dart';
import 'package:xrooster/models/teacher.dart';

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

  final String baseUrl;

  /// Create a MyxApi instance. If [tokenOverride] is provided it will be
  /// used instead of the global `token` variable.
  MyxApi({
    required this.baseUrl,
    required this.cache,
    required this.prefs,
    required this.scaffoldKey,
    String? tokenOverride,
  }) {
    final usedToken = tokenOverride ?? token;
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {"Authorization": "Bearer $usedToken"},
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    );

    // add dio request interceptor for api errors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          final statusCode = e.response?.statusCode ?? 000;

          // check if unauthorized
          if (statusCode == 401) {
            debugPrint("Interceptor: MyX Token invalid!");

            // invalidate token & re-render app
            prefs.remove("token");
            notifyListeners();
          }

          handler.next(e);
        },
      ),
    );

    // Certificate fix for self-signed certificates
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<List<GroupAttendee>> getAllAttendees(String type) async {
    final cacheKey = 'attendees:$type';
    var cachedJson = cache.getString(cacheKey);
    if (cachedJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedJson) as List<dynamic>;
        return decoded
            .map((e) => GroupAttendee.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Error parsing cached attendees for type $type: $e');
        debugPrint('Invalidating cached attendees and re-fetching.');
        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get('Attendee/Type/$type');
    List<dynamic> attendees = response.data['result'] as List<dynamic>;

    await cache.setString(cacheKey, jsonEncode(attendees));

    return attendees
        .map((e) => GroupAttendee.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Location> getLocationById(int locationId) async {
    final cacheKey = 'location:$locationId';
    var cachedJson = cache.getString(cacheKey);
    if (cachedJson != null) {
      try {
        return Location.fromJson(
          jsonDecode(cachedJson) as Map<String, dynamic>,
        );
      } catch (e) {
        debugPrint(
          'Error parsing cached location with locationId $locationId: $e',
        );
        debugPrint('Invalidating cached location and re-fetching.');

        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get('Attendee/$locationId');
    final locationJson = response.data['result'] as Map<String, dynamic>;

    await cache.setString(cacheKey, jsonEncode(locationJson));
    return Location.fromJson(locationJson);
  }

  Future<Teacher> getTeacherById(int teacherId) async {
    final cacheKey = 'teacher:$teacherId';
    var cachedJson = cache.getString(cacheKey);
    if (cachedJson != null) {
      try {
        return Teacher.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
      } catch (e) {
        debugPrint(
          'Error parsing cached teacher with teacherId $teacherId: $e',
        );
        debugPrint('Invalidating cached teacher and re-fetching.');

        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get('Attendee/$teacherId');
    final teacherJson = response.data['result'] as Map<String, dynamic>;

    await cache.setString(cacheKey, jsonEncode(teacherJson));
    return Teacher.fromJson(teacherJson);
  }

  Future<GroupAttendee> getGroupById(int groupId) async {
    final cacheKey = 'group:$groupId';
    var cachedJson = cache.getString(cacheKey);
    if (cachedJson != null) {
      try {
        return GroupAttendee.fromJson(
          jsonDecode(cachedJson) as Map<String, dynamic>,
        );
      } catch (e) {
        debugPrint(
          'Error parsing cached groupAttendee with groupid $groupId: $e',
        );
        debugPrint('Invalidating cached groupAttendee and re-fetching.');

        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get('Attendee/$groupId');
    final groupJson = response.data['result'] as Map<String, dynamic>;

    await cache.setString(cacheKey, jsonEncode(groupJson));
    return GroupAttendee.fromJson(groupJson);
  }

  Future<Map<String, List<Appointment>>> getAppointmentsForAttendee(
    String startDate,
    String endDate, {
    int? attendeeId,
  }) async {
    final usedAttendeeId = attendeeId ?? await prefs.getInt("selectedAttendee");
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
    if (cachedJson != null) {
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
    final weekAppointments = (response.data['result']['appointments'] as Map)
        .values
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
