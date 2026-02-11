import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_service/audio_service.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/data/models/quran_content_model.dart';
import 'package:islamic_library_flutter/data/services/audio_player_service.dart';
import 'package:islamic_library_flutter/presentation/providers/api_providers.dart';
import 'package:islamic_library_flutter/presentation/widgets/glass_container.dart';

class ReadingView extends ConsumerStatefulWidget {
  final AudioPlayerService audioService;
  final BoxConstraints constraints;

  const ReadingView({
    super.key,
    required this.audioService,
    required this.constraints,
  });

  @override
  ConsumerState<ReadingView> createState() => _ReadingViewState();
}

class _ReadingViewState extends ConsumerState<ReadingView> {
  Future<QuranSurahContent?>? _surahFuture;
  int? _currentSurahNum;

  @override
  Widget build(BuildContext context) {
    final state = widget.audioService.player.sequenceState;
    if (state?.currentSource == null) {
      return const SizedBox.shrink();
    }

    final currentSource = state!.currentSource!;
    final metadata = currentSource.tag as MediaItem;

    if (metadata.album != 'القرآن الكريم') {
      return const Center(
        child: Text(
          'وضع القراءة متاح للقرآن الكريم فقط',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Try to get surah number from extras first (more reliable)
    int? surahNum;
    if (metadata.extras != null &&
        metadata.extras!.containsKey('surahNumber')) {
      surahNum = metadata.extras!['surahNumber'] as int?;
    }

    // Fallback: try to extract from URL using regex
    if (surahNum == null) {
      final id = metadata.id;
      final match = RegExp(r'(\d+)\.mp3').firstMatch(id);
      surahNum = match != null ? int.tryParse(match.group(1)!) : null;
    }

    if (surahNum == null) {
      return const Center(child: Text('Surah identifier not found'));
    }

    // Refresh future if surah changed
    if (_surahFuture == null || _currentSurahNum != surahNum) {
      _currentSurahNum = surahNum;
      _surahFuture = ref
          .read(apiServiceProvider)
          .getQuranSurah(surahNum, edition: 'quran-uthmani');
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveHeight =
        (widget.constraints.maxWidth * 0.8) >
            (widget.constraints.maxHeight * 0.35)
        ? (widget.constraints.maxHeight * 0.35)
        : (widget.constraints.maxWidth * 0.8);

    return SizedBox(
      width: screenWidth * 0.9,
      height: responsiveHeight,
      child: GlassContainer(
        opacity: 0.1,
        blur: 25,
        borderRadius: 24,
        padding: EdgeInsets.zero,
        child: FutureBuilder<QuranSurahContent?>(
          future: _surahFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              );
            }
            if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                child: Text(
                  'خطأ في تحميل النص',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final surahContent = snapshot.data!;
            final ayahs = surahContent.ayahs ?? [];

            return Column(
              children: [
                // Surah Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      surahContent.name ?? '',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                // Text Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text.rich(
                        TextSpan(
                          children: ayahs.map((ayah) {
                            return TextSpan(
                              children: [
                                TextSpan(
                                  text: ayah.text,
                                  style: GoogleFonts.amiri(
                                    fontSize: 24,
                                    height: 2.2,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ﴿${ayah.numberInSurah}﴾ ',
                                  style: GoogleFonts.amiri(
                                    fontSize: 20,
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
