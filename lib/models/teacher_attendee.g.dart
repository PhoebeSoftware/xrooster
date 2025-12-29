// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_attendee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeacherAttendee _$TeacherAttendeeFromJson(Map<String, dynamic> json) =>
    TeacherAttendee(
      login: json['login'] as String?,
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      role: $enumDecode(_$AttendeeTypeEnumMap, json['role']),
    );

Map<String, dynamic> _$TeacherAttendeeToJson(TeacherAttendee instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'role': _$AttendeeTypeEnumMap[instance.role]!,
      'login': instance.login,
    };

const _$AttendeeTypeEnumMap = {
  AttendeeType.teacher: 'teacher',
  AttendeeType.group: 'group',
};
