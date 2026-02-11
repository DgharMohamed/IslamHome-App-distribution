import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/data/models/reciter_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/presentation/providers/favorites_provider.dart';
import 'package:islamic_library_flutter/presentation/providers/api_providers.dart';
import 'package:islamic_library_flutter/data/services/audio_player_service.dart';
import 'package:islamic_library_flutter/presentation/widgets/surah_tile_widget.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:islamic_library_flutter/presentation/widgets/glass_container.dart';
import 'package:islamic_library_flutter/presentation/widgets/download_button.dart';
import 'package:islamic_library_flutter/presentation/providers/download_state.dart';
import 'package:islamic_library_flutter/presentation/screens/downloads_screen.dart';
import 'package:islamic_library_flutter/data/models/surah_model.dart';
import 'package:islamic_library_flutter/data/models/playlist_model.dart';

class ReciterScreen extends ConsumerStatefulWidget {
  final Reciter reciter;

  const ReciterScreen({super.key, required this.reciter});

  @override
  ConsumerState<ReciterScreen> createState() => _ReciterScreenState();
}

class _ReciterScreenState extends ConsumerState<ReciterScreen> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final audioService = ref.watch(audioPlayerServiceProvider);

    debugPrint('🎵 ReciterScreen: Building for ${widget.reciter.name}');

    // If audio service not initialized, show loading indicator
    if (audioService == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(title: Text(widget.reciter.name ?? l10n.reciterLabel)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    ref.watch(favoritesProvider);
    final isFavorite = ref
        .read(favoritesProvider.notifier)
        .isFavoriteReciter(widget.reciter.id.toString());

    final moshaf = widget.reciter.moshaf?.isNotEmpty == true
        ? widget.reciter.moshaf!.first
        : null;
    final surahListRaw = moshaf?.surahList?.split(',') ?? [];

    // Error state if no moshaf
    if (moshaf == null || surahListRaw.isEmpty) {
      return _buildErrorScreen(l10n, 'لا توجد سور متاحة للقارئ');
    }

    // Watch surahsProvider ONCE outside the list
    final surahsAsync = ref.watch(surahsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header
            _buildHeader(context, l10n, isFavorite),

            // Reciter Info Card
            _buildReciterInfo(moshaf),

            // Reciter Actions (Download All)
            surahsAsync.maybeWhen(
              data: (surahs) => _buildReciterActions(moshaf, surahs),
              orElse: () => const SizedBox.shrink(),
            ),

            // Search Bar
            _buildSearchBar(l10n),

            // Surahs List
            Expanded(
              child: StreamBuilder<MediaItem?>(
                stream: audioService.mediaItemStream,
                builder: (context, snapshot) {
                  final activeMedia = snapshot.data;
                  final activeReciter = activeMedia?.artist;

                  return surahsAsync.when(
                    data: (surahs) => _buildSurahsList(
                      surahListRaw,
                      surahs,
                      moshaf,
                      activeMedia,
                      activeReciter,
                      audioService,
                      l10n,
                    ),
                    loading: () => _buildLoadingState(),
                    error: (err, _) => _buildErrorState(err),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isFavorite,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.backgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              onPressed: () => context.pop(),
            ),
          ),

          // In _buildHeader:
          const SizedBox(width: 16),

          // Downloads Button (New)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.download_done_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DownloadsScreen()),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              widget.reciter.name ?? '',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Favorite Button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isFavorite
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFavorite
                    ? Colors.red.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white54,
                size: 20,
              ),
              onPressed: () => ref
                  .read(favoritesProvider.notifier)
                  .toggleFavoriteReciter(widget.reciter),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReciterInfo(dynamic moshaf) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassContainer(
        borderRadius: 20,
        opacity: 0.05,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 32,
                color: Colors.white38,
              ),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moshaf.name ?? 'المصحف',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${moshaf.surahList?.split(',').length ?? 0} سورة',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.white54,
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

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GlassContainer(
        borderRadius: 16,
        opacity: 0.05,
        child: TextField(
          controller: _searchController,
          onChanged: (value) =>
              setState(() => searchQuery = value.toLowerCase()),
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: l10n.searchSurah,
            hintStyle: GoogleFonts.cairo(color: Colors.white38),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahsList(
    List<String> surahListRaw,
    List<dynamic> surahs,
    dynamic moshaf,
    MediaItem? activeMedia,
    String? activeReciter,
    dynamic audioService,
    AppLocalizations l10n,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: surahListRaw.length,
      itemBuilder: (context, index) {
        final surahId = surahListRaw[index];

        // Get surah name and object
        String surahName = l10n.surahNumber(surahId);
        Surah? surahObj;
        try {
          surahObj =
              surahs.firstWhere((s) => s.number.toString() == surahId)
                  as Surah; // Ensure cast
          surahName = surahObj.name ?? surahName;
        } catch (_) {}

        // Filter by search
        if (searchQuery.isNotEmpty &&
            !surahName.toLowerCase().contains(searchQuery)) {
          return const SizedBox.shrink();
        }

        // Check if playing
        final isPlaying =
            activeReciter == widget.reciter.name &&
            activeMedia?.extras?['surahNumber']?.toString() == surahId;

        // Check if favorite
        ref.watch(favoritesProvider);
        final isFavoriteSurah = ref
            .read(favoritesProvider.notifier)
            .isFavoriteSurah(int.parse(surahId), widget.reciter.id.toString());

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SurahTileWidget(
            surahId: surahId,
            surahName: surahName,
            subtitle: l10n.recitationOf(moshaf.name ?? ''),
            isFavorite: isFavoriteSurah,
            isPlaying: isPlaying,
            onFavorite: () => _handleFavorite(surahId, surahs, moshaf),
            onPlaylistAdd: () => _showPlaylistSelector(surahObj, moshaf),
            onDownload: () {}, // Handled by widget
            onPlay: () => _handlePlay(
              surahListRaw,
              surahs,
              moshaf,
              index,
              audioService,
              l10n,
            ),
            downloadWidget: surahObj != null
                ? DownloadButton(
                    reciter: widget.reciter,
                    moshaf: moshaf,
                    surah: surahObj,
                    color: Colors.white38,
                  )
                : null,
          ),
        );
      },
    );
  }

  void _showPlaylistSelector(Surah? surah, dynamic moshaf) {
    if (surah == null) return;

    final favorites = ref.read(favoritesProvider);
    final playlists = (favorites['playlists'] as List)
        .map((p) => Playlist.fromJson(p))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'إضافة إلى قائمة تشغيل',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            if (playlists.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'لا توجد قوائم تشغيل. أنشئ واحدة من قسم المفضلات.',
                  style: GoogleFonts.cairo(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      leading: Text(
                        playlist.icon ?? '⭐',
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        playlist.name,
                        style: GoogleFonts.cairo(color: Colors.white),
                      ),
                      onTap: () {
                        String? url;
                        if (moshaf.server != null) {
                          final paddedId = surah.number.toString().padLeft(
                            3,
                            '0',
                          );
                          url = '${moshaf.server}$paddedId.mp3';
                        }
                        if (url != null) {
                          ref
                              .read(favoritesProvider.notifier)
                              .addToPlaylist(
                                playlist.id,
                                surah,
                                widget.reciter,
                                url,
                              );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تمت الإضافة إلى ${playlist.name}',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleFavorite(String surahId, List<dynamic> surahs, dynamic moshaf) {
    try {
      final surah = surahs.firstWhere((s) => s.number.toString() == surahId);
      String? url;
      if (moshaf.server != null) {
        final paddedId = surahId.padLeft(3, '0');
        url = '${moshaf.server}$paddedId.mp3';
      }
      ref
          .read(favoritesProvider.notifier)
          .toggleFavoriteSurah(surah, widget.reciter, url: url);
    } catch (_) {}
  }

  Widget _buildReciterActions(dynamic moshaf, List<dynamic>? surahs) {
    if (moshaf == null || surahs == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (surahs.isEmpty) return;
                // Filter surahs that are in the moshaf list
                final moshafSurahIds = moshaf.surahList?.split(',') ?? [];
                final surahsToDownload = surahs
                    .where((s) => moshafSurahIds.contains(s.number.toString()))
                    .cast<Surah>()
                    .toList();

                ref
                    .read(downloadProvider.notifier)
                    .downloadAll(
                      reciter: widget.reciter,
                      moshaf: moshaf,
                      surahs: surahsToDownload,
                    );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم بدء تحميل الكل إلى القائمة'),
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('تحميل الكل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePlay(
    List<String> surahListRaw,
    List<dynamic> surahs,
    dynamic moshaf,
    int index,
    dynamic audioService,
    AppLocalizations l10n,
  ) async {
    // Validate that we have a server URL
    if (moshaf.server == null || moshaf.server.toString().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: لا يوجد رابط خادم للقارئ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('🎵 ReciterScreen: Using server URL: ${moshaf.server}');
    debugPrint('🎵 ReciterScreen: Reciter: ${widget.reciter.name}');

    final sources = surahListRaw.map((id) {
      final surahNum = int.parse(id);

      // Use the actual moshaf server URL from the API
      final paddedId = id.padLeft(3, '0');
      final url = '${moshaf.server}$paddedId.mp3';

      String name = l10n.surahNumber(id);
      try {
        name = surahs.firstWhere((s) => s.number.toString() == id).name ?? name;
      } catch (_) {}

      debugPrint('🎵 ReciterScreen: Audio URL for $name: $url');

      return AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: url,
          title: name,
          artist: widget.reciter.name,
          artUri: Uri.parse(
            'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?q=80&w=500',
          ),
          extras: {'surahNumber': surahNum},
        ),
      );
    }).toList();

    try {
      await audioService.setPlaylist(sources: sources, initialIndex: index);
    } catch (e) {
      debugPrint('🎵 ReciterScreen: setPlaylist error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تشغيل القائمة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.primaryColor),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              err.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(AppLocalizations l10n, String message) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.withValues(alpha: 0.7),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
