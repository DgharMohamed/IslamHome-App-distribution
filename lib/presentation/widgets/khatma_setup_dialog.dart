import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/presentation/providers/khatma_provider.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';

class KhatmaSetupDialog extends ConsumerStatefulWidget {
  const KhatmaSetupDialog({super.key});

  @override
  ConsumerState<KhatmaSetupDialog> createState() => _KhatmaSetupDialogState();
}

class _KhatmaSetupDialogState extends ConsumerState<KhatmaSetupDialog> {
  int _selectedDays = 30;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.khatmaPlannerTitle,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.khatmaPlannerSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.white60),
          ),
          const SizedBox(height: 32),

          // Days Selection
          _buildDaysSelector(),

          const SizedBox(height: 32),

          // Summary
          _buildSummary(l10n),

          const SizedBox(height: 32),

          // Start Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(khatmaProvider.notifier).setPlan(_selectedDays);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.05),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.startKhatma,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDaysSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDayBtn(7),
        const SizedBox(width: 8),
        _buildDayBtn(15),
        const SizedBox(width: 8),
        _buildDayBtn(30),
        const SizedBox(width: 8),
        _buildDayBtn(60),
      ],
    );
  }

  Widget _buildDayBtn(int days) {
    final isSelected = _selectedDays == days;
    return InkWell(
      onTap: () => setState(() => _selectedDays = days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Text(
          '$days ${AppLocalizations.of(context)!.days}',
          style: GoogleFonts.cairo(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(AppLocalizations l10n) {
    final pagesPerDay = (604 / _selectedDays).ceil();
    final pagesPerPrayer = (pagesPerDay / 5).ceil();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(l10n.pagesDaily, pagesPerDay.toString()),
          Container(width: 1, height: 40, color: Colors.white10),
          _buildSummaryItem(l10n.pagesPerPrayer, pagesPerPrayer.toString()),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.white54),
        ),
      ],
    );
  }
}
