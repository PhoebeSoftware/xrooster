import 'package:json_annotation/json_annotation.dart';

part 'appointment.g.dart';

@JsonSerializable()
class Appointment {
  final int id;
  final String name;
  final String summary;
  final DateTime start;
  final DateTime end;

  Appointment({
    required this.id,
    required this.name,
    required this.summary,
    required this.start,
    required this.end,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}
