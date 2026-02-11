import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/presentation/widgets/glass_container.dart';

class SurahTileWidget extends StatelessWidget {
  final String surahId;
  final String surahName;
  final String subtitle;
  final VoidCallback onPlay;
  final VoidCallback onDownload;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback? onPlaylistAdd;
  final bool isPlaying;
  final bool isDownloaded;
  final Widget? downloadWidget;

  const SurahTileWidget({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.subtitle,
    required this.onPlay,
    required this.onDownload,
    required this.onFavorite,
    this.onPlaylistAdd,
    this.isPlaying = false,
    this.isDownloaded = false,
    this.isFavorite = false,
    this.downloadWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 16,
      opacity: isPlaying ? 0.1 : 0.05,
      borderColor: isPlaying
          ? AppTheme.primaryColor.withValues(alpha: 0.3)
          : Colors.white.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onPlay,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Number Badge or Playing Indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isPlaying
                      ? LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.2),
                            AppTheme.primaryColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isPlaying
                      ? null
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPlaying
                        ? AppTheme.primaryColor.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                alignment: Alignment.center,
                child: isPlaying
                    ? Icon(
                        Icons.equalizer_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      )
                    : Text(
                        surahId,
                        style: GoogleFonts.montserrat(
                          color: Colors.white54,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 16),

              // Surah Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surahName,
                      style: GoogleFonts.cairo(
                        color: isPlaying ? AppTheme.primaryColor : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Favorite Button
                  _buildActionButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white38,
                    onPressed: onFavorite,
                  ),
                  const SizedBox(width: 4),

                  // Playlist Add Button
                  if (onPlaylistAdd != null) ...[
                    _buildActionButton(
                      icon: Icons.playlist_add,
                      color: Colors.white38,
                      onPressed: onPlaylistAdd,
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Download Button
                  if (downloadWidget != null) ...[
                    downloadWidget!,
                  ] else
                    _buildActionButton(
                      icon: isDownloaded
                          ? Icons.check_circle
                          : Icons.download_outlined,
                      color: isDownloaded
                          ? AppTheme.primaryColor
                          : Colors.white38,
                      onPressed: isDownloaded ? null : onDownload,
                    ),
                  const SizedBox(width: 8),

                  // Play/Pause Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? AppTheme.primaryColor.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPlaying
                            ? AppTheme.primaryColor.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: isPlaying ? AppTheme.primaryColor : Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: Icon(icon, color: color, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 18,
      ),
    );
  }
}
