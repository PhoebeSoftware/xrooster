import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/models/appointment.dart';
import 'package:xrooster/models/group_attendee.dart';
import 'package:xrooster/models/location.dart';

var token = "";

void setToken(String newToken) {
  token = newToken;
}

class MyxApi {
  late final Dio _dio;

  final SharedPreferencesWithCache cache;

  /// Create a MyxApi instance. If [tokenOverride] is provided it will be
  /// used instead of the global `token` variable.
  MyxApi({required this.cache, String? tokenOverride}) {
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

      List<dynamic> attendees = response.data['result'] as List<dynamic>;

      return attendees
          .map((e) => GroupAttendee.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Error fetching attendees: $e");
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

  Future<List<Appointment>> getAppointmentsForAttendee(
    String date,
    int attendeeId,
  ) async {
    final cacheKey = 'appointments:$date:$attendeeId';
    var cachedJson = cache.getString(cacheKey);
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
