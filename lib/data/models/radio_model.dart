import 'package:json_annotation/json_annotation.dart';

part 'radio_model.g.dart';

@JsonSerializable()
class RadioModel {
  final int? id;
  final String? name;
  final String? url;

  RadioModel({this.id, this.name, this.url});

  factory RadioModel.fromJson(Map<String, dynamic> json) =>
      _$RadioModelFromJson(json);
  Map<String, dynamic> toJson() => _$RadioModelToJson(this);
}
