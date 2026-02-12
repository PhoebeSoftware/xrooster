// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyxFeed _$MyxFeedFromJson(Map<String, dynamic> json) => MyxFeed();

Map<String, dynamic> _$MyxFeedToJson(MyxFeed instance) => <String, dynamic>{};

MyxSettings _$MyxSettingsFromJson(Map<String, dynamic> json) => MyxSettings(
  feeds: (json['feeds'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, MyxFeed.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$MyxSettingsToJson(MyxSettings instance) =>
    <String, dynamic>{
      'feeds': instance.feeds.map((k, e) => MapEntry(k, e.toJson())),
    };
