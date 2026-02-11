// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoModel _$VideoModelFromJson(Map<String, dynamic> json) => VideoModel(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      thumbUrl: json['thumb_url'] as String?,
      reciter: json['reciter'] as String?,
      videoType: (json['video_type'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VideoModelToJson(VideoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'url': instance.url,
      'thumb_url': instance.thumbUrl,
      'reciter': instance.reciter,
      'video_type': instance.videoType,
    };

VideoType _$VideoTypeFromJson(Map<String, dynamic> json) => VideoType(
      id: (json['id'] as num?)?.toInt(),
      name: json['video_type'] as String?,
    );

Map<String, dynamic> _$VideoTypeToJson(VideoType instance) => <String, dynamic>{
      'id': instance.id,
      'video_type': instance.name,
    };
