import 'package:json_annotation/json_annotation.dart';

part 'feed.g.dart';

@JsonSerializable()
class Feed {
  Feed({required this.name, required this.ids});

  final String name;
  final List<int> ids;

  factory Feed.fromJson(dynamic json) => _$FeedFromJson(json);
  dynamic toJson() => _$FeedToJson(this);
}
