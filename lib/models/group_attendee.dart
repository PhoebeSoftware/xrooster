import 'package:json_annotation/json_annotation.dart';

part 'group_attendee.g.dart';

@JsonSerializable()
class GroupAttendee {
  final int id;
  final String code;
  final String role;

  GroupAttendee({required this.id, required this.code, required this.role});

  factory GroupAttendee.fromJson(Map<String, dynamic> json) =>
      _$GroupAttendeeFromJson(json);
  Map<String, dynamic> toJson() => _$GroupAttendeeToJson(this);
}
