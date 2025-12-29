import 'package:json_annotation/json_annotation.dart';
import 'package:xrooster/models/base_attendee.dart';

part 'group_attendee.g.dart';

@JsonSerializable()
class GroupAttendee extends BaseAttendee {
  GroupAttendee({required super.id, required super.code, required super.role});

  factory GroupAttendee.fromJson(dynamic json) => _$GroupAttendeeFromJson(json);
  dynamic toJson() => _$GroupAttendeeToJson(this);
}
