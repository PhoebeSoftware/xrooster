// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teacher _$TeacherFromJson(Map<String, dynamic> json) => Teacher(
  id: (json['id'] as num).toInt(),
  login: json['login'] as String,
  code: json['code'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
  'id': instance.id,
  'login': instance.login,
  'code': instance.code,
  'role': instance.role,
};
