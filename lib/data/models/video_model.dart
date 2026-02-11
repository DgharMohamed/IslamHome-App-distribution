import 'package:json_annotation/json_annotation.dart';

part 'video_model.g.dart';

@JsonSerializable()
class VideoModel {
  final int? id;
  final String? title;
  final String? description;
  final String? url;
  @JsonKey(name: 'thumb_url')
  final String? thumbUrl;
  final String? reciter;
  @JsonKey(name: 'video_type')
  final int? videoType;

  VideoModel({
    this.id,
    this.title,
    this.description,
    this.url,
    this.thumbUrl,
    this.reciter,
    this.videoType,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);
  Map<String, dynamic> toJson() => _$VideoModelToJson(this);
}

@JsonSerializable()
class VideoType {
  final int? id;
  @JsonKey(name: 'video_type')
  final String? name;

  VideoType({this.id, this.name});

  factory VideoType.fromJson(Map<String, dynamic> json) =>
      _$VideoTypeFromJson(json);
  Map<String, dynamic> toJson() => _$VideoTypeToJson(this);
}
