import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:islamic_library_flutter/data/models/khatma_plan.dart';
import 'package:islamic_library_flutter/data/models/khatma_completion.dart';

class KhatmaState {
  final KhatmaPlan? plan;
  final int currentPage;
  final List<KhatmaCompletion> completions;

  KhatmaState({this.plan, this.currentPage = 1, this.completions = const []});

  KhatmaState copyWith({
    KhatmaPlan? plan,
    int? currentPage,
    List<KhatmaCompletion>? completions,
  }) {
    return KhatmaState(
      plan: plan ?? this.plan,
      currentPage: currentPage ?? this.currentPage,
      completions: completions ?? this.completions,
    );
  }
}

class KhatmaNotifier extends Notifier<KhatmaState> {
  @override
  KhatmaState build() {
    final box = Hive.box('settings');
    final planJson = box.get('khatma_plan');
    final lastPage = box.get('last_mushaf_page', defaultValue: 1);

    KhatmaPlan? plan;
    if (planJson != null) {
      plan = KhatmaPlan.fromJson(Map<String, dynamic>.from(planJson));
    }

    final completionsJson = box.get('khatma_history', defaultValue: []);
    final completions = (completionsJson as List)
        .map((e) => KhatmaCompletion.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return KhatmaState(
      plan: plan,
      currentPage: lastPage,
      completions: completions,
    );
  }

  Future<void> setPlan(int days) async {
    final box = Hive.box('settings');
    final lastPage = box.get('last_mushaf_page', defaultValue: 1);

    final newPlan = KhatmaPlan(
      targetDays: days,
      startDate: DateTime.now(),
      startPage: lastPage,
    );

    await box.put('khatma_plan', newPlan.toJson());
    state = state.copyWith(plan: newPlan);
  }

  Future<void> updateProgress(int page) async {
    final box = Hive.box('settings');
    await box.put('last_mushaf_page', page);
    state = state.copyWith(currentPage: page);
  }

  Future<void> completeKhatma() async {
    final box = Hive.box('settings');
    final plan = state.plan;

    // Save to history if there was a plan or if they reached the end
    if (state.currentPage >= 604) {
      final completion = KhatmaCompletion(
        completionDate: DateTime.now(),
        startDate: plan?.startDate ?? DateTime.now(),
        totalDays: plan != null
            ? DateTime.now().difference(plan.startDate).inDays
            : 0,
      );

      final newHistory = [...state.completions, completion];
      await box.put(
        'khatma_history',
        newHistory.map((e) => e.toJson()).toList(),
      );
      state = state.copyWith(completions: newHistory);
    }

    // Reset progress and plan
    await box.delete('khatma_plan');
    await box.put('last_mushaf_page', 1);
    state = state.copyWith(plan: null, currentPage: 1);
  }

  Future<void> cancelPlan() async {
    final box = Hive.box('settings');
    await box.delete('khatma_plan');
    state = state.copyWith(plan: null);
  }

  // Business Logic
  int get pagesNeededToday {
    final plan = state.plan;
    if (plan == null) return 0;

    final now = DateTime.now();
    final expectedPage = plan.expectedTodayPage(now) + plan.pagesPerDay.toInt();
    final remaining = expectedPage - state.currentPage;

    return remaining > 0 ? remaining : 0;
  }

  double get overallProgress {
    return (state.currentPage / 604).clamp(0.0, 1.0);
  }
}

final khatmaProvider = NotifierProvider<KhatmaNotifier, KhatmaState>(() {
  return KhatmaNotifier();
});
