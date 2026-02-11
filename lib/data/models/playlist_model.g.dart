// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Playlist _$PlaylistFromJson(Map<String, dynamic> json) => Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => PlaylistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PlaylistToJson(Playlist instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

PlaylistItem _$PlaylistItemFromJson(Map<String, dynamic> json) => PlaylistItem(
      id: json['id'] as String,
      surahNumber: (json['surahNumber'] as num).toInt(),
      surahName: json['surahName'] as String,
      reciterId: (json['reciterId'] as num).toInt(),
      reciterName: json['reciterName'] as String,
      url: json['url'] as String,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$PlaylistItemToJson(PlaylistItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'surahNumber': instance.surahNumber,
      'surahName': instance.surahName,
      'reciterId': instance.reciterId,
      'reciterName': instance.reciterName,
      'url': instance.url,
      'order': instance.order,
    };
