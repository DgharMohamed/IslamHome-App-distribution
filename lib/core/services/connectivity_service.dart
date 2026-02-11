import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized connectivity monitoring service.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isOnline => _isOnline;

  /// Initialize and start listening to connectivity changes.
  Future<void> init() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = _hasConnection(results);
      debugPrint(
        '📶 Initial connectivity: ${_isOnline ? "Online" : "Offline"}',
      );
    } catch (e) {
      debugPrint('📶 Connectivity check failed: $e');
      _isOnline = true; // Assume online if check fails
    }

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = _hasConnection(results);
      if (wasOnline != _isOnline) {
        debugPrint(
          '📶 Connectivity changed: ${_isOnline ? "Online" : "Offline"}',
        );
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );
  }

  /// Stream of online/offline state changes.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => _hasConnection(results),
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}

// --- Riverpod Providers ---

final connectivityServiceProvider = Provider((ref) => ConnectivityService());

/// Stream provider that emits true/false for online/offline.
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

/// Simple synchronous check — reads cached value.
final isOnlineProvider = Provider<bool>((ref) {
  final stream = ref.watch(connectivityStreamProvider);
  return stream.whenOrNull(data: (v) => v) ??
      ref.read(connectivityServiceProvider).isOnline;
});
