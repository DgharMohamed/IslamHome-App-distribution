import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';

class UpdateManager {
  // TODO: Replace with your actual GitHub Pages URLs
  static const String _versionUrl =
      'https://dgharmohamed.github.io/IslamHome-App-distribution/version.json';
  static const String _apkUrl =
      'https://dgharmohamed.github.io/IslamHome-App-distribution/app-release.apk';

  static Future<void> check(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http
          .get(Uri.parse(_versionUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        if (!context.mounted) return;

        final data = json.decode(response.body);
        final latestVersion = data['version'] as String;

        // Get localized notes
        final locale = View.of(context).platformDispatcher.locale.languageCode;
        String notes;
        if (locale == 'ar') {
          notes =
              data['notes_ar'] as String? ??
              data['notes_en'] as String? ??
              'تحديث جديد متاح';
        } else {
          notes =
              data['notes_en'] as String? ??
              data['notes_ar'] as String? ??
              'New update available';
        }

        if (_isNewer(currentVersion, latestVersion)) {
          if (context.mounted) {
            _showUpdateDialog(context, latestVersion, notes);
          }
        }
      }
    } catch (e) {
      debugPrint('UpdateManager Error: $e');
    }
  }

  static bool _isNewer(String current, String latest) {
    List<int> cur = current.split('.').map(int.parse).toList();
    List<int> lat = latest.split('.').map(int.parse).toList();
    for (int i = 0; i < lat.length; i++) {
      if (i >= cur.length || lat[i] > cur[i]) return true;
      if (lat[i] < cur[i]) return false;
    }
    return false;
  }

  static void _showUpdateDialog(
    BuildContext context,
    String version,
    String notes,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _UpdateDialog(version: version, notes: notes, apkUrl: _apkUrl),
    );
  }
}

class _UpdateDialog extends StatefulWidget {
  final String version;
  final String notes;
  final String apkUrl;

  const _UpdateDialog({
    required this.version,
    required this.notes,
    required this.apkUrl,
  });

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  double _progress = 0;
  bool _isDownloading = false;
  String _statusMessage = '';

  void _startDownload() {
    setState(() {
      _isDownloading = true;
      _statusMessage = 'جاري التحميل...';
    });

    try {
      OtaUpdate()
          .execute(widget.apkUrl, destinationFilename: 'islam_home.apk')
          .listen(
            (OtaEvent event) {
              setState(() {
                switch (event.status) {
                  case OtaStatus.DOWNLOADING:
                    _progress = double.tryParse(event.value ?? '0') ?? 0;
                    break;
                  case OtaStatus.INSTALLING:
                    _statusMessage = 'جاري التثبيت...';
                    _isDownloading = false;
                    Navigator.pop(context);
                    break;
                  case OtaStatus.ALREADY_RUNNING_ERROR:
                    _statusMessage = 'التحميل قيد التشغيل بالفعل';
                    break;
                  case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                    _statusMessage = 'تم رفض الإذن';
                    break;
                  default:
                    _statusMessage = 'حدث خطأ: ${event.status}';
                    _isDownloading = false;
                }
              });
            },
            onError: (e) {
              setState(() {
                _statusMessage = 'فشل التحميل: $e';
                _isDownloading = false;
              });
            },
          );
    } catch (e) {
      setState(() {
        _statusMessage = 'حدث خطأ غير متوقع';
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.system_update, color: Color(0xFF125139)),
          SizedBox(width: 12),
          Text('تحديث جديد', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإصدار: ${widget.version}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(widget.notes),
          if (_isDownloading) ...[
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _progress / 100,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF125139),
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${_progress.toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          if (_statusMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: TextStyle(
                color: _statusMessage.contains('فشل')
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!_isDownloading) ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: _startDownload,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF125139),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('تحديث الآن'),
          ),
        ],
      ],
    );
  }
}
