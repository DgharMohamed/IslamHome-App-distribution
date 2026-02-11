import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/presentation/providers/api_providers.dart';
import 'package:islamic_library_flutter/data/models/surah_model.dart';
import 'package:islamic_library_flutter/data/models/quran_content_model.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';

import 'package:islamic_library_flutter/core/utils/quran_utils.dart';
import 'package:islamic_library_flutter/core/utils/scaffold_utils.dart';
import 'package:islamic_library_flutter/presentation/widgets/ayah_tile.dart';
import 'package:islamic_library_flutter/presentation/widgets/premium_islamic_frame_painter.dart';
import 'package:islamic_library_flutter/presentation/widgets/mushaf_verse_marker.dart';
import 'package:islamic_library_flutter/presentation/providers/khatma_provider.dart';
import 'package:islamic_library_flutter/presentation/widgets/dua_khatm_dialog.dart';
import 'package:flutter/gestures.dart';

enum ReadingMode { list, flow }

class QuranTextScreen extends ConsumerStatefulWidget {
  final int? initialSurahNumber;
  const QuranTextScreen({super.key, this.initialSurahNumber});

  @override
  ConsumerState<QuranTextScreen> createState() => _QuranTextScreenState();
}

class _QuranTextScreenState extends ConsumerState<QuranTextScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialSurahNumber != null) {
      selectedSurahNumber = widget.initialSurahNumber!;
    }
  }

  int selectedSurahNumber = 1;
  String selectedTranslation = 'en.sahih'; // Default English translation
  String arabicEdition = 'quran-uthmani'; // Clear Uthmani text
  String selectedTafsir = 'ar.jalalayn';
  bool isTafsirLoading = false;
  final bool _useImages = false; // New state for image toggle

  // Search state
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Ayah> _searchResults = [];
  bool _isSearchLoading = false;
  ReadingMode _readingMode = ReadingMode.flow; // Default to Tarteel look

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearchLoading = true);
    try {
      final results = await ref.read(quranServiceProvider).searchVerses(query);
      setState(() {
        _searchResults = results;
        _isSearchLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearchLoading = false;
      });
    }
  }

  final Map<String, String> translationOptions = {
    'en.sahih': 'English (Sahih)',
    'fr.hamidullah': 'Français',
    'ur.ahmedali': 'اردو',
    'id.indonesian': 'Bahasa Indonesia',
    'tr.ates': 'Türkçe',
  };

  final Map<String, String> tafsirOptions = {
    'ar.jalalayn': 'تفسير الجلالين',
    'ar.muyassar': 'التفسير الميسر',
    'ar.tanweer': 'تفسير التنوير',
    'ar.waseet': 'الوسيط لطنطاوي',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surahsAsync = ref.watch(surahsProvider);

    return Scaffold(
      backgroundColor: _readingMode == ReadingMode.flow
          ? const Color(0xFFFDFBF7)
          : null,
      floatingActionButton: selectedSurahNumber == 114
          ? FloatingActionButton.extended(
              onPressed: () => _showDua(context),
              backgroundColor: const Color(0xFFD4AF37),
              elevation: 4,
              icon: const Icon(Icons.auto_awesome, color: Color(0xFF2C1810)),
              label: Text(
                'دعاء ختم القرآن',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C1810),
                ),
              ),
            )
          : null,
      body: Container(
        decoration: _readingMode == ReadingMode.flow
            ? null
            : BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/quran_paper_bg.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.9),
                    BlendMode.modulate,
                  ),
                ),
              ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: _readingMode == ReadingMode.flow ? 130.0 : 280.0,
              pinned: true,
              backgroundColor: const Color(0xFFF3E5AB), // Fallback beige
              leading: context.canPop()
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF5D4037),
                      ), // Brown
                      onPressed: () => context.pop(),
                    )
                  : Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(
                          Icons.menu_rounded,
                          size: 28,
                          color: Color(0xFF5D4037),
                        ),
                        onPressed: () => GlobalScaffoldService.openDrawer(),
                      ),
                    ),
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final settings = context
                      .dependOnInheritedWidgetOfExactType<
                        FlexibleSpaceBarSettings
                      >();
                  final deltaExtent = settings!.maxExtent - settings.minExtent;
                  final t =
                      (1.0 -
                              (settings.currentExtent - settings.minExtent) /
                                  deltaExtent)
                          .clamp(0.0, 1.0);

                  return FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: EdgeInsets.only(
                      bottom: 12 + (4 * (1 - t)),
                      left: 72 * t,
                      right: 72 * t,
                    ),
                    title: _readingMode == ReadingMode.flow
                        ? Opacity(
                            opacity: t > 0.7 ? 1.0 : 0.0,
                            child: surahsAsync.when(
                              data: (surahs) {
                                final currentSurah = surahs.firstWhere(
                                  (s) => s.number == selectedSurahNumber,
                                );
                                return Text(
                                  currentSurah.name ?? '',
                                  style: GoogleFonts.amiri(
                                    fontSize: 16 + (2 * (1 - t)),
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1B1B1B),
                                  ),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, _) => const SizedBox.shrink(),
                            ),
                          )
                        : null,
                    background: _readingMode == ReadingMode.flow
                        ? Container(
                            color: const Color(0xFFFDFBF7),
                            child: surahsAsync.when(
                              data: (surahs) {
                                final currentSurah = surahs.firstWhere(
                                  (s) => s.number == selectedSurahNumber,
                                );
                                return Opacity(
                                  opacity: (1.0 - t).clamp(0.0, 1.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 70),
                                      Text(
                                        currentSurah.name ?? '',
                                        style: GoogleFonts.amiri(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1B1B1B),
                                        ),
                                      ),
                                      FutureBuilder<QuranSurahContent?>(
                                        future: ref
                                            .read(quranServiceProvider)
                                            .getQuranSurah(selectedSurahNumber),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const SizedBox.shrink();
                                          }
                                          final ayah =
                                              snapshot.data!.ayahs!.first;
                                          return Text(
                                            'صفحة ${ayah.page ?? 1} | الجزء ${ayah.juz ?? 1} | الحزب ${((ayah.hizbQuarter ?? 1) / 4).ceil()}',
                                            style: GoogleFonts.amiri(
                                              fontSize: 11,
                                              color: const Color(0xFF8B7355),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, _) => const SizedBox.shrink(),
                            ),
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/quran_paper_bg.png',
                                fit: BoxFit.cover,
                                color: Colors.white.withValues(alpha: 0.8),
                                colorBlendMode: BlendMode.modulate,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 80,
                                  left: 24,
                                  right: 24,
                                  bottom: 20,
                                ),
                                child: CustomPaint(
                                  painter: PremiumIslamicFramePainter(
                                    color: const Color(
                                      0xFFD4AF37,
                                    ).withValues(alpha: 0.6),
                                  ),
                                  child: Center(
                                    child: surahsAsync.when(
                                      data: (surahs) {
                                        final currentSurah = surahs.firstWhere(
                                          (s) =>
                                              s.number == selectedSurahNumber,
                                        );
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'سورة',
                                              style: GoogleFonts.amiri(
                                                fontSize: 16,
                                                color: const Color(0xFF8B7355),
                                              ),
                                            ),
                                            Text(
                                              currentSurah.name
                                                      ?.replaceAll('سورة', '')
                                                      .trim() ??
                                                  '',
                                              style: GoogleFonts.amiri(
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF2C1810),
                                                height: 1.1,
                                              ),
                                            ),
                                            Text(
                                              '${currentSurah.englishName} • ${currentSurah.numberOfAyahs} Verses',
                                              style:
                                                  GoogleFonts.libreBaskerville(
                                                    fontSize: 12,
                                                    color: const Color(
                                                      0xFF8B7355,
                                                    ),
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                              style: GoogleFonts.amiri(
                                                fontSize: 22,
                                                color: const Color(0xFF2C1810),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      loading: () =>
                                          const CircularProgressIndicator(),
                                      error: (_, __) => const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search Quran...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Color(0xFF5D4037)),
                      onChanged: _performSearch,
                    )
                  : null,
              actions: [
                IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search_rounded,
                    color: const Color(0xFF5D4037),
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        _searchResults = [];
                      }
                    });
                  },
                ),
                surahsAsync.when(
                  data: (surahs) => IconButton(
                    icon: const Icon(
                      Icons.list_alt_rounded,
                      color: Color(0xFF5D4037),
                    ),
                    onPressed: () => _showSurahPicker(context, surahs),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                IconButton(
                  icon: Icon(
                    _readingMode == ReadingMode.flow
                        ? Icons.format_list_numbered_rtl_rounded
                        : Icons.auto_stories_rounded,
                    color: const Color(0xFF5D4037),
                  ),
                  tooltip: _readingMode == ReadingMode.flow
                      ? 'Switch to List View'
                      : 'Switch to Flow View',
                  onPressed: () {
                    setState(() {
                      _readingMode = _readingMode == ReadingMode.flow
                          ? ReadingMode.list
                          : ReadingMode.flow;
                    });
                  },
                ),
              ],
            ),

            // Search and Settings Bar
            if (_isSearching)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isSearchLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Text(
                          'Found ${_searchResults.length} results',
                          style: GoogleFonts.libreBaskerville(
                            fontSize: 14,
                            color: const Color(0xFF795548),
                          ),
                        ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF8B7355,
                          ).withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: _buildTranslationSelector(),
                            ),
                          ),
                          VerticalDivider(
                            color: const Color(
                              0xFFD4AF37,
                            ).withValues(alpha: 0.2),
                            width: 1,
                            indent: 12,
                            endIndent: 12,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: _buildTafsirSelector(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            if (_isSearching && _searchResults.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final ayah = _searchResults[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedSurahNumber = ayah.surah!.number!;
                          _isSearching = false;
                          _searchController.clear();
                          _searchResults = [];
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDFBF7).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFD4AF37,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              ayah.text ?? '',
                              textAlign: TextAlign.right,
                              style: GoogleFonts.amiri(
                                fontSize: 18,
                                color: const Color(0xFF2C1810),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${ayah.surah?.name} • Verse ${ayah.numberInSurah}',
                              style: GoogleFonts.libreBaskerville(
                                fontSize: 12,
                                color: const Color(0xFF8B7355),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: _searchResults.length),
              )
            else if (!_isSearching)
              // Ayah List
              FutureBuilder<List<QuranSurahContent?>>(
                future: Future.wait([
                  ref
                      .read(quranServiceProvider)
                      .getQuranSurah(
                        selectedSurahNumber,
                        edition: arabicEdition,
                      ),
                  ref
                      .read(quranServiceProvider)
                      .getQuranSurah(
                        selectedSurahNumber,
                        edition: selectedTranslation,
                      ),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError ||
                      snapshot.data == null ||
                      snapshot.data![0] == null) {
                    return SliverFillRemaining(
                      child: Center(child: Text(l10n.errorLoadingSurahs)),
                    );
                  }

                  final arabicContent = snapshot.data![0]!;
                  final translationContent = snapshot.data![1];

                  // Sync Khatma progress (only forward)
                  if (arabicContent.ayahs?.isNotEmpty == true) {
                    final firstPage = arabicContent.ayahs!.first.page;
                    if (firstPage != null &&
                        firstPage > ref.read(khatmaProvider).currentPage) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(khatmaProvider.notifier)
                            .updateProgress(firstPage);
                      });
                    }
                  }

                  if (_readingMode == ReadingMode.flow) {
                    return SliverToBoxAdapter(
                      child: _buildFlowView(arabicContent, translationContent),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final arabicAyah = arabicContent.ayahs![index];
                      final transAyah = translationContent?.ayahs?[index];

                      return AyahTile(
                        arabicAyah: arabicAyah,
                        transAyah: transAyah,
                        useImage: _useImages,
                        onDetailsTap: () => _showAyahDetails(arabicAyah),
                        onShareTap: () {},
                        onBookmarkTap: () {},
                      );
                    }, childCount: arabicContent.ayahs?.length ?? 0),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowView(
    QuranSurahContent arabicContent,
    QuranSurahContent? translationContent,
  ) {
    final List<Widget> children = [];
    final List<InlineSpan> spans = [];

    int? currentJuz;
    int? currentHizb;

    for (int i = 0; i < (arabicContent.ayahs?.length ?? 0); i++) {
      final ayah = arabicContent.ayahs![i];
      final trans = translationContent?.ayahs?[i];

      // Check for Juz/Hizb change
      if (ayah.juz != null && ayah.juz != currentJuz) {
        if (spans.isNotEmpty) {
          children.add(
            Directionality(
              textDirection: TextDirection.rtl,
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(children: List.from(spans)),
              ),
            ),
          );
          spans.clear();
        }
        currentJuz = ayah.juz;
        currentHizb = ayah.hizb;
        children.add(_buildSectionMarker('الجزء ${ayah.juz}', isMain: true));
      } else if (ayah.hizb != null && ayah.hizb != currentHizb) {
        if (spans.isNotEmpty) {
          children.add(
            Directionality(
              textDirection: TextDirection.rtl,
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(children: List.from(spans)),
              ),
            ),
          );
          spans.clear();
        }
        currentHizb = ayah.hizb;
        children.add(_buildSectionMarker('الحزب ${ayah.hizb}'));
      }

      // Arabic Text
      spans.add(
        TextSpan(
          text: '${ayah.text} ',
          recognizer: TapGestureRecognizer()
            ..onTap = () => _showAyahDetails(ayah, translation: trans),
          style: GoogleFonts.amiri(
            fontSize: 28,
            height: 2.2,
            color: const Color(0xFF2C1810),
            fontWeight: FontWeight.w400,
          ),
        ),
      );

      // Verse Marker
      final isSajdah =
          ayah.sajda != null &&
          (ayah.sajda == 1 ||
              ayah.sajda == true ||
              (ayah.sajda is Map && ayah.sajda.isNotEmpty));

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () => _showAyahDetails(ayah, translation: trans),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (isSajdah)
                    Positioned(
                      top: -14,
                      child: Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  Container(
                    width: 32,
                    height: 32,
                    padding: const EdgeInsets.all(4),
                    child: CustomPaint(
                      painter: MushafVerseMarkerPainter(
                        color: const Color(0xFFD4AF37),
                      ),
                      child: Center(
                        child: Text(
                          _toArabicNumbers(ayah.numberInSurah ?? 0),
                          style: GoogleFonts.amiri(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C1810),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (spans.isNotEmpty) {
      children.add(
        Directionality(
          textDirection: TextDirection.rtl,
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(children: spans),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(children: children),
    );
  }

  Widget _buildSectionMarker(String title, {bool isMain = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Divider(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
          ),
          InkWell(
            onTap: isMain ? _showJuzPicker : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B7355).withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMain ? Icons.auto_stories : Icons.menu_book,
                    size: 16,
                    color: const Color(0xFFBC9A27),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: GoogleFonts.amiri(
                      fontSize: isMain ? 18 : 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4E342E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _showJuzPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'اختر الجزء',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      final juzNumber = index + 1;
                      return InkWell(
                        onTap: () {
                          final mapping = QuranUtils.juzMapping[juzNumber];
                          if (mapping != null) {
                            setState(() {
                              selectedSurahNumber = mapping['surah']!;
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFDFBF7,
                            ).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFFD4AF37,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'الجزء $juzNumber',
                              style: GoogleFonts.amiri(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4E342E),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTranslationSelector() {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: _showTranslationPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.language_rounded,
              size: 16,
              color: Color(0xFFD4AF37),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                translationOptions[selectedTranslation] ??
                    l10n.selectTranslation,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C1810),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTafsirSelector() {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: _showTafsirPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book_rounded,
              size: 16,
              color: Color(0xFFD4AF37),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                tafsirOptions[selectedTafsir] ?? l10n.selectTafsir,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C1810),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTranslationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.chooseTranslation,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...translationOptions.entries.map((entry) {
                return ListTile(
                  title: Text(entry.value),
                  trailing: selectedTranslation == entry.key
                      ? const Icon(Icons.check, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    setState(() => selectedTranslation = entry.key);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showTafsirPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.chooseTafsir,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...tafsirOptions.entries.map((entry) {
                return ListTile(
                  title: Text(
                    entry.value,
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                  trailing: selectedTafsir == entry.key
                      ? const Icon(Icons.check, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    setState(() => selectedTafsir = entry.key);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showSurahPicker(BuildContext context, List<Surah> surahs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            final l10n = AppLocalizations.of(context)!;
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      l10n.chooseSurah,
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: surahs.length,
                      itemBuilder: (context, index) {
                        final surah = surahs[index];
                        return ListTile(
                          leading: Text(
                            '${surah.number}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          title: Text(
                            surah.name ?? '',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(surah.englishName ?? ''),
                          onTap: () {
                            setState(() => selectedSurahNumber = surah.number!);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAyahDetails(Ayah ayah, {Ayah? translation}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Text(
                              l10n.verseN(ayah.numberInSurah!),
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_rounded, size: 20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Translation Section
                    if (translation != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${translationOptions[selectedTranslation]}:',
                            style: GoogleFonts.cairo(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        translation.text ?? '',
                        style: GoogleFonts.libreBaskerville(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 24),
                    ],
                    // Tafsir Section
                    FutureBuilder<String?>(
                      future: ref
                          .read(apiServiceProvider)
                          .getAyahTafsir(
                            selectedSurahNumber,
                            ayah.numberInSurah!,
                            edition: selectedTafsir,
                          ),
                      builder: (context, snapshot) {
                        final l10n = AppLocalizations.of(context)!;
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                            ),
                          );
                        }
                        return Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.menu_book_rounded,
                                  color: AppTheme.primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${tafsirOptions[selectedTafsir]}:',
                                  style: GoogleFonts.cairo(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              snapshot.data ?? l10n.noTafsirAvailable,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
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

  String _toArabicNumbers(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String s = number.toString();
    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(english[i], arabic[i]);
    }
    return s;
  }
}
