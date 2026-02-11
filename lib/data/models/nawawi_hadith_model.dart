import 'package:json_annotation/json_annotation.dart';

part 'nawawi_hadith_model.g.dart';

@JsonSerializable()
class NawawiHadith {
  final int? number;
  final String? arabicText;
  final String? englishTranslation;
  final String? explanation;
  final String? reference;
  final String? theme;

  NawawiHadith({
    this.number,
    this.arabicText,
    this.englishTranslation,
    this.explanation,
    this.reference,
    this.theme,
  });

  factory NawawiHadith.fromJson(Map<String, dynamic> json) =>
      _$NawawiHadithFromJson(json);
  Map<String, dynamic> toJson() => _$NawawiHadithToJson(this);
}
