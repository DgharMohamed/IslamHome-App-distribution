import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_library_flutter/presentation/providers/api_providers.dart';
import 'package:islamic_library_flutter/presentation/widgets/aurora_background.dart';
import 'package:islamic_library_flutter/presentation/widgets/glass_container.dart';
import 'package:islamic_library_flutter/data/models/video_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:islamic_library_flutter/data/services/audio_player_service.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  int? activeTypeId; // Default to All
  String searchQuery = '';
  bool _isProcessing = false;

  Future<void> _playEpisode(
    VideoModel video,
    int index,
    List<VideoModel> playlist,
  ) async {
    if (video.url == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final isYoutube =
          video.url!.contains('youtube.com') || video.url!.contains('youtu.be');

      final audioService = ref.read(audioPlayerServiceProvider);
      if (audioService == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('خدمة الصوت لم تكتمل بعد، يرجى المحاولة مرة أخرى'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (isYoutube) {
        await audioService.playYoutubeAudio(
          video.url!,
          title: video.title,
          artist: video.reciter,
          thumbUrl: video.thumbUrl,
        );
      } else {
        // Create a playlist of only direct URLs (excluding YouTube/empty URLs)
        final List<VideoModel> directUrlPlaylist = playlist.where((v) {
          final url = v.url?.toLowerCase() ?? '';
          return url.isNotEmpty &&
              !url.contains('youtube.com') &&
              !url.contains('youtu.be');
        }).toList();

        final int newIndex = directUrlPlaylist.indexWhere(
          (v) => v.id == video.id,
        );

        if (newIndex != -1) {
          await audioService.playVideoPlaylist(
            videos: directUrlPlaylist,
            initialIndex: newIndex,
          );
        } else {
          // Absolute fallback
          await audioService.playUrl(
            video.url!,
            title: video.title,
            artist: video.reciter,
            thumbUrl: video.thumbUrl,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تشغيل المقطع كصوت في الخلفية'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error playing episode: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تشغيل المقطع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final videosAsync = ref.watch(videosProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: AuroraBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 180.0,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Icon(
                            Icons.history_edu_rounded,
                            size: 40,
                            color: AppTheme.primaryColor.withValues(alpha: 0.8),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.videoLibraryTitle,
                            style: GoogleFonts.cairo(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
                onPressed: () => context.pop(),
              ),
            ),

            videosAsync.when(
              data: (videos) {
                final reciters = videos
                    .map((v) => v.reciter)
                    .where((r) => r != null)
                    .toSet()
                    .toList();

                final filteredVideos = videos.where((v) {
                  // Only include videos with URLs to avoid crashes
                  if (v.url == null) return false;

                  final matchesReciter =
                      activeTypeId == null ||
                      (reciters.isNotEmpty &&
                          activeTypeId! <= reciters.length &&
                          v.reciter == reciters[activeTypeId! - 1]);

                  final matchesSearch =
                      v.title?.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ??
                      true;
                  return matchesReciter && matchesSearch;
                }).toList();

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: Column(
                          children: [
                            // Glass Search Bar
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  child: TextField(
                                    onChanged: (value) =>
                                        setState(() => searchQuery = value),
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: l10n.searchVideoHint,
                                      hintStyle: GoogleFonts.cairo(
                                        color: Colors.white38,
                                        fontSize: 14,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search_rounded,
                                        color: AppTheme.primaryColor,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Filter Pills
                            if (reciters.isNotEmpty)
                              SizedBox(
                                height: 42,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: reciters.length + 1,
                                  itemBuilder: (context, i) {
                                    final bool isActive =
                                        (i == 0 && activeTypeId == null) ||
                                        (i > 0 && activeTypeId == i);

                                    return _buildFilterPill(
                                      i == 0 ? l10n.all : reciters[i - 1]!,
                                      isActive,
                                      () => setState(
                                        () => activeTypeId = i == 0 ? null : i,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    final video = filteredVideos[index - 1];
                    return _buildEpisodeCard(
                      context,
                      video,
                      index,
                      filteredVideos,
                    );
                  }, childCount: filteredVideos.length + 1),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    l10n.errorOccurred(err.toString()),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, bool isActive, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isActive
                  ? AppTheme.primaryColor
                  : Colors.white.withValues(alpha: 0.1),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                color: isActive ? Colors.black : Colors.white70,
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeCard(
    BuildContext context,
    VideoModel video,
    int index,
    List<VideoModel> playlist,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: InkWell(
        onTap: () => _playEpisode(video, index - 1, playlist),
        borderRadius: BorderRadius.circular(24),
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail Box
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Reciter Image
                          _getReciterImage(video.reciter),
                          // Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(18),
                        ),
                      ),
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title ?? '',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          video.reciter ?? '',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.headphones_rounded,
                            size: 12,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppLocalizations.of(context)!.nowListening,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getReciterImage(String? reciterName) {
    // Map of reciter names to their image assets or network URLs
    final Map<String, String> reciterImages = {
      'بدر المشاري': 'https://i.ytimg.com/vi/qJwecTUy8PY/maxresdefault.jpg',
      'نواف السالم':
          'https://pbs.twimg.com/profile_images/1542862587086729216/zYQqXqZJ_400x400.jpg',
    };

    final imageUrl = reciterImages[reciterName];

    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildReciterPlaceholder(reciterName),
      );
    }

    return _buildReciterPlaceholder(reciterName);
  }

  Widget _buildReciterPlaceholder(String? reciterName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.3),
            AppTheme.primaryColor.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_rounded,
              size: 40,
              color: AppTheme.primaryColor,
            ),
            if (reciterName != null) ...[
              const SizedBox(height: 4),
              Text(
                reciterName.split(' ').first,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
