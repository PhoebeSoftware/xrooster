// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feed _$FeedFromJson(Map<String, dynamic> json) => Feed(
  name: json['name'] as String,
  ids: (json['ids'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
);

Map<String, dynamic> _$FeedToJson(Feed instance) => <String, dynamic>{
  'name': instance.name,
  'ids': instance.ids,
};
