import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xrooster/api/utils.dart';
import 'package:xrooster/models/appointment.dart';

class MyXWebCalApi {
  late final Dio _dio;
  final String baseUrl;
  final SharedPreferencesAsync prefs;

  MyXWebCalApi({required this.baseUrl, required String token, required this.prefs}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {"Authorization": "Bearer $token"},
        validateStatus: validateStatusCode,
      ),
    );
  }

  Future<String?> get userId async => await prefs.getString("userId");
  Future<String?> get feedId async => await prefs.getString("selectedFeed");

  Future<void> feedArgumentPatch() async {
    final response = await _dio.patch(
      "Settings",
      data: [
        // TITLE
        {"op": "add", "path": "/addTeachersToTitleInRosterExport", "value": true},
        {"op": "add", "path": "/addGroupsToTitleInRosterExport", "value": true},
        {"op": "add", "path": "/addClassroomsToTitleInRosterExport", "value": true},
        // DESCRIPTION
        {"op": "add", "path": "/addAttentionToDescriptionInRosterExport", "value": true},
        {"op": "add", "path": "/addNoteToDescriptionInRosterExport", "value": true},
        // LOCATION
        {"op": "add", "path": "/addTeachersToLocationInRosterExport", "value": true},
        {"op": "add", "path": "/addGroupsToLocationInRosterExport", "value": true},
      ],
    );

    if (!validateStatusCode(response.statusCode)) {
      throw Exception("Failed to update settings");
    }
  }

  Future<Map<String, List<Appointment>>> getAppointmentsForAttendee(
    String startDate,
    String endDate, {
    int? attendeeId,
  }) async {
    await _dio.get("InternetCalendar/feed/${await userId}/${await feedId}");

    return <String, List<Appointment>>{};
  }
}
