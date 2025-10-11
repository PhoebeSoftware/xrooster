import 'package:json_annotation/json_annotation.dart';

part 'attendee_id.g.dart';

@JsonSerializable()
class AttendeeIds {
  final List<int> teacher;
  final List<int> classroom;
  final List<int> group;
  final List<int> student;
  final List<int> materials;

  AttendeeIds({
    required this.teacher,
    required this.classroom,
    required this.group,
    required this.student,
    required this.materials,
  });

  factory AttendeeIds.fromJson(Map<String, dynamic> json) => _$AttendeeIdsFromJson(json);
  Map<String, dynamic> toJson() => _$AttendeeIdsToJson(this);
}
