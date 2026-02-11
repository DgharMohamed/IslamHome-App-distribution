import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

/// Service to handle all app permissions
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() => _instance;

  PermissionService._internal();

  /// Request notification permission (Android 13+)
  Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    debugPrint('🔔 PermissionService: Requesting notification permission');
    final status = await Permission.notification.request();
    debugPrint('🔔 PermissionService: Notification permission status: $status');
    return status.isGranted;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    debugPrint('📍 PermissionService: Requesting location permission');
    final status = await Permission.locationWhenInUse.request();
    debugPrint('📍 PermissionService: Location permission status: $status');
    return status.isGranted;
  }

  /// Check if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  /// Request all essential permissions
  Future<Map<String, bool>> requestAllPermissions() async {
    debugPrint('🔔 PermissionService: Requesting all essential permissions');

    final results = <String, bool>{};

    try {
      // Request both permissions at once to avoid conflicts
      final statuses = await [
        Permission.notification,
        Permission.locationWhenInUse,
      ].request();

      results['notification'] =
          statuses[Permission.notification]?.isGranted ?? false;
      results['location'] =
          statuses[Permission.locationWhenInUse]?.isGranted ?? false;

      debugPrint('🔔 PermissionService: Permission results: $results');
    } catch (e) {
      debugPrint('🔔 PermissionService: Error requesting permissions: $e');
      // Return false for both if there's an error
      results['notification'] = false;
      results['location'] = false;
    }

    return results;
  }

  /// Check if all essential permissions are granted
  Future<bool> hasAllPermissions() async {
    final notificationGranted = await hasNotificationPermission();
    final locationGranted = await hasLocationPermission();
    return notificationGranted && locationGranted;
  }
}
