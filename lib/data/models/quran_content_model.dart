import 'package:json_annotation/json_annotation.dart';
import 'package:islamic_library_flutter/data/models/surah_model.dart';

part 'quran_content_model.g.dart';

// Backward compatibility
typedef QuranSurahContent = QuranContent;

@JsonSerializable()
class QuranEdition {
  final String? identifier;
  final String? language;
  final String? name;
  final String? englishName;
  final String? format;
  final String? type;

  QuranEdition({
    this.identifier,
    this.language,
    this.name,
    this.englishName,
    this.format,
    this.type,
  });

  factory QuranEdition.fromJson(Map<String, dynamic> json) =>
      _$QuranEditionFromJson(json);
  Map<String, dynamic> toJson() => _$QuranEditionToJson(this);
}

@JsonSerializable()
class QuranContent {
  final int? number;
  final String? name; // For surah-based responses
  final List<Ayah>? ayahs;
  final Map<int, Surah>? surahs; // For page-based responses

  QuranContent({this.number, this.name, this.ayahs, this.surahs});

  factory QuranContent.fromJson(Map<String, dynamic> json) =>
      _$QuranContentFromJson(json);
  Map<String, dynamic> toJson() => _$QuranContentToJson(this);
}

@JsonSerializable()
class Ayah {
  final int? number;
  final String? text;
  final int? numberInSurah;
  final int? juz;
  final int? manzil;
  final int? page;
  final int? ruku;
  final int? hizbQuarter;
  final dynamic sajda;
  final int? hizb;
  final int? rubu;
  final Surah? surah; // Included in some responses

  Ayah({
    this.number,
    this.text,
    this.numberInSurah,
    this.juz,
    this.manzil,
    this.page,
    this.ruku,
    this.hizbQuarter,
    this.sajda,
    this.hizb,
    this.rubu,
    this.surah,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) => _$AyahFromJson(json);
  Map<String, dynamic> toJson() => _$AyahToJson(this);
}
