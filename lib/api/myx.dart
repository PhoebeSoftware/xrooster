import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/models/appointment.dart';

var token =
    "eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNyc2Etc2hhMjU2IiwidHlwIjoiSldUIn0.eyJhdWQiOiJsaXZlLnRhbGxhbmQvQXBpIiwiaXNzIjoibGl2ZS50YWxsYW5kL0F1dGhlbnRpY2F0aW9uIiwidXNlciI6IjRlYWY3YWM5LTdmZGYtNDA5OC1hZWEwLTQyOGM2YTEyZDU1NyIsIm5hbWUiOiIxODIwOTVAc3R1ZGVudC50YWxsYW5kLm5sIiwicm9sZSI6InN0dWRlbnQiLCJzY29wZSI6IlJvc3RlciBTZXR0aW5ncyIsIm9yZ2FuaXNhdGlvbiI6InRhbGxhbmQiLCJleHAiOjE3NjAxNDUxODAsImlhdCI6MTc2MDEwMTk4MCwibmJmIjoxNzYwMTAxOTgwfQ.jaw7nuwR6grzPAUNLprgjZa6d8RDEzCH-baBTJkLuJ3N_x79er0dsT5PccUBphbcbc0eTxQqc3OyBm5_IBFkBHsBibuw_-1Pd7KI42aQnrQ-8LYGyQERpb90Q0e8TCwDIMYhe8egMjyV88GiKE1Fnl4AGqUxE8i9o-sfqouhUkSkyoXbHIz5YSy-TPA8A_ZuOQqCIKatmknwh34fuz0cBVuQX_nS74z9umIrs4_X52wSZ_ne6pgE9CHsipDPCEcB_3FEuQZhfIl2gQXieq8LbHPrr4IFMhCBsScguYMGpxRNQYy35cwJu3h2odIlK6Hx08pSno-8y2wpyltnfA8o8g";

class MyxApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://talland.myx.nl/api/',
      headers: {"Authorization": "Bearer $token"},
    ),
  );

  final SharedPreferences prefs;

  MyxApi({required this.prefs});

  Future<List<Appointment>> getAppointmentsForAttendee(String date, int attendeeId) async {
    var cachedJson = prefs.getString(date);
    if (cachedJson != null) {
      debugPrint('cached');
      return cachedJson.split(',').map((e) => Appointment.fromJson(jsonDecode(e))).toList();
    }

    final response = await _dio.get('Appointment/Date/$date/$date/Attendee?id=$attendeeId');
    if (response.statusCode != 200) {
      debugPrint("failed to get appointments");
      return List.empty();
    }

    final Map<String, dynamic> appointments = response.data['result']['appointments'];
    prefs.setString(date, appointments.values.map((e) => jsonEncode(e)).join(','));

    return appointments.values
        .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
