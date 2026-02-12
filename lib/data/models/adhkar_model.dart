import 'package:json_annotation/json_annotation.dart';

part 'adhkar_model.g.dart';

@JsonSerializable()
class AdhkarModel {
  final String? id;
  final String? category;
  final String? text;
  final String? arabic;
  final String? zikr;
  final String? english;
  final dynamic count;
  final String? description;
  final String? reference;

  AdhkarModel({
    this.id,
    this.category,
    this.text,
    this.arabic,
    this.zikr,
    this.english,
    this.count,
    this.description,
    this.reference,
  });

  String get zekr => zikr ?? text ?? arabic ?? '';
  String get zekrText => zekr;

  int get targetCount {
    if (count == null) return 1;
    if (count is int) return count;
    return int.tryParse(count.toString()) ?? 1;
  }

  factory AdhkarModel.fromJson(Map<String, dynamic> json) =>
      _$AdhkarModelFromJson(json);
  Map<String, dynamic> toJson() => _$AdhkarModelToJson(this);
}
