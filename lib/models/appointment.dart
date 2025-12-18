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
  @JsonKey(name: "startTimeUnit")
  final int startUnit;
  final DateTime end;
  @JsonKey(name: "endTimeUnit")
  final int endUnit;
  final AttendeeIds attendeeIds;

  Appointment({
    required this.id,
    required this.name,
    required this.summary,
    required this.start,
    required this.startUnit,
    required this.end,
    required this.endUnit,
    required this.attendeeIds,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}
