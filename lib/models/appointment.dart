import 'package:json_annotation/json_annotation.dart';
import 'package:xrooster/models/attendee_id.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  final int id;
  final String name;
  @JsonKey(defaultValue: '')
  final String summary;
  final DateTime start;
  final DateTime end;
  final AttendeeIds attendeeIds;

  Appointment({
    required this.id,
    required this.name,
    required this.summary,
    required this.start,
    required this.end,
    required this.attendeeIds,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}
