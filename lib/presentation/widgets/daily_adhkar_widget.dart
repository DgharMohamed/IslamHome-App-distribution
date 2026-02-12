import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/presentation/providers/api_providers.dart';
import 'package:islamic_library_flutter/data/models/adhkar_model.dart';
import 'package:islamic_library_flutter/presentation/widgets/glass_container.dart';

final dailyAdhkarProvider = FutureProvider<AdhkarModel?>((ref) async {
  final azkarService = ref.watch(azkarServiceProvider);
  final all = await azkarService.loadAllAdhkar();
  if (all.isEmpty) return null;

  final categories = all.keys.toList();
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

  final category = categories[dayOfYear % categories.length];
  final list = all[category]!;
  if (list.isEmpty) return null;

  return list[dayOfYear % list.length];
});

class DailyAdhkarWidget extends ConsumerWidget {
  const DailyAdhkarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAdhkar = ref.watch(dailyAdhkarProvider);

    final locale = View.of(context).platformDispatcher.locale.languageCode;
    final isArabic = locale == 'ar';

    return dailyAdhkar.when(
      data: (dhikr) {
        if (dhikr == null) return const SizedBox.shrink();

        return GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.1,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isArabic ? 'ذكر اليوم' : 'Daily Adhkar',
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                (isArabic ? dhikr.zekrText : dhikr.english) ?? dhikr.zekrText,
                textAlign: TextAlign.center,
                style: isArabic
                    ? GoogleFonts.amiri(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.6,
                      )
                    : GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.5,
                      ),
              ),
              if (dhikr.description != null &&
                  dhikr.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  dhikr.description!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.white70),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  dhikr.category ?? 'Daily Dhikr',
                  style: GoogleFonts.cairo(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
