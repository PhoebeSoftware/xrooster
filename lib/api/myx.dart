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
import 'package:xrooster/pages/login/login.dart';

var token = "";

void setToken(String newToken) {
  token = newToken;
}

class MyxApi extends ChangeNotifier {
  late final Dio _dio;

  final navigatorKey = GlobalKey<NavigatorState>();
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final SharedPreferencesWithCache cache;
  final SharedPreferencesAsync prefs;

  /// Create a MyxApi instance. If [tokenOverride] is provided it will be
  /// used instead of the global `token` variable.
  MyxApi({required this.cache, required this.prefs, String? tokenOverride}) {
    final usedToken = tokenOverride ?? token;
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://talland.myx.nl/api/',
        headers: {"Authorization": "Bearer $usedToken"},
        validateStatus: (status) {
          if (status == 401) {
            debugPrint("token invalid");

            // invalidate
            prefs.remove("token");
            notifyListeners();
          }

          return true;
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
    try {
      final response = await _dio.get('Attendee/Type/$type');
      if (response.statusCode != 200) {
        debugPrint("Failed to get $type attendees: ${response.statusCode}");
        return List.empty();
      }

      List<dynamic> attendees = response.data['result'] as List<dynamic>;

      return attendees
          .map((e) => GroupAttendee.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Error fetching $type attendees: $e");
      return List.empty();
    }
  }

  Future<Location> getLocationById(int locationId) async {
    final cacheKey = 'location:$locationId';
    var cachedJson = cache.getString(cacheKey);
    if (cachedJson != null) {
      try {
        return Location.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
      } catch (e) {
        return Future.error('Error parsing cached appointments: $e');
      }
    }

    try {
      final response = await _dio.get('Attendee/$locationId');
      if (response.statusCode != 200) {
        return Future.error("Failed to get appointments: ${response.statusCode}");
      }

      final locationJson = response.data['result'] as Map<String, dynamic>;

      await cache.setString(cacheKey, jsonEncode(locationJson));
      return Location.fromJson(locationJson);
    } catch (e) {
      return Future.error("Error fetching appointments: $e");
    }
  }

  Future<Teacher> getTeacherById(int teacherId) async {
    final cacheKey = 'teacher:$teacherId';
    var cachedJson = cache.getString(cacheKey);
    if (cachedJson != null) {
      try {
        return Teacher.fromJson(jsonDecode(cachedJson) as Map<String, dynamic>);
      } catch (e) {
        return Future.error('Error parsing cached teacher: $e');
      }
    }

    try {
      final response = await _dio.get('Attendee/$teacherId');
      if (response.statusCode != 200) {
        return Future.error("Failed to get teacher: ${response.statusCode}");
      }

      final teacherJson = response.data['result'] as Map<String, dynamic>;

      await cache.setString(cacheKey, jsonEncode(teacherJson));
      return Teacher.fromJson(teacherJson);
    } catch (e) {
      return Future.error("Error fetching teacher: $e");
    }
  }

  Future<List<Appointment>> getAppointmentsForAttendee(String date) async {
    final attendeeId = await prefs.getInt("selectedAttendee");
    if (attendeeId == null) {
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('This is an in-app notification!'),
          duration: Duration(seconds: 3),
        ),
      );

      return List.empty();
    }

    final cacheKey = 'appointments:$date:$attendeeId';
    var cachedJson = cache.getString(cacheKey);
    if (cachedJson != null) {
      try {
        if (cachedJson.isEmpty) {
          debugPrint('Cached is empty');
          return List.empty();
        }

        return cachedJson
            .split(';')
            .where((e) => e.isNotEmpty) // Filter out empty strings
            .map((a) {
              try {
                return Appointment.fromJson(jsonDecode(a));
              } catch (parseError) {
                debugPrint('Error parsing appointment JSON: $parseError, JSON: $a');
                return null;
              }
            })
            .where((a) => a != null)
            .cast<Appointment>()
            .toList();
      } catch (e) {
        debugPrint('Error parsing cached appointments: $e');
        return List.empty();
      }
    }

    try {
      final response = await _dio.get(
        'Appointment/Date/$date/$date/Attendee?id=$attendeeId',
      );
      if (response.statusCode != 200) {
        debugPrint("Failed to get appointments: ${response.statusCode}");
        return List.empty();
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
    } catch (e) {
      debugPrint("Error fetching appointments: $e");
      return List.empty();
    }
  }
}
