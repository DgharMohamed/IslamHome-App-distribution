import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/presentation/providers/khatma_provider.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:islamic_library_flutter/core/utils/quran_utils.dart';
import 'package:islamic_library_flutter/presentation/widgets/khatma_setup_dialog.dart';
import 'package:islamic_library_flutter/presentation/widgets/dua_khatm_dialog.dart';
import 'package:go_router/go_router.dart';

class SmartKhatmaWidget extends ConsumerWidget {
  const SmartKhatmaWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(khatmaProvider);
    final notifier = ref.read(khatmaProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    final plan = state.plan;
    final progress = notifier.overallProgress;
    final surahName = QuranUtils.getSurahNameByPage(state.currentPage);
    final juzNumber = QuranUtils.getJuzByPage(state.currentPage);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B7355).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Decorative background pattern
            Positioned(
              left: -30,
              top: -30,
              child: Opacity(
                opacity: 0.03,
                child: Icon(
                  Icons.mosque_rounded,
                  size: 150,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.auto_stories_rounded,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.continueYourKhatma,
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF2C1810),
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                l10n.juzAndSurah(
                                  juzNumber.toString(),
                                  surahName,
                                ),
                                style: GoogleFonts.cairo(
                                  color: AppTheme.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.05,
                          ),
                          color: AppTheme.primaryColor,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (plan == null)
                    _buildSmartSuggestions(context, ref, l10n)
                  else
                    _buildPlanStatus(context, state, l10n, notifier),

                  if (state.completions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildKhatmaHistory(state),
                  ],

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (progress >= 1.0) {
                          _showDua(context);
                        } else {
                          final surahNum = QuranUtils.getSurahNumberByPage(
                            state.currentPage,
                          );
                          context.push('/quran-text?surah=$surahNum');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: progress >= 1.0
                            ? const Color(0xFFD4AF37)
                            : AppTheme.primaryColor,
                        foregroundColor: progress >= 1.0
                            ? const Color(0xFF2C1810)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        progress >= 1.0 ? l10n.duaKhatm : l10n.continueReading,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartSuggestions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.smartSuggestionsForNewPlan,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSuggestionCard(
                icon: Icons.flash_on_rounded,
                title: l10n.khatmaInMonth,
                subtitle: l10n.oneJuzDaily,
                onTap: () => ref.read(khatmaProvider.notifier).setPlan(30),
              ),
              const SizedBox(width: 10),
              _buildSuggestionCard(
                icon: Icons.calendar_month_rounded,
                title: l10n.khatmaInTwoMonths,
                subtitle: l10n.fifteenPagesDaily,
                onTap: () => ref.read(khatmaProvider.notifier).setPlan(60),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryColor),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(fontSize: 10, color: Colors.black45),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanStatus(
    BuildContext context,
    KhatmaState state,
    AppLocalizations l10n,
    KhatmaNotifier notifier,
  ) {
    final remaining = notifier.pagesNeededToday;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: remaining > 0
                ? Colors.orange.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                remaining > 0
                    ? Icons.trending_up_rounded
                    : Icons.task_alt_rounded,
                color: remaining > 0 ? Colors.orange : Colors.green,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                remaining > 0
                    ? l10n.pagesRemainingToday(remaining.toString())
                    : l10n.onTrack,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: remaining > 0 ? Colors.orange[900] : Colors.green[900],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => _showHistory(context, state),
              icon: const Icon(
                Icons.history_rounded,
                color: Colors.black26,
                size: 22,
              ),
              tooltip: l10n.khatmaHistory,
            ),
            IconButton(
              onPressed: () => _showSetup(context),
              icon: const Icon(
                Icons.settings_suggest_rounded,
                color: Colors.black26,
                size: 22,
              ),
              tooltip: l10n.khatmaSettings,
            ),
          ],
        ),
      ],
    );
  }

  void _showHistory(BuildContext context, KhatmaState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFFFDFBF7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'سجل الختمات السابقة',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C1810),
              ),
            ),
            const SizedBox(height: 24),
            if (state.completions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_edu_rounded,
                      size: 64,
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا يوجد ختمات مسجلة بعد',
                      style: GoogleFonts.cairo(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: state.completions.reversed.map((completion) {
                      final dateStr =
                          '${completion.completionDate.day}/${completion.completionDate.month}/${completion.completionDate.year}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFFD4AF37,
                            ).withValues(alpha: 0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ختمة مباركة',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  dateStr,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${completion.totalDays} يوم',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSetup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const KhatmaSetupDialog(),
    );
  }

  void _showDua(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const DuaKhatmDialog(),
    );
  }

  Widget _buildKhatmaHistory(KhatmaState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              size: 16,
              color: Color(0xFFD4AF37),
            ),
            const SizedBox(width: 8),
            Text(
              'إنجازات سابقة:',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...state.completions.reversed.take(3).map((completion) {
          final dateStr =
              '${completion.completionDate.day}/${completion.completionDate.month}/${completion.completionDate.year}';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تم الختم بحمد الله',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                    Text(
                      dateStr,
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${completion.totalDays} يوم',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
