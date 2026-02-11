import 'package:json_annotation/json_annotation.dart';

part 'book_model.g.dart';

@JsonSerializable()
class BookModel {
  final int? id;
  final String? title;
  @JsonKey(name: 'add_date')
  final int? addDate;
  final List<Attachment>? attachments;

  BookModel({this.id, this.title, this.addDate, this.attachments});

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);
  Map<String, dynamic> toJson() => _$BookModelToJson(this);
}

@JsonSerializable()
class Attachment {
  final String? url;
  final String? size;

  Attachment({this.url, this.size});

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$AttachmentToJson(this);
}
