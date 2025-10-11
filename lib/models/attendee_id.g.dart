// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendee_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendeeIds _$AttendeeIdsFromJson(Map<String, dynamic> json) => AttendeeIds(
  teacher: (json['teacher'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  classroom: (json['classroom'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  group: (json['group'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  student: (json['student'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  materials: (json['materials'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$AttendeeIdsToJson(AttendeeIds instance) =>
    <String, dynamic>{
      'teacher': instance.teacher,
      'classroom': instance.classroom,
      'group': instance.group,
      'student': instance.student,
      'materials': instance.materials,
    };
