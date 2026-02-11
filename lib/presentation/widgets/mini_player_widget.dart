import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/data/services/audio_player_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:audio_service/audio_service.dart';
import 'package:islamic_library_flutter/presentation/widgets/glass_container.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';

class MiniPlayerWidget extends ConsumerWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioService = ref.watch(audioPlayerServiceProvider);
    final l10n = AppLocalizations.of(context)!;

    // Don't show mini player if audio service not yet initialized
    if (audioService == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<PlayerState>(
      stream: audioService.player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        debugPrint(
          '🎵 MiniPlayer: processingState=$processingState, playing=$playing',
        );

        // Show mini player if audio is loading, buffering, or ready (but not idle/complete)
        if (processingState == ProcessingState.idle ||
            processingState == null) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<MediaItem?>(
          stream: audioService.mediaItemStream,
          builder: (context, metadataSnapshot) {
            final hasMetadata = metadataSnapshot.data != null;
            debugPrint(
              '🎵 MiniPlayer: hasMetadata=$hasMetadata, title=${metadataSnapshot.data?.title}',
            );

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.fromLTRB(
                12,
                0,
                12,
                12,
              ), // Floating effect
              child: GlassContainer(
                borderRadius: 20,
                blur: 20,
                opacity: 0.12,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/player'),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: StreamBuilder<SequenceState?>(
                            stream: audioService.player.sequenceStateStream,
                            builder: (context, snapshot) {
                              final state = snapshot.data;
                              final metadata =
                                  state?.currentSource?.tag as MediaItem? ??
                                  metadataSnapshot.data;

                              return Row(
                                children: [
                                  // Mini Artwork with pulse effect if playing
                                  Hero(
                                    tag: 'artwork',
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: playing == true
                                            ? [
                                                BoxShadow(
                                                  color: AppTheme.primaryColor
                                                      .withValues(alpha: 0.2),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.music_note_rounded,
                                          color: AppTheme.primaryColor,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Metadata
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          metadata?.title ?? l10n.nowPlaying,
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          metadata?.artist ?? l10n.reciterLabel,
                                          style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            color: Colors.white.withValues(
                                              alpha: 0.6,
                                            ),
                                            height: 1.1,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Compact Controls
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (playing == true) {
                                            audioService.pause();
                                          } else {
                                            audioService.resume();
                                          }
                                        },
                                        icon: Icon(
                                          playing == true
                                              ? Icons
                                                    .pause_circle_filled_rounded
                                              : Icons.play_circle_fill_rounded,
                                          size: 40,
                                          color: AppTheme.primaryColor,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () =>
                                            audioService.player.seekToNext(),
                                        icon: const Icon(
                                          Icons.skip_next_rounded,
                                          size: 32,
                                          color: Colors.white70,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        // Progress bar at the very bottom of the card
                        StreamBuilder<Duration>(
                          stream: audioService.player.positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final duration =
                                audioService.player.duration ?? Duration.zero;
                            final factor = duration.inMilliseconds > 0
                                ? (position.inMilliseconds /
                                          duration.inMilliseconds)
                                      .clamp(0.0, 1.0)
                                : 0.0;

                            return Container(
                              height: 3,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: factor,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
