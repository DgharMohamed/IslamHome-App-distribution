import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocationState {
  final bool useGPS;
  final String city;
  final String country;
  final String? gpsCoordinates;
  final bool isLoading;
  final String? error;

  LocationState({
    required this.useGPS,
    required this.city,
    required this.country,
    this.gpsCoordinates,
    this.isLoading = false,
    this.error,
  });

  String get query => '$city,$country';

  LocationState copyWith({
    bool? useGPS,
    String? city,
    String? country,
    String? gpsCoordinates,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      useGPS: useGPS ?? this.useGPS,
      city: city ?? this.city,
      country: country ?? this.country,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LocationNotifier extends Notifier<LocationState> {
  @override
  LocationState build() {
    // Initial state
    final box = Hive.box('settings');
    final useGPS = box.get('prayer_use_gps', defaultValue: false);
    final city = box.get('prayer_city', defaultValue: 'Rabat');
    final country = box.get('prayer_country', defaultValue: 'Morocco');
    final coords = box.get('prayer_coords');

    if (useGPS) {
      // Trigger async refresh after build
      Future.delayed(Duration.zero, () => refreshLocation());
    }

    return LocationState(
      useGPS: useGPS,
      city: city,
      country: country,
      gpsCoordinates: coords,
    );
  }

  Future<void> _saveSettings() async {
    final box = Hive.box('settings');
    await box.put('prayer_use_gps', state.useGPS);
    await box.put('prayer_city', state.city);
    await box.put('prayer_country', state.country);
    if (state.gpsCoordinates != null) {
      await box.put('prayer_coords', state.gpsCoordinates);
    }
  }

  Future<void> setManualLocation(String city, String country) async {
    state = state.copyWith(
      useGPS: false,
      city: city,
      country: country,
      isLoading: false,
    );
    await _saveSettings();
  }

  Future<void> toggleGPS(bool enabled) async {
    state = state.copyWith(useGPS: enabled);
    if (enabled) {
      await refreshLocation();
    } else {
      await _saveSettings();
    }
  }

  Future<void> refreshLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Permission checks
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(isLoading: false, error: 'Permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error: 'Permission permanently denied',
        );
        return;
      }

      // Fetch position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );

      // Resolve city/country
      String? resolvedCity;
      String? resolvedCountry;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          resolvedCity = place.locality ?? place.subAdministrativeArea;
          resolvedCountry = place.country;
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }

      state = state.copyWith(
        useGPS: true,
        gpsCoordinates: '${position.latitude},${position.longitude}',
        city: resolvedCity ?? state.city,
        country: resolvedCountry ?? state.country,
        isLoading: false,
      );
      await _saveSettings();
    } catch (e) {
      debugPrint('Location refresh error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(() {
  return LocationNotifier();
});
