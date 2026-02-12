import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/data/services/audio_player_service.dart';
import 'package:islamic_library_flutter/data/services/download_service.dart';
import 'package:islamic_library_flutter/presentation/providers/download_state.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'dart:math';

class PlayerControls extends ConsumerWidget {
  final AudioPlayerService audioService;
  final Function(BuildContext, AudioPlayerService, WidgetRef) onShowQueue;

  const PlayerControls({
    super.key,
    required this.audioService,
    required this.onShowQueue,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          StreamBuilder<MediaItem?>(
            stream: audioService.mediaItemStream,
            builder: (context, metadataSnapshot) {
              final duration =
                  metadataSnapshot.data?.duration ??
                  audioService.player.duration ??
                  Duration.zero;

              return StreamBuilder<Duration>(
                stream: audioService.player.positionStream,
                builder: (context, positionSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;

                  return Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                            activeTrackColor: AppTheme.primaryColor,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: position.inMilliseconds.toDouble().clamp(
                              0,
                              max(1.0, duration.inMilliseconds.toDouble()),
                            ),
                            max: max(
                              1.0,
                              duration.inMilliseconds.toDouble() + 0.01,
                            ),
                            onChanged: (value) {
                              audioService.player.seek(
                                Duration(milliseconds: value.toInt()),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<bool>(
                    stream: audioService.player.shuffleModeEnabledStream,
                    builder: (context, snapshot) {
                      final enabled = snapshot.data ?? false;
                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.shuffle_rounded,
                          color: enabled ? AppTheme.primaryColor : Colors.white,
                        ),
                        onPressed: () => audioService.toggleShuffle(),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => audioService.player.seekToPrevious(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.replay_10_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => audioService.skipBackward(),
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder<PlayerState>(
                    stream: audioService.player.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final playing = playerState?.playing ?? false;
                      final processingState = playerState?.processingState;

                      if (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering) {
                        return const SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          if (playing) {
                            audioService.pause();
                          } else {
                            audioService.resume();
                          }
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 42,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.forward_10_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => audioService.skipForward(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => audioService.player.seekToNext(),
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder<LoopMode>(
                    stream: audioService.player.loopModeStream,
                    builder: (context, snapshot) {
                      final mode = snapshot.data ?? LoopMode.off;
                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          mode == LoopMode.one
                              ? Icons.repeat_one_rounded
                              : Icons.repeat_rounded,
                          color: mode != LoopMode.off
                              ? AppTheme.primaryColor
                              : Colors.white,
                        ),
                        onPressed: () => audioService.toggleRepeat(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Secondary Controls Row (Speed & Download)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Speed Control
              StreamBuilder<double>(
                stream: audioService.player.speedStream,
                builder: (context, snapshot) {
                  final speed = snapshot.data ?? 1.0;
                  return TextButton.icon(
                    onPressed: () {
                      final newSpeed = speed == 1.0
                          ? 1.25
                          : speed == 1.25
                          ? 1.5
                          : speed == 1.5
                          ? 2.0
                          : speed == 2.0
                          ? 0.75
                          : 1.0;
                      audioService.player.setSpeed(newSpeed);
                    },
                    icon: const Icon(
                      Icons.speed_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                    label: Text(
                      '${speed}x',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
              // Download Button
              Consumer(
                builder: (context, ref, child) {
                  final state = audioService.player.sequenceState;
                  final metadata = state?.currentSource?.tag as MediaItem?;
                  if (metadata == null) return const SizedBox.shrink();

                  final title = metadata.title;
                  final artist = metadata.artist;
                  final url = metadata.id;
                  final album = metadata.album;
                  final extras = metadata.extras;

                  final isSeerah = album == 'السيرة النبوية';
                  final downloadNotifier = ref.read(downloadProvider.notifier);
                  final downloadState = ref.watch(downloadProvider);

                  // Extract IDs if possible
                  final int episodeId = extras?['id'] ?? 0;

                  return FutureBuilder<bool>(
                    future: isSeerah
                        ? downloadNotifier.isSeerahDownloaded(
                            artist ?? '',
                            episodeId,
                          )
                        : Future.value(false),
                    builder: (context, snapshot) {
                      final bool isDownloaded = snapshot.data ?? false;

                      // Identify current download status for progress
                      final String downloadId = isSeerah
                          ? 'seerah_${artist}_seerah_audio_$episodeId'
                          : '';
                      final activeDownload = downloadState[downloadId];
                      final bool isDownloading =
                          activeDownload?.status == DownloadStatus.downloading;
                      final double progress = activeDownload?.progress ?? 0.0;

                      return TextButton.icon(
                        onPressed: isDownloaded || isDownloading
                            ? null
                            : () async {
                                if (isSeerah) {
                                  await downloadNotifier.startSeerahDownload(
                                    reciterName: artist ?? 'بدر المشاري',
                                    title: title,
                                    url: url,
                                    episodeId: episodeId,
                                  );
                                }
                              },
                        icon: isDownloading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor,
                                ),
                              )
                            : Icon(
                                isDownloaded
                                    ? Icons.offline_pin_rounded
                                    : Icons.download_rounded,
                                color: isDownloaded
                                    ? AppTheme.primaryColor
                                    : Colors.white70,
                                size: 20,
                              ),
                        label: Text(
                          isDownloaded
                              ? l10n.downloaded
                              : isDownloading
                              ? '${(progress * 100).toInt()}%'
                              : l10n.download,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // Queue Button
              TextButton.icon(
                onPressed: () {
                  onShowQueue(context, audioService, ref);
                },
                icon: const Icon(
                  Icons.queue_music_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                label: Text(
                  l10n.playlist,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
