import 'package:json_annotation/json_annotation.dart';
import 'package:xrooster/models/base_attendee.dart';

part 'teacher_attendee.g.dart';

@JsonSerializable()
class TeacherAttendee extends BaseAttendee {
  final String? login;

  TeacherAttendee({
    required this.login,
    required super.id,
    required super.code,
    required super.role,
  });

  factory TeacherAttendee.fromJson(dynamic json) => _$TeacherAttendeeFromJson(json);
  dynamic toJson() => _$TeacherAttendeeToJson(this);
}
