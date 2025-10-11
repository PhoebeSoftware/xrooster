// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  id: (json['id'] as num).toInt(),
  location: json['location'] as String,
  code: json['code'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'id': instance.id,
  'location': instance.location,
  'code': instance.code,
  'role': instance.role,
};
