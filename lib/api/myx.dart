import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        validateStatus: (_) =>
            true, // no need for dio handling, we do (most) errors ourself
      ),
    );

    // add dio request interceptor for api errors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          final statusCode = response.statusCode ?? 000;
          final statusMessage = response.statusMessage ?? "No status messsage";

          // should show snackbar?
          if (statusCode == 200) {
            handler.next(response);
            return;
          }

          debugPrint(statusCode.toString());
          debugPrint(statusMessage);

          scaffoldKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('API Error: $statusCode $statusMessage'),
              duration: Duration(seconds: 10),
            ),
          );

          // check if unauthorized
          if (statusCode == 401) {
            debugPrint("Interceptor: MyX Token invalid!");

            // invalidate token & re-render app
            prefs.remove("token");
            notifyListeners();
          }

          handler.next(response);
        },
        onError: (DioException e, handler) {
          final statusCode = e.response?.statusCode ?? 000;
          final statusMessage = e.response?.statusMessage ?? "No status messsage";

          scaffoldKey.currentState?.showSnackBar(
            SnackBar(
              content: Text('API Error: $statusCode $statusMessage'),
              duration: Duration(seconds: 10),
            ),
          );
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
    if (response.statusCode != 200) {
      throw Exception('Failed to get $type attendees: ${response.statusMessage}');
    }

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
        return Location.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing cached location with locationId $locationId: $e');
        debugPrint('Invalidating cached location and re-fetching.');

        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get('Attendee/$locationId');
    if (response.statusCode != 200) {
      throw Exception('Failed to get location $locationId: ${response.statusMessage}');
    }

    final locationJson = response.data['result'] as Map<String, dynamic>;

    await cache.setString(cacheKey, jsonEncode(locationJson));
    return Location.fromJson(locationJson);
  }

  Future<Teacher> getTeacherById(int teacherId) async {
    final cacheKey = 'teacher:$teacherId';
    var cachedJson = cache.getString(cacheKey);
    if (cachedJson != null) {
      if (cachedJson.isEmpty) {
        cache.remove(cacheKey);
      }

      try {
        return Teacher.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing cached teacher with teacherId $teacherId: $e');
        debugPrint('Invalidating cached teacher and re-fetching.');

        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get('Attendee/$teacherId');
    if (response.statusCode != 200) {
      throw Exception('Failed to get teacher $teacherId: ${response.statusMessage}');
    }

    final teacherJson = response.data['result'] as Map<String, dynamic>;

    await cache.setString(cacheKey, jsonEncode(teacherJson));
    return Teacher.fromJson(teacherJson);
  }

  Future<GroupAttendee> getGroupById(int groupId) async {
    final cacheKey = 'group:$groupId';
    var cachedJson = cache.getString(cacheKey);
    if (cachedJson != null) {
      try {
        return GroupAttendee.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error parsing cached groupAttendee with groupid $groupId: $e');
        debugPrint('Invalidating cached groupAttendee and re-fetching.');

        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get('Attendee/$groupId');
    if (response.statusCode != 200) {
      throw Exception('Failed to get group $groupId: ${response.statusMessage}');
    }

    final groupJson = response.data['result'] as Map<String, dynamic>;

    await cache.setString(cacheKey, jsonEncode(groupJson));
    return GroupAttendee.fromJson(groupJson);
  }

  Future<List<Appointment>> getAppointmentsForAttendee(String date) async {
    final attendeeId = await prefs.getInt("selectedAttendee");
    if (attendeeId == null) {
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('Select an attendee before checking the schedule!'),
          duration: Duration(seconds: 3),
        ),
      );

      return List.empty();
    }

    final cacheKey = 'appointments:$date:$attendeeId';
    var cachedJson = cache.getString(cacheKey);
    if (cachedJson != null) {
      try {
        return cachedJson
            .split(';')
            .where((e) => e.isNotEmpty) // filter out empty strings
            .map((a) {
              return Appointment.fromJson(jsonDecode(a));
            })
            .cast<Appointment>()
            .toList();
      } catch (e) {
        debugPrint('Error parsing cached appointments with date $date: $e');
        debugPrint('Invalidating cached appointments and re-fetching.');

        cache.remove(cacheKey);
      }
    }

    final response = await _dio.get(
      'Appointment/Date/$date/$date/Attendee?id=$attendeeId',
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get appointments for date $date: ${response.statusMessage}',
      );
    }

    final appointmentsMap =
        response.data['result']['appointments'] as Map<String, dynamic>;

    // sort appointments with start timedate
    final sorted = appointmentsMap.values.toList()
      ..sort((a, b) {
        DateTime parse(String? stringTime) =>
            stringTime == null ? DateTime.now() : DateTime.parse(stringTime);
        return parse(a['start'] as String?).compareTo(parse(b['start'] as String?));
      });

    final appointments = sorted
        .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
        .toList();

    await cache.setString(
      cacheKey,
      appointments
          .map((appointment) => jsonEncode(appointment.toJson()))
          .toList()
          .join(';'),
    );

    return appointments;
  }
}
