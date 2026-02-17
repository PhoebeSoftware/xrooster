import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
class Location {
  final int id;
  final String? location;
  final String? code;
  final String? role;

  Location({
    required this.id,
    this.location,
    this.code,
    this.role,
  });

  factory Location.fromJson(dynamic json) => _$LocationFromJson(json);
  dynamic toJson() => _$LocationToJson(this);
}
