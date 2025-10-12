import 'package:json_annotation/json_annotation.dart';

part 'teacher.g.dart';

@JsonSerializable()
class Teacher {
  final int id;
  final String login;
  final String code;
  final String role;

  Teacher({
    required this.id,
    required this.login,
    required this.code,
    required this.role,
  });

  factory Teacher.fromJson(dynamic json) => _$TeacherFromJson(json);
  dynamic toJson() => _$TeacherToJson(this);
}
