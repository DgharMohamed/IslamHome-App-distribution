// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookModel _$BookModelFromJson(Map<String, dynamic> json) => BookModel(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      addDate: (json['add_date'] as num?)?.toInt(),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BookModelToJson(BookModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'add_date': instance.addDate,
      'attachments': instance.attachments,
    };

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => Attachment(
      url: json['url'] as String?,
      size: json['size'] as String?,
    );

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'url': instance.url,
      'size': instance.size,
    };
