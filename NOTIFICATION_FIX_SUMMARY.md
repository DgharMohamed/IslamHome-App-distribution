# Quran Playback Notification Fix

## Problem
The Quran audio player was not showing notifications on the phone when playing audio, even though the audio was playing correctly.

## Root Causes Identified

1. **Incorrect AudioService Configuration**: The `androidNotificationOngoing` was set to `false` while `androidStopForegroundOnPause` was also `false`, which can prevent the notification from appearing properly on Android 13+.

2. **Timing Issues**: The notification state wasn't being broadcast at the right times to ensure the Android system creates and displays the notification.

3. **Foreground Service**: The service wasn't properly starting as a foreground service when playback begins.

## Changes Made

### 1. Fixed QuranPlaybackService Configuration (`lib/data/services/quran_playback_service.dart`)

**Changed:**
```dart
androidNotificationOngoing: true,  // Keep notification persistent while playing
androidStopForegroundOnPause: true, // Stop foreground service when paused to allow dismissal
```

**Why:** This combination ensures:
- The notification appears and stays visible while playing
- The notification can be dismissed when paused
- The foreground service properly starts when playing begins

### 2. Enhanced QuranAudioHandler Play Method (`lib/data/services/quran_audio_handler.dart`)

**Added:**
- Broadcast state BEFORE starting playback to prepare the notification
- Added a small delay (100ms) after playback starts to ensure the notification updates
- Double broadcast to ensure Android system receives the state change

**Why:** Android 13+ requires the notification to be prepared before the foreground service starts, and the double broadcast ensures the system has time to process the notification.

### 3. Enhanced setPlaylist Method

**Added:**
- Additional state broadcast after setting the playlist
- Small delay to ensure the notification system processes the changes

**Why:** Ensures the notification is ready when the user presses play.

## How to Test

### 1. Clean Build
```bash
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter build apk --debug
```

### 2. Install and Test
1. Install the app on your Android device
2. Grant notification permissions when prompted (Android 13+)
3. Navigate to a reciter screen
4. Select a surah to play
5. **Expected Result**: You should see a notification appear in your notification shade with:
   - Surah name in Arabic
   - Reciter name
   - Play/Pause button
   - Previous/Next buttons
   - Stop button

### 3. Test Scenarios

#### Scenario 1: Basic Playback
- ✅ Play a surah → Notification should appear immediately
- ✅ Pause → Notification should remain visible but show pause button
- ✅ Resume → Notification should update to show play button
- ✅ Stop → Notification should disappear

#### Scenario 2: Background Playback
- ✅ Play a surah
- ✅ Press home button or switch apps
- ✅ Notification should remain visible
- ✅ Control playback from notification
- ✅ Tap notification to return to app

#### Scenario 3: Notification Controls
- ✅ Use Previous button in notification
- ✅ Use Next button in notification
- ✅ Use Play/Pause button in notification
- ✅ Use Stop button in notification

## Verification Checklist

- [ ] Notification appears when playing Quran
- [ ] Notification shows correct Arabic text (surah name, verse number)
- [ ] Notification shows reciter name
- [ ] Play/Pause button works from notification
- [ ] Previous/Next buttons work from notification
- [ ] Stop button works from notification
- [ ] Notification persists when app is in background
- [ ] Notification can be dismissed when paused
- [ ] Tapping notification opens the app
- [ ] Notification updates when track changes

## Permissions Required

The app already requests these permissions:
- ✅ `POST_NOTIFICATIONS` (Android 13+) - Requested in splash screen
- ✅ `FOREGROUND_SERVICE` - Declared in AndroidManifest.xml
- ✅ `FOREGROUND_SERVICE_MEDIA_PLAYBACK` - Declared in AndroidManifest.xml
- ✅ `WAKE_LOCK` - Declared in AndroidManifest.xml

## Troubleshooting

### If notification still doesn't appear:

1. **Check Permissions**:
   ```dart
   // In your app, check if notification permission is granted
   final hasPermission = await PermissionService().hasNotificationPermission();
   print('Notification permission: $hasPermission');
   ```

2. **Check Notification Settings**:
   - Go to Android Settings → Apps → Islam Home → Notifications
   - Ensure "تشغيل القرآن الكريم" channel is enabled

3. **Check Logs**:
   ```bash
   adb logcat | grep "QuranAudioHandler\|AudioService"
   ```
   Look for:
   - "Playback started, notification should be visible"
   - "State broadcast completed"
   - Any error messages

4. **Force Stop and Restart**:
   - Force stop the app
   - Clear app data (Settings → Apps → Islam Home → Storage → Clear Data)
   - Reinstall the app
   - Grant permissions again

## Technical Details

### AudioService Configuration
- **Channel ID**: `quran_playback`
- **Channel Name**: `تشغيل القرآن الكريم` (Quran Playback)
- **Channel Description**: `التحكم في تشغيل القرآن الكريم` (Control Quran Playback)
- **Notification Icon**: `drawable/ic_notification` (Quran book icon)
- **Foreground Service Type**: `mediaPlayback`

### State Broadcasting
The handler broadcasts state in these scenarios:
1. When playlist is set
2. Before playback starts
3. After playback starts (with 100ms delay)
4. When playback state changes (play/pause/stop)
5. When track changes

### Media Item Format
```dart
MediaItem(
  id: audioUrl,
  title: 'سورة الفاتحة آية 1', // Surah name + verse number
  artist: 'القرآن الكريم',      // "The Holy Quran"
  album: reciterName,          // Reciter name
  duration: null,              // Streaming, no duration
)
```

## Files Modified

1. [`lib/data/services/quran_playback_service.dart`](lib/data/services/quran_playback_service.dart)
   - Updated `androidNotificationOngoing` to `true`
   - Updated `androidStopForegroundOnPause` to `true`

2. [`lib/data/services/quran_audio_handler.dart`](lib/data/services/quran_audio_handler.dart)
   - Enhanced `play()` method with pre-playback state broadcast
   - Added delayed state broadcast after playback starts
   - Enhanced `setPlaylist()` method with additional state broadcast

## Related Files (No Changes Needed)

- [`lib/data/services/permission_service.dart`](lib/data/services/permission_service.dart) - Already handles notification permissions
- [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml) - Already has correct permissions and service configuration
- [`android/app/src/main/res/drawable/ic_notification.xml`](android/app/src/main/res/drawable/ic_notification.xml) - Notification icon already exists

## Next Steps

1. Build and install the app
2. Test all scenarios listed above
3. If issues persist, check the troubleshooting section
4. Monitor logs for any error messages

## Support

If you continue to experience issues:
1. Capture logs using: `adb logcat > notification_debug.log`
2. Note the exact steps to reproduce
3. Check Android version and device model
4. Verify notification permissions are granted
