import 'package:json_annotation/json_annotation.dart';

part 'riwaya_model.g.dart';

@JsonSerializable()
class Riwaya {
  final int? id;
  final String? name;

  Riwaya({this.id, this.name});

  factory Riwaya.fromJson(Map<String, dynamic> json) => _$RiwayaFromJson(json);
  Map<String, dynamic> toJson() => _$RiwayaToJson(this);
}
