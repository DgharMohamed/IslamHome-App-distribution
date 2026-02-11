import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_library_flutter/core/theme/app_theme.dart';
import 'package:islamic_library_flutter/l10n/generated/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:adhan/adhan.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:islamic_library_flutter/core/utils/scaffold_utils.dart';
import 'package:islamic_library_flutter/presentation/widgets/qibla_painters.dart';
import 'package:islamic_library_flutter/presentation/providers/location_provider.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      setState(() {
        _hasPermissions = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locationState = ref.watch(locationProvider);

    // Parse coordinates from locationProvider
    double lat = 0;
    double lng = 0;
    if (locationState.gpsCoordinates != null) {
      final parts = locationState.gpsCoordinates!.split(',');
      if (parts.length == 2) {
        lat = double.tryParse(parts[0]) ?? 0;
        lng = double.tryParse(parts[1]) ?? 0;
      }
    }

    if (!_hasPermissions) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            l10n.qibla,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, size: 28),
            onPressed: () => GlobalScaffoldService.openDrawer(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off_rounded,
                size: 80,
                color: Colors.white24,
              ),
              const SizedBox(height: 24),
              Text(
                'Location Permission Required',
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF0D47A1), AppTheme.backgroundColor],
            stops: const [0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Custom Header
              _buildHeader(l10n),

              Expanded(
                child: StreamBuilder<CompassEvent>(
                  stream: FlutterCompass.events,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      );
                    }

                    double? direction = snapshot.data?.heading;
                    if (direction == null) {
                      return const Center(
                        child: Text('Device does not have sensors'),
                      );
                    }

                    // Calculate Qibla
                    final qibla = Qibla(Coordinates(lat, lng));
                    final qiblaDirection = qibla.direction;

                    // Calculate Distance
                    double distanceInMeters = Geolocator.distanceBetween(
                      lat,
                      lng,
                      21.4225, // Kaaba Lat
                      39.8262, // Kaaba Long
                    );

                    return Column(
                      children: [
                        const Spacer(),
                        // 3. Compass Section
                        _buildCompass(direction, qiblaDirection),
                        const Spacer(),
                        // 4. Info Badges
                        _buildInfoBadges(
                          qiblaDirection,
                          distanceInMeters,
                          lat,
                          lng,
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          Text(
            l10n.qibla,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
            onPressed: () => GlobalScaffoldService.openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass(double direction, double qiblaDirection) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Top Ornament
        Positioned(
          top: -40,
          child: CustomPaint(
            size: const Size(120, 60),
            painter: QiblaOrnamentPainter(color: Colors.white24),
          ),
        ),

        // Rotating Dial
        Transform.rotate(
          angle: (direction * -1) * (math.pi / 180),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(320, 320),
                painter: QiblaDialPainter(color: Colors.white24),
              ),
              // Direction Letters (Dial Interior)
              // ...
            ],
          ),
        ),

        // Fixed Center components (Needle)
        Transform.rotate(
          angle: (qiblaDirection - direction) * (math.pi / 180),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The Main Needle (Now includes mosque silhouette)
              CustomPaint(
                size: const Size(40, 260),
                painter: CompassNeedlePainter(),
              ),
            ],
          ),
        ),

        // Center Point
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor, width: 4),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBadges(
    double qiblaDirection,
    double distance,
    double lat,
    double lng,
  ) {
    return Column(
      children: [
        // Coordinates Badge (Formatted as N/S Lat E/W Lng)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '${lat >= 0 ? 'N' : 'S'}  ${lat.abs().toStringAsFixed(2)}°  ${lng >= 0 ? 'E' : 'W'}  ${lng.abs().toStringAsFixed(2)}°',
            style: GoogleFonts.montserrat(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Distance & Angle Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInfoCard(
              '${(distance / 1000).toStringAsFixed(0)} KM',
              'بعد عن الكعبة',
              const Icon(Icons.mosque, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            _buildInfoCard(
              qiblaDirection.toStringAsFixed(2),
              'اتجاه القبلة',
              const Icon(Icons.architecture, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            _buildSmallRoundBadge('36\nMT'),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String value, String label, Widget icon) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: Colors.black54,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallRoundBadge(String label) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
