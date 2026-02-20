import 'package:json_annotation/json_annotation.dart';
import 'package:xrooster/models/feed.dart';

part 'settings.g.dart';

@JsonSerializable()
class Settings {
  final Map<String, Feed> feeds;

  Settings({required this.feeds});

  factory Settings.fromJson(dynamic json) => _$SettingsFromJson(json);
  dynamic toJson() => _$SettingsToJson(this);
}
