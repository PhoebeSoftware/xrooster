import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

@JsonSerializable()
class MyxFeed {
  final String name;
}

@JsonSerializable()
class MyxSettings {
  MyxSettings({required this.feeds});
  final Map<String, MyxFeed> feeds;

  factory MyxSettings.fromJson(dynamic json) => _$MyxSettingsFromJson(json);
  dynamic toJson() => _$MyxSettingsToJson(this);
}
