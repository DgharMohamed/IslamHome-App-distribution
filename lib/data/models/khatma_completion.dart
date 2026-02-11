import 'package:json_annotation/json_annotation.dart';

part 'khatma_completion.g.dart';

@JsonSerializable()
class KhatmaCompletion {
  final DateTime completionDate;
  final int totalDays;
  final DateTime startDate;

  KhatmaCompletion({
    required this.completionDate,
    required this.totalDays,
    required this.startDate,
  });

  factory KhatmaCompletion.fromJson(Map<String, dynamic> json) =>
      _$KhatmaCompletionFromJson(json);
  Map<String, dynamic> toJson() => _$KhatmaCompletionToJson(this);
}
