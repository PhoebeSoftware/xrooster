import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/models/appointment.dart';
import 'package:xrooster/models/group_attendee.dart';

var token = "";

void setToken(String newToken) {
  token = newToken;
}

class MyxApi {
  late final Dio _dio;

  final SharedPreferences prefs;

  /// Create a MyxApi instance. If [tokenOverride] is provided it will be
  /// used instead of the global `token` variable.
  MyxApi({required this.prefs, String? tokenOverride}) {
    // debugPrint('token: $token');
    final usedToken = tokenOverride ?? token;
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://talland.myx.nl/api/',
        headers: {"Authorization": "Bearer $usedToken"},
      ),
    );
  }

  Future<List<GroupAttendee>> getAllGroupAttendees() async {
    try {
      final response = await _dio.get('Attendee/Type/group');
      if (response.statusCode != 200) {
        debugPrint("Failed to get group attendees: ${response.statusCode}");
        return List.empty();
      }

      final attendeesMap = response.data['result'] as Map<String, dynamic>;

      return attendeesMap.entries.toList() as List<GroupAttendee>;
    } catch (e) {
      debugPrint("Error fetching attendees: $e");
      return List.empty();
    }
  }

  Future<List<Appointment>> getAppointmentsForAttendee(
    String date,
    int attendeeId,
  ) async {
    final cacheKey = 'appointments:$date:$attendeeId';
    var cachedJson = prefs.getString(cacheKey);
    if (cachedJson != null) {
      try {
        return cachedJson
            .split(';')
            .map((e) => Appointment.fromJson(jsonDecode(e)))
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

      final sorted = appointmentsMap.values.toList()
        ..sort((a, b) {
          DateTime parse(String? stringTime) =>
              stringTime == null ? DateTime.now() : DateTime.parse(stringTime);
          return parse(a['start'] as String?).compareTo(parse(b['start'] as String?));
        });

      final appointments = sorted
          .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
          .toList();

      await prefs.setString(
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
