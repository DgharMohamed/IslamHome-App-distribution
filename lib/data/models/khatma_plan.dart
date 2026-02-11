import 'package:json_annotation/json_annotation.dart';

part 'khatma_plan.g.dart';

@JsonSerializable()
class KhatmaPlan {
  final int targetDays;
  final DateTime startDate;
  final int startPage;
  final bool isCompleted;

  KhatmaPlan({
    required this.targetDays,
    required this.startDate,
    required this.startPage,
    this.isCompleted = false,
  });

  factory KhatmaPlan.fromJson(Map<String, dynamic> json) =>
      _$KhatmaPlanFromJson(json);
  Map<String, dynamic> toJson() => _$KhatmaPlanToJson(this);

  // Constants
  static const int totalPages = 604;

  // Calculations
  int get remainingPages => totalPages - startPage;

  double get pagesPerDay => remainingPages / targetDays;

  double get pagesPerPrayer => pagesPerDay / 5;

  int daysPassed(DateTime now) {
    return now.difference(startDate).inDays;
  }

  int expectedTodayPage(DateTime now) {
    int days = daysPassed(now);
    return (startPage + (days * pagesPerDay)).toInt();
  }
}
