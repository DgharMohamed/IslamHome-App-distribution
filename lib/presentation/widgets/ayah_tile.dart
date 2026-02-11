import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/data/models/quran_content_model.dart';
import 'package:islamic_library_flutter/data/models/surah_model.dart';
import 'package:islamic_library_flutter/data/services/quran_cdn_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';

class AyahTile extends ConsumerWidget {
  final Ayah arabicAyah;
  final Surah? surah; // Added to get surah number
  final Ayah? transAyah;
  final VoidCallback onDetailsTap;
  final VoidCallback onShareTap;
  final VoidCallback onBookmarkTap;
  final bool useImage;

  const AyahTile({
    super.key,
    required this.arabicAyah,
    this.surah,
    this.transAyah,
    required this.onDetailsTap,
    required this.onShareTap,
    required this.onBookmarkTap,
    this.useImage = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cdn = ref.watch(quranCdnServiceProvider);

    // Fallback search for surah number if not provided
    final surahNum = surah?.number ?? arabicAyah.surah?.number ?? 1;
    final imageUrl = cdn.getAyahImageUrl(
      surahNum,
      arabicAyah.numberInSurah ?? 1,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse Number Badge and Actions
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFD4AF37),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${arabicAyah.numberInSurah}',
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF2C1810),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              _buildAyahAction(Icons.menu_book_rounded, onDetailsTap),
              const SizedBox(width: 8),
              _buildAyahAction(Icons.share_rounded, onShareTap),
              const SizedBox(width: 8),
              _buildAyahAction(Icons.bookmark_border_rounded, onBookmarkTap),
            ],
          ),
          const SizedBox(height: 24),
          // Arabic Text or Image
          useImage
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    errorWidget: (context, url, error) => _buildArabicText(),
                    fit: BoxFit.contain,
                  ),
                )
              : _buildArabicText(),
          if (transAyah != null) ...[
            const SizedBox(height: 20),
            Text(
              transAyah!.text ?? '',
              textAlign: TextAlign.left,
              style: GoogleFonts.libreBaskerville(
                fontSize: 15,
                color: const Color(0xFF5D4037).withValues(alpha: 0.8),
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArabicText() {
    return Text(
      arabicAyah.text ?? '',
      textAlign: TextAlign.right,
      style: GoogleFonts.amiri(
        fontSize: 32,
        height: 2,
        color: const Color(0xFF2C1810),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildAyahAction(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFBF7).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF8B7355)),
      ),
    );
  }
}
