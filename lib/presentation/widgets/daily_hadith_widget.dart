import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/presentation/providers/api_providers.dart';
import 'package:islamic_library_flutter/data/models/hadith_model.dart';
import 'package:islamic_library_flutter/presentation/widgets/glass_container.dart';

final dailyHadithProvider = FutureProvider<HadithModel?>((ref) async {
  final hadithService = ref.watch(hadithServiceProvider);
  return hadithService.getRandomHadith();
});

class DailyHadithWidget extends ConsumerWidget {
  const DailyHadithWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyHadith = ref.watch(dailyHadithProvider);

    return dailyHadith.when(
      data: (hadith) {
        if (hadith == null) return const SizedBox.shrink();

        return GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.1,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.format_quote_rounded,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hadith of the Day', // Replace with l10n if available
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                hadith.english ?? hadith.arab ?? '',
                style: GoogleFonts.libreBaskerville(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hadith.book ?? '',
                    style: GoogleFonts.cairo(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'No. ${hadith.number}',
                    style: GoogleFonts.montserrat(
                      color: Colors.white30,
                      fontSize: 12,
                    ),
                  ),
                ],
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
