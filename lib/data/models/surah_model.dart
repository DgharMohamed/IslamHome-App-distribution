import 'package:json_annotation/json_annotation.dart';

part 'surah_model.g.dart';

@JsonSerializable()
class Surah {
  final int? number;
  final String? name;
  final String? englishName;
  final String? revelationType;
  final int? numberOfAyahs;

  Surah({
    this.number,
    this.name,
    this.englishName,
    this.revelationType,
    this.numberOfAyahs,
  });

  factory Surah.fromJson(Map<String, dynamic> json) => _$SurahFromJson(json);
  Map<String, dynamic> toJson() => _$SurahToJson(this);
}
