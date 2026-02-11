import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'dart:io';

class UpdateService {
  // TODO: Replace these with your actual GitHub Raw URLs
  static const String _versionUrl =
      'https://raw.githubusercontent.com/DgharMohamed/Islam-Home/main/version.json';
  static const String _apkUrl =
      'https://raw.githubusercontent.com/DgharMohamed/Islam-Home/main/app-release.apk';

  static Future<void> checkForUpdate(
    BuildContext context, {
    bool showNoUpdateDialog = false,
  }) async {
    try {
      debugPrint('🔄 UpdateService: Checking for updates...');

      // 1. Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 2. Fetch remote version info
      final response = await http
          .get(Uri.parse(_versionUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['version'] as String;
        final releaseNotes =
            data['notes'] as String? ?? 'New version available';
        final isCritical = data['critical'] as bool? ?? false;

        debugPrint(
          '🔄 UpdateService: Current: $currentVersion, Latest: $latestVersion',
        );

        if (_isVersionNewer(currentVersion, latestVersion)) {
          if (context.mounted) {
            _showUpdateDialog(context, latestVersion, releaseNotes, isCritical);
          }
        } else if (showNoUpdateDialog) {
          if (context.mounted) {
            _showNoUpdateDialog(context);
          }
        }
      } else {
        debugPrint(
          '🔄 UpdateService: Failed to fetch version info (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('🔄 UpdateService Error: $e');
    }
  }

  static bool _isVersionNewer(String current, String latest) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
    BuildContext context,
    String version,
    String notes,
    bool critical,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !critical,
      builder: (context) => PopScope(
        canPop: !critical,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.system_update_alt, color: Color(0xFF125139)),
              const SizedBox(width: 10),
              Text(
                'تحديث جديد متاح',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الإصدار: $version',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(notes),
              if (critical) ...[
                const SizedBox(height: 15),
                const Text(
                  'هذا التحديث ضروري للمتابعة.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!critical)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('لاحقاً'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _executeDownload(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF125139),
                foregroundColor: Colors.white,
              ),
              child: const Text('تحديث الآن'),
            ),
          ],
        ),
      ),
    );
  }

  static void _executeDownload(BuildContext context) {
    if (!Platform.isAndroid) {
      // Fallback for non-android if necessary
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('بدأ تحميل التحديث...')));

    try {
      OtaUpdate()
          .execute(_apkUrl, destinationFilename: 'islamic_library.apk')
          .listen(
            (OtaEvent event) {
              debugPrint(
                '🔄 OTA Status: ${event.status}, Progress: ${event.value}',
              );
            },
            onError: (e) {
              debugPrint('🔄 OTA Error: $e');
              _showErrorDialog(
                context,
                'فشل في تحميل التحديث. يرجى المحاولة لاحقاً.',
              );
            },
          );
    } catch (e) {
      debugPrint('🔄 OTA Exception: $e');
    }
  }

  static void _showNoUpdateDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('أنت تستخدم أحدث إصدار بالفعل')),
    );
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
