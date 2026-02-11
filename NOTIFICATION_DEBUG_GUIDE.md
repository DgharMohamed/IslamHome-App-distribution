# Notification Not Showing - Debug Guide

## Changes Made

I've updated the `QuranAudioHandler` to ensure notifications appear by:

1. **Removed `_forceNotificationUpdate()` calls** from `setPlaylist()` and `setAudioSource()`
2. **Added `_broadcastState()` calls** instead - this is the proper way to trigger notifications
3. **Enhanced `play()` method** to broadcast state immediately after starting playback

## Why Notifications Might Not Show

AudioService notifications only appear when ALL of these conditions are met:

1. ✅ **Notification channel is created** - Done in `NotificationService.init()` and `NotificationManager.initialize()`
2. ✅ **Notification permissions granted** - Done in `main.dart` with `Permission.notification.request()`
3. ✅ **MediaItem is set** - Done in `setPlaylist()`/`setAudioSource()`
4. ✅ **PlaybackState is broadcast** - Done in `_broadcastState()`
5. ⚠️ **AudioService enters foreground mode** - Happens when `play()` is called
6. ⚠️ **Notification icon exists** - Should be at `android/app/src/main/res/drawable/ic_notification.xml`

## Debugging Steps

### Step 1: Check Logcat for Notification Errors

Run the app and check logcat for any notification-related errors:

```bash
adb logcat | findstr /i "notification audioservice quran"
```

Look for:
- "Notification channel not found"
- "Permission denied"
- "Icon not found"
- Any AudioService errors

### Step 2: Verify Notification Permission

On Android 13+, notification permission must be explicitly granted. Check if the permission dialog appeared when you first ran the app.

To manually check/grant permission:
1. Go to Settings > Apps > Islam Home
2. Go to Permissions > Notifications
3. Ensure it's set to "Allowed"

### Step 3: Test with Simple Playback

Try playing audio from the simplest screen (like Radio or a single video) to isolate the issue:

1. Open the app
2. Go to Radio screen
3. Play a radio station
4. Check if notification appears

### Step 4: Check Debug Logs

The code now has extensive debug logging. Look for these messages in logcat:

```
🎵 QuranAudioHandler: Initializing...
🎵 QuranAudioHandler: Initialization complete
🎵 QuranAudioHandler: setPlaylist() with X sources
🎵 QuranAudioHandler: play() called
🎵 QuranAudioHandler: Starting playback
🎵 QuranAudioHandler: Playback started, notification should be visible
🎵 QuranAudioHandler._broadcastState: playing=true
```

If you see "WARNING - No media item set before play()", that's the problem.

### Step 5: Verify Notification Icon

Check that the icon file exists:
```bash
dir android\app\src\main\res\drawable\ic_notification.xml
```

If it doesn't exist, the notification won't show.

### Step 6: Test Notification System

The app shows a test notification on startup (in debug mode). If you see that notification, the system is working and the issue is with AudioService specifically.

## Common Issues and Solutions

### Issue 1: Notification Shows Briefly Then Disappears

**Cause**: `androidNotificationOngoing` is set to `false` in `QuranPlaybackService`

**Solution**: The notification can be dismissed by the user. This is intentional per Requirement 1.3. The notification should reappear when playback resumes.

### Issue 2: Notification Never Appears

**Possible Causes**:
1. Notification permission not granted
2. Notification channel not created
3. Icon file missing
4. AudioService not entering foreground mode
5. MediaItem not set before play()

**Solution**: Follow debugging steps above to identify which condition is failing.

### Issue 3: Notification Shows But No Arabic Text

**Cause**: MediaItem not properly formatted with Arabic text

**Solution**: Check that `QuranMediaItem.toMediaItem()` is being used to create MediaItems with proper Arabic formatting.

## Code Flow for Notification Display

Here's the complete flow when playing audio:

1. User taps play button in UI
2. UI calls `audioPlayerService.setPlaylist(sources)`
3. Service calls `handler.setPlaylist(sources)`
4. Handler extracts MediaItems and calls `_updateMediaItem()`
5. Handler sets audio source in player
6. Handler calls `_broadcastState()` to notify AudioService
7. Service calls `_handler.play()`
8. Handler's `play()` method starts playback
9. Handler calls `_broadcastState()` again with playing=true
10. **AudioService enters foreground mode and shows notification**

If notification doesn't appear, one of these steps is failing.

## Next Steps

1. Run the app with logcat open
2. Try playing audio
3. Look for the debug messages listed above
4. Check for any errors or warnings
5. Report back which step is failing

## Files Modified

- `lib/data/services/quran_audio_handler.dart` - Enhanced notification triggering
- `lib/main.dart` - Already has permission request and notification setup
- `lib/data/services/quran_playback_service.dart` - Already configured correctly
- `lib/data/services/notification_manager.dart` - Already has channel setup

## Testing Checklist

- [ ] Notification permission granted
- [ ] Test notification appears on app startup (debug mode)
- [ ] Logcat shows "QuranAudioHandler: Initialization complete"
- [ ] Logcat shows "QuranAudioHandler: Playback started, notification should be visible"
- [ ] Logcat shows "_broadcastState: playing=true"
- [ ] No errors in logcat about notifications or AudioService
- [ ] Icon file exists at `android/app/src/main/res/drawable/ic_notification.xml`
