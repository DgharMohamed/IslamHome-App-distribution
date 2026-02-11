import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:islamic_library_flutter/data/models/quran_media_item.dart';
import 'package:islamic_library_flutter/data/models/playback_session.dart';
import 'package:islamic_library_flutter/data/services/playback_session_service.dart';
import 'package:player_notification/player_notification.dart';

/// Enhanced AudioHandler specifically designed for Quran playback
/// with proper Arabic notification support and reliable background operation
/// Requirements 1.1, 5.1: Proper notification display and state management
/// Requirements 5.4: Session persistence and restoration
class QuranAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  late StreamSubscription<PlaybackEvent> _playbackEventSubscription;
  late StreamSubscription<SequenceState?> _sequenceStateSubscription;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<int?> _currentIndexSubscription;

  // Instance for player_notification (Android only)
  final _playerNotification = PlayerNotification();

  // Ensure initialization is complete before allowing playback
  late final Future<void> _initComplete;

  // Current playlist for session persistence
  List<QuranVerse> _currentPlaylist = [];

  // Timer for periodic session saving
  Timer? _sessionSaveTimer;

  // Circuit breaker for player_notification to avoid ANRs if plugin missing
  bool _playerNotificationAvailable = true;

  QuranAudioHandler() {
    debugPrint('🎵 QuranAudioHandler: Initializing...');
    _initComplete = _init();
  }

  /// Get the underlying AudioPlayer for direct access when needed
  AudioPlayer get player => _player;

  Future<void> _init() async {
    // Set initial playback state with Arabic-friendly controls
    // Requirements 1.1, 5.1: Proper state initialization for notifications
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
          MediaAction.playPause,
          MediaAction.stop,
          MediaAction.play,
          MediaAction.pause,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );

    // Configure audio session for Quran recitation
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Handle audio interruptions (e.g., phone calls)
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(0.3); // Lower volume for Quran respect
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              // Don't auto-resume Quran - let user decide
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });

      // Handle becoming noisy (e.g., headphones unplugged)
      session.becomingNoisyEventStream.listen((_) {
        pause();
      });
    } catch (e) {
      debugPrint('🎵 QuranAudioHandler: Audio session config error: $e');
    }

    // Pass all playback events from just_audio through to audio_service
    _playbackEventSubscription = _player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object e, StackTrace st) {
        debugPrint('🎵 QuranAudioHandler: Playback error: $e');
      },
    );

    // Listen to changes in the current media item (handles auto-progression)
    // Requirements 1.4, 3.3: Ensure notification updates within 1 second when content changes
    _sequenceStateSubscription = _player.sequenceStateStream.listen((state) {
      final sequence = state?.sequence ?? [];
      final index = state?.currentIndex;
      if (sequence.isEmpty || index == null || index >= sequence.length) return;

      final source = sequence[index];
      final tag = source.tag;
      if (tag is MediaItem) {
        final updatedItem = tag.copyWith(duration: _player.duration);
        _updateMediaItem(updatedItem);

        // Log auto-progression for debugging
        if (index < _currentPlaylist.length) {
          final currentVerse = _currentPlaylist[index];
          debugPrint(
            '🎵 QuranAudioHandler: Track changed to verse ${index + 1}/${_currentPlaylist.length}: ${currentVerse.surahName} آية ${currentVerse.verseNumber}',
          );
        }

        // Force immediate notification update to ensure it happens within 1 second
        // Requirements 1.4, 3.3
        _forceNotificationUpdate();
      }
    });

    // Listen for index changes to update the queue index and handle auto-progression
    // Requirements 1.4, 3.3: Ensure notification updates within 1 second when auto-progressing
    _currentIndexSubscription = _player.currentIndexStream.listen((index) {
      if (index != null) {
        _broadcastState(_player.playbackEvent);

        // Only update media item for auto-progression (when player moves to next track automatically)
        // Manual navigation (skipToNext, skipToPrevious, skipToQueueItem) already updates the media item
        // We detect auto-progression by checking if the sequence state has already been updated
        // This prevents duplicate updates during manual navigation
      }
    });

    // Handle duration changes specifically to update mediaItem
    _durationSubscription = _player.durationStream.listen((duration) {
      final item = mediaItem.value;
      if (item != null && duration != null) {
        _updateMediaItem(item.copyWith(duration: duration));
      }
    });

    debugPrint('🎵 QuranAudioHandler: Initialization complete');

    // Initialize player_notification listeners
    _initPlayerNotification();
  }

  void _initPlayerNotification() {
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        _playerNotificationAvailable) {
      try {
        _playerNotification.setPlaybackListener(
          onPlay: play,
          onPause: pause,
          onNext: skipToNext,
          onPrevious: skipToPrevious,
        );
      } catch (e) {
        if (e is MissingPluginException) {
          _playerNotificationAvailable = false;
          debugPrint(
            '🎵 QuranAudioHandler: player_notification plugin missing, disabling...',
          );
        }
      }
    }
  }

  /// Updates the current media item and notifies the system
  /// Requirements 1.1, 1.4, 3.1, 3.2, 3.3: Ensure proper Arabic text in notifications
  /// and instant notification updates (within 1 second)
  void _updateMediaItem(MediaItem item) {
    final startTime = DateTime.now();
    debugPrint('🎵 QuranAudioHandler: Updating media item: ${item.title}');

    // Validate Arabic text formatting for notification display
    // This helps catch any formatting issues early
    if (kDebugMode) {
      if (!item.title.contains('آية')) {
        debugPrint(
          '🎵 QuranAudioHandler: Warning - MediaItem title missing Arabic verse marker',
        );
      }
      if (item.artist != 'القرآن الكريم') {
        debugPrint(
          '🎵 QuranAudioHandler: Warning - MediaItem artist not set correctly',
        );
      }
    }

    // Update media item immediately - this triggers notification update
    // Requirements 1.4, 3.3: Notification must update within 1 second
    mediaItem.add(item);

    // Measure update time in debug mode to ensure it's within 1 second
    if (kDebugMode) {
      final updateDuration = DateTime.now().difference(startTime);
      debugPrint(
        '🎵 QuranAudioHandler: Media item updated in ${updateDuration.inMilliseconds}ms',
      );
      if (updateDuration.inMilliseconds > 1000) {
        debugPrint(
          '🎵 QuranAudioHandler: WARNING - Media item update took longer than 1 second!',
        );
      }
    }

    // Sync with player_notification (Android only)
    _syncPlayerNotification(item);
  }

  void _syncPlayerNotification(MediaItem item) async {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android ||
        !_playerNotificationAvailable) {
      return;
    }

    try {
      // Using named parameters as suggested by lint errors
      await _playerNotification.show(
        title: item.title,
        artist: item.artist ?? 'القرآن الكريم',
        imageUrl: item.artUri?.toString() ?? '',
        isPlaying: _player.playing,
        position: _player.position,
        duration: item.duration ?? _player.duration ?? Duration.zero,
      );
    } catch (e) {
      debugPrint('🎵 QuranAudioHandler: player_notification sync error: $e');
      if (e is MissingPluginException) {
        _playerNotificationAvailable = false;
        debugPrint(
          '🎵 QuranAudioHandler: player_notification linkage failed! Disabling to prevent ANR.',
        );
        debugPrint(
          '🎵 QuranAudioHandler: TIP - A full app rebuild (Stop and Start) is required after adding this plugin.',
        );
      }
    }
  }

  /// Updates the queue and notifies the system
  void _updateQueue(List<QuranVerse> verses) {
    final mediaItems = verses.map((v) => v.toMediaItem()).toList();
    debugPrint(
      '🎵 QuranAudioHandler: Updating queue with ${mediaItems.length} items',
    );
    queue.add(mediaItems);
  }

  /// Force immediate notification update
  /// Requirements 1.4, 3.3: Ensure notification updates within 1 second when content changes
  void _forceNotificationUpdate() {
    final startTime = DateTime.now();
    debugPrint('🎵 QuranAudioHandler: Forcing immediate notification update');

    // Trigger both media item and state updates to ensure notification refreshes
    final currentItem = mediaItem.value;
    if (currentItem != null) {
      // Re-add the current media item to trigger notification update
      mediaItem.add(currentItem);
    }

    // Also broadcast current state to ensure controls are updated
    _broadcastState(_player.playbackEvent);

    if (kDebugMode) {
      final updateDuration = DateTime.now().difference(startTime);
      debugPrint(
        '🎵 QuranAudioHandler: Forced notification update completed in ${updateDuration.inMilliseconds}ms',
      );
      if (updateDuration.inMilliseconds > 1000) {
        debugPrint(
          '🎵 QuranAudioHandler: WARNING - Forced update took longer than 1 second!',
        );
      }
    }
  }

  /// Broadcasts the current player state to the system notification
  /// Requirements 1.4, 3.3: Ensure notification updates within 1 second
  void _broadcastState(PlaybackEvent event) {
    final startTime = DateTime.now();
    final playing = _player.playing;
    final queueIndex = _player.currentIndex ?? 0;

    debugPrint(
      '🎵 QuranAudioHandler._broadcastState: playing=$playing, queueIndex=$queueIndex, mediaItem=${mediaItem.value?.title}',
    );

    // Broadcast state immediately to ensure notification updates quickly
    // Requirements 1.4, 3.3: Notification must update within 1 second
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
          MediaAction.playPause,
          MediaAction.stop,
          MediaAction.play,
          MediaAction.pause,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: queueIndex,
      ),
    );

    // Measure broadcast time in debug mode to ensure it's within 1 second
    if (kDebugMode) {
      final broadcastDuration = DateTime.now().difference(startTime);
      debugPrint(
        '🎵 QuranAudioHandler: State broadcast completed in ${broadcastDuration.inMilliseconds}ms',
      );
      if (broadcastDuration.inMilliseconds > 1000) {
        debugPrint(
          '🎵 QuranAudioHandler: WARNING - State broadcast took longer than 1 second!',
        );
      }
    }

    // Sync play state with player_notification
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        _playerNotificationAvailable) {
      try {
        // Named parameters or positional based on lint feedback
        _playerNotification.updatePlayState(playing);
        _playerNotification.updateProgress(
          _player.position,
          mediaItem.value?.duration ?? _player.duration ?? Duration.zero,
        );
      } catch (e) {
        if (e is MissingPluginException) {
          _playerNotificationAvailable = false;
          debugPrint(
            '🎵 QuranAudioHandler: Disabling player_notification due to linkage error.',
          );
        }
      }
    }
  }

  @override
  Future<void> play() async {
    debugPrint('🎵 QuranAudioHandler: play() called, waiting for init...');
    await _initComplete;
    debugPrint('🎵 QuranAudioHandler: Starting playback');

    // Ensure we have a media item before playing
    if (mediaItem.value == null) {
      debugPrint(
        '🎵 QuranAudioHandler: WARNING - No media item set before play()',
      );
    }

    // Start playback
    await _player.play();

    // Force immediate state broadcast to ensure notification appears
    // This is critical for notification visibility
    _broadcastState(_player.playbackEvent);

    debugPrint(
      '🎵 QuranAudioHandler: Playback started, notification should be visible',
    );
  }

  @override
  Future<void> pause() async {
    debugPrint('🎵 QuranAudioHandler: pause() called');
    await _player.pause();

    // Save session when pausing
    await _saveCurrentSession();
  }

  @override
  Future<void> stop() async {
    debugPrint('🎵 QuranAudioHandler: stop() called');

    // Save session before stopping
    await _saveCurrentSession();

    // Stop periodic session saving
    _stopSessionSaving();

    await _player.stop();
    await _player.seek(Duration.zero);

    // Broadcast stopped state
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );

    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    debugPrint('🎵 QuranAudioHandler: seek() to $position');
    await _player.seek(position);
  }

  /// Skip to the next verse in the playlist
  /// Requirements 2.2, 1.4, 3.3: Navigate to next verse and update notification immediately
  @override
  Future<void> skipToNext() async {
    debugPrint('🎵 QuranAudioHandler: skipToNext() called');
    await _initComplete;

    // Check if we have a valid playlist
    if (_currentPlaylist.isEmpty) {
      debugPrint('🎵 QuranAudioHandler: No playlist to navigate');
      return;
    }

    final currentIndex = _player.currentIndex ?? 0;
    final hasNext = currentIndex < _currentPlaylist.length - 1;

    if (!hasNext) {
      debugPrint(
        '🎵 QuranAudioHandler: Already at last verse (${currentIndex + 1}/${_currentPlaylist.length})',
      );
      // If at the end and not looping, stay at current position
      if (_player.loopMode == LoopMode.off) {
        return;
      }
    }

    // Navigate to next verse
    await _player.seekToNext();

    // Explicitly update MediaItem for the new verse
    final newIndex = _player.currentIndex ?? currentIndex;
    if (newIndex < _currentPlaylist.length) {
      final nextVerse = _currentPlaylist[newIndex];
      _updateMediaItem(nextVerse.toMediaItem());
      debugPrint(
        '🎵 QuranAudioHandler: Navigated to verse ${newIndex + 1}/${_currentPlaylist.length}: ${nextVerse.surahName} آية ${nextVerse.verseNumber}',
      );

      // Force immediate notification update
      // Requirements 1.4, 3.3: Ensure notification updates within 1 second
      _forceNotificationUpdate();
    }
  }

  /// Skip to the previous verse in the playlist
  /// Requirements 2.3, 1.4, 3.3: Navigate to previous verse and update notification immediately
  @override
  Future<void> skipToPrevious() async {
    debugPrint('🎵 QuranAudioHandler: skipToPrevious() called');
    await _initComplete;

    // Check if we have a valid playlist
    if (_currentPlaylist.isEmpty) {
      debugPrint('🎵 QuranAudioHandler: No playlist to navigate');
      return;
    }

    final currentIndex = _player.currentIndex ?? 0;
    final hasPrevious = currentIndex > 0;

    if (!hasPrevious) {
      debugPrint(
        '🎵 QuranAudioHandler: Already at first verse (${currentIndex + 1}/${_currentPlaylist.length})',
      );
      // If at the beginning, restart current verse or loop to end
      if (_player.loopMode == LoopMode.off) {
        await _player.seek(Duration.zero);
        return;
      }
    }

    // Navigate to previous verse
    await _player.seekToPrevious();

    // Explicitly update MediaItem for the new verse
    final newIndex = _player.currentIndex ?? currentIndex;
    if (newIndex < _currentPlaylist.length) {
      final previousVerse = _currentPlaylist[newIndex];
      _updateMediaItem(previousVerse.toMediaItem());
      debugPrint(
        '🎵 QuranAudioHandler: Navigated to verse ${newIndex + 1}/${_currentPlaylist.length}: ${previousVerse.surahName} آية ${previousVerse.verseNumber}',
      );

      // Force immediate notification update
      // Requirements 1.4, 3.3: Ensure notification updates within 1 second
      _forceNotificationUpdate();
    }
  }

  /// Skip to a specific verse in the playlist by index
  /// Requirements 2.2, 2.3, 1.4, 3.3: Navigate to specific verse and update notification immediately
  @override
  Future<void> skipToQueueItem(int index) async {
    debugPrint('🎵 QuranAudioHandler: skipToQueueItem($index)');
    await _initComplete;

    // Validate index
    if (_currentPlaylist.isEmpty) {
      debugPrint('🎵 QuranAudioHandler: No playlist to navigate');
      return;
    }

    if (index < 0 || index >= _currentPlaylist.length) {
      debugPrint(
        '🎵 QuranAudioHandler: Invalid index $index (playlist size: ${_currentPlaylist.length})',
      );
      return;
    }

    // Navigate to the specified verse
    await _player.seek(Duration.zero, index: index);

    // Explicitly update MediaItem for the new verse
    final verse = _currentPlaylist[index];
    _updateMediaItem(verse.toMediaItem());
    debugPrint(
      '🎵 QuranAudioHandler: Navigated to verse ${index + 1}/${_currentPlaylist.length}: ${verse.surahName} آية ${verse.verseNumber}',
    );

    // Force immediate notification update
    // Requirements 1.4, 3.3: Ensure notification updates within 1 second
    _forceNotificationUpdate();
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await _player.setShuffleModeEnabled(
      shuffleMode == AudioServiceShuffleMode.all,
    );
  }

  /// Compatibility method for setting playlist with generic AudioSource list
  /// This allows the handler to work with existing AudioPlayerService code
  Future<void> setPlaylist(
    List<AudioSource> sources, {
    int initialIndex = 0,
  }) async {
    debugPrint(
      '🎵 QuranAudioHandler: setPlaylist() with ${sources.length} sources, starting at $initialIndex',
    );
    await _initComplete;

    if (sources.isEmpty) {
      debugPrint('🎵 QuranAudioHandler: Empty sources list');
      return;
    }

    // Extract media items from sources and update queue
    final mediaItems = <MediaItem>[];
    for (final source in sources) {
      if (source is UriAudioSource) {
        final tag = source.tag;
        if (tag is MediaItem) {
          mediaItems.add(tag);
        }
      }
    }

    if (mediaItems.isNotEmpty) {
      queue.add(mediaItems);
      if (initialIndex < mediaItems.length) {
        _updateMediaItem(mediaItems[initialIndex]);
      }
    }

    // Create concatenating audio source
    final playlist = ConcatenatingAudioSource(
      children: sources,
      useLazyPreparation: true,
    );

    await _player.setAudioSource(playlist, initialIndex: initialIndex);

    // Broadcast state immediately to trigger notification
    // This ensures AudioService knows we're ready to play
    _broadcastState(_player.playbackEvent);

    debugPrint('🎵 QuranAudioHandler: Playlist set successfully');
  }

  /// Compatibility method for setting a single audio source
  /// This allows the handler to work with existing AudioPlayerService code
  Future<void> setAudioSource(AudioSource source) async {
    debugPrint('🎵 QuranAudioHandler: setAudioSource() called');
    await _initComplete;

    // Extract media item from source and update
    if (source is UriAudioSource) {
      final tag = source.tag;
      if (tag is MediaItem) {
        _updateMediaItem(tag);
        queue.add([tag]);
      }
    }

    await _player.setAudioSource(source);

    // Broadcast state immediately to trigger notification
    // This ensures AudioService knows we're ready to play
    _broadcastState(_player.playbackEvent);

    debugPrint('🎵 QuranAudioHandler: Audio source set successfully');
  }

  /// Play a single Quran verse
  /// Requirements 1.4, 3.3: Ensure notification updates immediately when starting playback
  Future<void> playVerse(QuranVerse verse) async {
    debugPrint(
      '🎵 QuranAudioHandler: playVerse() - ${verse.surahName} آية ${verse.verseNumber}',
    );
    await _initComplete;

    // Store single verse as playlist
    _currentPlaylist = [verse];

    final mediaItem = verse.toMediaItem();
    _updateMediaItem(mediaItem);
    _updateQueue([verse]);

    final source = AudioSource.uri(Uri.parse(verse.audioUrl), tag: mediaItem);

    await _player.setAudioSource(source);
    await play();

    // Force immediate notification update
    // Requirements 1.4, 3.3: Ensure notification updates within 1 second
    _forceNotificationUpdate();

    // Start periodic session saving
    _startSessionSaving();
  }

  /// Play a playlist of Quran verses
  /// Requirements 1.4, 3.3: Ensure notification updates immediately when starting playback
  Future<void> playVersePlaylist(
    List<QuranVerse> verses, {
    int initialIndex = 0,
  }) async {
    debugPrint(
      '🎵 QuranAudioHandler: playVersePlaylist() with ${verses.length} verses, starting at $initialIndex',
    );
    await _initComplete;

    if (verses.isEmpty) {
      debugPrint('🎵 QuranAudioHandler: Empty verses list');
      return;
    }

    // Store playlist for session persistence
    _currentPlaylist = verses;

    // Update queue and current media item
    _updateQueue(verses);
    if (initialIndex < verses.length) {
      _updateMediaItem(verses[initialIndex].toMediaItem());
    }

    // Create audio sources
    final sources = verses.map((verse) {
      return AudioSource.uri(
        Uri.parse(verse.audioUrl),
        tag: verse.toMediaItem(),
      );
    }).toList();

    // Create concatenating audio source
    final playlist = ConcatenatingAudioSource(
      children: sources,
      useLazyPreparation: true,
    );

    await _player.setAudioSource(playlist, initialIndex: initialIndex);
    await play();

    // Force immediate notification update
    // Requirements 1.4, 3.3: Ensure notification updates within 1 second
    _forceNotificationUpdate();

    // Start periodic session saving
    _startSessionSaving();
  }

  /// Save the current playback session
  /// Requirements 5.4: Persist current position and playlist
  Future<void> _saveCurrentSession() async {
    if (_currentPlaylist.isEmpty) {
      debugPrint('🎵 QuranAudioHandler: No playlist to save');
      return;
    }

    try {
      final session = PlaybackSession(
        playlist: _currentPlaylist,
        currentIndex: _player.currentIndex ?? 0,
        currentPosition: _player.position,
        isPlaying: _player.playing,
        repeatMode: _convertLoopModeToRepeatMode(_player.loopMode),
        shuffleMode: _player.shuffleModeEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      );

      await PlaybackSessionService.saveSession(session);
    } catch (e) {
      debugPrint('🎵 QuranAudioHandler: Error saving session: $e');
    }
  }

  /// Convert LoopMode to AudioServiceRepeatMode
  AudioServiceRepeatMode _convertLoopModeToRepeatMode(LoopMode loopMode) {
    switch (loopMode) {
      case LoopMode.off:
        return AudioServiceRepeatMode.none;
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
    }
  }

  /// Start periodic session saving
  /// Requirements 5.4: Automatically save session during playback
  void _startSessionSaving() {
    // Cancel existing timer if any
    _sessionSaveTimer?.cancel();

    // Save session every 10 seconds during playback
    _sessionSaveTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _saveCurrentSession(),
    );

    debugPrint('🎵 QuranAudioHandler: Started periodic session saving');
  }

  /// Stop periodic session saving
  void _stopSessionSaving() {
    _sessionSaveTimer?.cancel();
    _sessionSaveTimer = null;
    debugPrint('🎵 QuranAudioHandler: Stopped periodic session saving');
  }

  /// Restore a previously saved session
  /// Requirements 5.4: Restore saved session on app restart
  Future<void> restoreSession() async {
    debugPrint('🎵 QuranAudioHandler: Attempting to restore session...');
    await _initComplete;

    try {
      final session = await PlaybackSessionService.restoreSession();
      if (session == null) {
        debugPrint('🎵 QuranAudioHandler: No session to restore');
        return;
      }

      if (session.playlist.isEmpty) {
        debugPrint('🎵 QuranAudioHandler: Restored session has empty playlist');
        return;
      }

      debugPrint(
        '🎵 QuranAudioHandler: Restoring session with ${session.playlist.length} items',
      );

      // Restore playlist
      await playVersePlaylist(
        session.playlist,
        initialIndex: session.currentIndex,
      );

      // Restore position
      await seek(session.currentPosition);

      // Restore repeat and shuffle modes
      await setRepeatMode(session.repeatMode);
      await setShuffleMode(session.shuffleMode);

      // Restore playing state
      if (!session.isPlaying) {
        await pause();
      }

      debugPrint('🎵 QuranAudioHandler: Session restored successfully');
    } catch (e) {
      debugPrint('🎵 QuranAudioHandler: Error restoring session: $e');
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    debugPrint('🎵 QuranAudioHandler: onTaskRemoved()');

    // Save session before task is removed
    await _saveCurrentSession();

    // Only stop if not playing to allow background playback
    if (!_player.playing) {
      await stop();
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    debugPrint('🎵 QuranAudioHandler: dispose()');

    // Save final session state
    await _saveCurrentSession();

    // Stop periodic session saving
    _stopSessionSaving();

    await _playbackEventSubscription.cancel();
    await _sequenceStateSubscription.cancel();
    await _durationSubscription.cancel();
    await _currentIndexSubscription.cancel();
    await _player.dispose();
  }
}
