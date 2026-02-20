// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
  feeds: (json['feeds'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, Feed.fromJson(e)),
  ),
);

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
  'feeds': instance.feeds.map((k, e) => MapEntry(k, e.toJson())),
};
