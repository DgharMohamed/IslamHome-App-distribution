import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/presentation/providers/api_providers.dart';
import 'package:islamic_library_flutter/data/models/adhkar_model.dart';
import 'package:islamic_library_flutter/data/models/hadith_model.dart';
import 'package:islamic_library_flutter/data/models/quran_content_model.dart';
import 'package:islamic_library_flutter/core/utils/quran_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';

enum SearchType { quran, hadith, adhkar }

class SearchResult {
  final String title;
  final String subtitle;
  final SearchType type;
  final dynamic data;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.data,
  });
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final quranService = ref.read(quranServiceProvider);
      final hadithService = ref.read(hadithServiceProvider);
      final azkarService = ref.read(azkarServiceProvider);

      final List<SearchResult> allResults = [];

      final l10n = AppLocalizations.of(ref.context)!;

      // 1. Search Quran
      final quranResults = await quranService.searchVerses(query);
      for (var ayah in quranResults) {
        allResults.add(
          SearchResult(
            title: ayah.text ?? '',
            subtitle: l10n.searchQuranSubtitle(
              ayah.surah?.name ?? '',
              ayah.numberInSurah ?? 0,
            ),
            type: SearchType.quran,
            data: ayah,
          ),
        );
      }

      // 2. Search Hadith
      final hadithResults = await hadithService.searchHadiths(query);
      for (var hadith in hadithResults) {
        allResults.add(
          SearchResult(
            title: hadith.english ?? hadith.arab ?? '',
            subtitle: l10n.searchHadithSubtitle(
              hadith.book ?? '',
              hadith.chapter ?? '',
            ),
            type: SearchType.hadith,
            data: hadith,
          ),
        );
      }

      // 3. Search Adhkar
      final adhkarResults = await azkarService.searchAdhkar(query);
      for (var dhikr in adhkarResults) {
        final isArabic =
            Localizations.localeOf(ref.context).languageCode == 'ar';
        allResults.add(
          SearchResult(
            title:
                (isArabic ? dhikr.zekrText : dhikr.english) ?? dhikr.zekrText,
            subtitle: l10n.searchAdhkarSubtitle(dhikr.category ?? ''),
            type: SearchType.adhkar,
            data: dhikr,
          ),
        );
      }

      setState(() {
        _results = allResults;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Global Search Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: GoogleFonts.cairo(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            hintStyle: GoogleFonts.cairo(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : _results.isEmpty && _searchController.text.isNotEmpty
          ? _buildNoResults(l10n)
          : _searchController.text.isEmpty
          ? _buildInitialState(l10n)
          : _buildResultsList(),
    );
  }

  Widget _buildInitialState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.exploreLibrary,
            style: GoogleFonts.cairo(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.searchDescription,
            style: GoogleFonts.cairo(color: Colors.white30),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noSearchResults,
            style: GoogleFonts.cairo(color: Colors.white54, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              result.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.amiri(
                fontSize: 18,
                color: Colors.white,
                height: 1.4,
              ),
              textAlign: QuranUtils.isArabic(result.title)
                  ? TextAlign.right
                  : TextAlign.left,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                result.subtitle,
                style: GoogleFonts.cairo(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () => _handleResultTap(result),
          ),
        );
      },
    );
  }

  void _handleResultTap(SearchResult result) {
    switch (result.type) {
      case SearchType.quran:
        final ayah = result.data as Ayah;
        context.push('/quran-text?surah=${ayah.surah?.number}');
        break;
      case SearchType.hadith:
        final _ = result.data as HadithModel;
        context.push('/hadith');
        break;
      case SearchType.adhkar:
        final _ = result.data as AdhkarModel;
        context.push('/azkar');
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
