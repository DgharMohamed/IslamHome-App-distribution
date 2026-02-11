import 'package:json_annotation/json_annotation.dart';

part 'reciter_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Reciter {
  final int? id;
  final String? name;
  final String? letter;
  @JsonKey(name: 'moshaf')
  final List<Moshaf>? moshaf;

  Reciter({this.id, this.name, this.letter, this.moshaf});

  factory Reciter.fromJson(Map<String, dynamic> json) =>
      _$ReciterFromJson(json);
  Map<String, dynamic> toJson() => _$ReciterToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Moshaf {
  final int? id;
  final String? name;
  final String? server;
  @JsonKey(name: 'surah_total')
  final int? surahTotal;
  @JsonKey(name: 'moshaf_type')
  final int? moshafType;
  @JsonKey(name: 'surah_list')
  final String? surahList;

  Moshaf({
    this.id,
    this.name,
    this.server,
    this.surahTotal,
    this.moshafType,
    this.surahList,
  });

  factory Moshaf.fromJson(Map<String, dynamic> json) => _$MoshafFromJson(json);
  Map<String, dynamic> toJson() => _$MoshafToJson(this);
}
