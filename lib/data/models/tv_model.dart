import 'package:json_annotation/json_annotation.dart';

part 'tv_model.g.dart';

@JsonSerializable()
class TvModel {
  final String? name;
  final String? url;

  TvModel({this.name, this.url});

  factory TvModel.fromJson(Map<String, dynamic> json) =>
      _$TvModelFromJson(json);
  Map<String, dynamic> toJson() => _$TvModelToJson(this);
}
