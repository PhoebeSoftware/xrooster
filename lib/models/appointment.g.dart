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
  startUnit: (json['startTimeUnit'] as num).toInt(),
  end: DateTime.parse(json['end'] as String),
  endUnit: (json['endTimeUnit'] as num).toInt(),
  attendeeIds: AttendeeIds.fromJson(
    json['attendeeIds'] as Map<String, dynamic>,
  ),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'summary': instance.summary,
      'start': instance.start.toIso8601String(),
      'startTimeUnit': instance.startUnit,
      'end': instance.end.toIso8601String(),
      'endTimeUnit': instance.endUnit,
      'attendeeIds': instance.attendeeIds.toJson(),
      'comment': instance.comment,
    };
