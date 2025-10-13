// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  summary: json['summary'] as String? ?? '',
  start: DateTime.parse(json['start'] as String),
  end: DateTime.parse(json['end'] as String),
  attendeeIds: AttendeeIds.fromJson(
    json['attendeeIds'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'summary': instance.summary,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'attendeeIds': instance.attendeeIds.toJson(),
    };
