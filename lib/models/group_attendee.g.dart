// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_attendee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupAttendee _$GroupAttendeeFromJson(Map<String, dynamic> json) =>
    GroupAttendee(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      role: json['role'] as String,
    );

Map<String, dynamic> _$GroupAttendeeToJson(GroupAttendee instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'role': instance.role,
    };
