import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Real-time ride navigation screen with GPS tracking.
///
/// Features:
/// - Live GPS position tracking with Firebase sync
/// - Route progress with origin/destination
/// - ETA, distance remaining, and speed (km/h)
/// - Driver info panel with avatar and rating
/// - Share live location link
/// - Emergency SOS button (long-press)
/// - Arrival confirmation with ride completion flow
class RideNavigationScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RideNavigationScreen({super.key, required this.rideId});

  @override
  ConsumerState<RideNavigationScreen> createState() =>
      _RideNavigationScreenState();
}

class _RideNavigationScreenState extends ConsumerState<RideNavigationScreen>
    with TickerProviderStateMixin {
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  double _progress = 0.0;
  String _eta = 'Calculating...';
  String _distanceRemaining = '--';
  double _speedKmh = 0;
  late AnimationController _pulseController;

  // Real ETA calculation state
  double? _totalDistanceKm;
  int? _totalDurationMinutes;
  LatLng? _originLatLng;
  LatLng? _destinationLatLng;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      final accepted =
          await PermissionDialogHelper.showRideTrackingRationale(context);
      if (!accepted) return;
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied ||
          requested == LocationPermission.deniedForever) {
        return;
      }
    }

    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          if (!mounted) return;
          setState(() {
            _currentPosition = position;
          });
          _updateLocationInFirebase(position);
          _calculateProgress(position);
        });
  }

  Future<void> _updateLocationInFirebase(Position position) async {
    try {
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .update({
            'liveLocation': GeoPoint(position.latitude, position.longitude),
            'lastLocationUpdate': FieldValue.serverTimestamp(),
          });
    } catch (_) {
      // Silent fail for location updates
    }
  }

  void _calculateProgress(Position position) {
    // Speed from GPS (m/s → km/h)
    final speedKmh = (position.speed * 3.6).clamp(0.0, 200.0);

    // Lazy-initialize ride data from the current ride stream value
    if (_originLatLng == null || _destinationLatLng == null) {
      final rideAsync = ref.read(rideStreamProvider(widget.rideId));
      final ride = rideAsync.value;
      if (ride != null) {
        _originLatLng = LatLng(
          ride.origin.latitude,
          ride.origin.longitude,
        );
        _destinationLatLng = LatLng(
          ride.destination.latitude,
          ride.destination.longitude,
        );
        _totalDistanceKm = ride.distanceKm;
        _totalDurationMinutes = ride.durationMinutes;
      }
    }

    if (_originLatLng == null || _destinationLatLng == null) {
      // No ride data yet - show placeholder
      setState(() {
        _speedKmh = speedKmh;
        _eta = 'Calculating...';
        _distanceRemaining = '--';
      });
      return;
    }

    final currentLatLng = LatLng(position.latitude, position.longitude);

    // Calculate distances using Haversine
    final totalDistKm =
        _totalDistanceKm ?? _haversineKm(_originLatLng!, _destinationLatLng!);
    final distToDest = _haversineKm(currentLatLng, _destinationLatLng!);
    final distFromOrigin = _haversineKm(_originLatLng!, currentLatLng);

    // Calculate progress (0.0 to 1.0)
    final progress = totalDistKm > 0
        ? (distFromOrigin / (distFromOrigin + distToDest)).clamp(0.0, 1.0)
        : 0.0;

    // Calculate ETA: prefer speed-based if moving, else use duration ratio
    int remainingMinutes;
    if (speedKmh > 5) {
      // Moving - use current speed for ETA
      remainingMinutes = (distToDest / speedKmh * 60).round();
    } else if (_totalDurationMinutes != null) {
      // Stationary - estimate from total duration and progress
      remainingMinutes = ((1 - progress) * _totalDurationMinutes!).round();
    } else {
      // Fallback: assume 40 km/h average
      remainingMinutes = (distToDest / 40 * 60).round();
    }

    // Format remaining distance
    String distStr;
    if (distToDest < 1) {
      distStr = '${(distToDest * 1000).toInt()} m';
    } else {
      distStr = '${distToDest.toStringAsFixed(1)} km';
    }

    // Format ETA
    String etaStr;
    if (remainingMinutes < 1) {
      etaStr = 'Arriving';
    } else if (remainingMinutes >= 60) {
      final h = remainingMinutes ~/ 60;
      final m = remainingMinutes % 60;
      etaStr = '${h}h ${m}m';
    } else {
      etaStr = '$remainingMinutes min';
    }

    setState(() {
      _speedKmh = speedKmh;
      _progress = progress;
      _eta = etaStr;
      _distanceRemaining = distStr;
    });
  }

  /// Calculates distance in km between two points using the Haversine formula.
  double _haversineKm(LatLng a, LatLng b) {
    const r = 6371.0; // Earth radius in km
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);
    final sinLat = math.sin(dLat / 2);
    final sinLon = math.sin(dLon / 2);
    final h = sinLat * sinLat +
        math.cos(_degToRad(a.latitude)) *
            math.cos(_degToRad(b.latitude)) *
            sinLon *
            sinLon;
    return 2 * r * math.asin(math.sqrt(h));
  }

  double _degToRad(double deg) => deg * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideStreamProvider(widget.rideId));
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: rideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 48.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.somethingWentWrong,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Unable to load ride navigation data.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(
                    rideStreamProvider(widget.rideId),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (ride) {
          if (ride == null) {
            return Center(child: Text(l10n.rideNotFound));
          }
          return _buildNavigationView(context, ride, l10n);
        },
      ),
    );
  }

  Widget _buildNavigationView(
    BuildContext context,
    RideModel ride,
    AppLocalizations l10n,
  ) {
    return Stack(
      children: [
        // Map placeholder (replace with actual map widget e.g. google_maps_flutter)
        _buildMapArea(ride),

        // Top bar
        _buildTopBar(context, ride),

        // Bottom panel
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomPanel(context, ride, l10n),
        ),

        // SOS button
        Positioned(
          top: MediaQuery.of(context).padding.top + 60.h,
          right: 16.w,
          child: _buildSOSButton(context),
        ),

        // Share location button
        Positioned(
          top: MediaQuery.of(context).padding.top + 60.h,
          right: 68.w,
          child: _buildShareButton(ride),
        ),
      ],
    );
  }

  Widget _buildMapArea(RideModel ride) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primarySurface.withValues(alpha: 0.5),
            AppColors.primarySurface.withValues(alpha: 0.2),
            AppColors.background,
          ],
        ),
      ),
      child: CustomPaint(
        painter: _MapGridPainter(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated pulsing location indicator
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.all(
                      20.w + (_pulseController.value * 10),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.12 - (_pulseController.value * 0.08),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.navigation_rounded,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20.h),
              if (_currentPosition != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${_currentPosition!.latitude.toStringAsFixed(5)}, '
                    '${_currentPosition!.longitude.toStringAsFixed(5)}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.gps_fixed_rounded,
                      size: 14.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Live Navigation Active',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, RideModel ride) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8.h,
          left: 16.w,
          right: 16.w,
          bottom: 12.h,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0),
            ],
          ),
        ),
        child: Row(
          children: [
            _buildNavButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => context.pop(),
            ),
            SizedBox(width: 12.w),
            // Driver info pill
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DriverAvatarWidget(
                      driverId: ride.driverId,
                      radius: 14,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: DriverNameWidget(
                        driverId: ride.driverId,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 22.sp, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildShareButton(RideModel ride) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        final pos = _currentPosition;
        final locationText = pos != null
            ? 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}'
            : 'Live location not yet available';
        SharePlus.instance.share(
          ShareParams(
            text:
                'Track my SportConnect ride!\n'
                'From: ${ride.origin.address}\n'
                'To: ${ride.destination.address}\n'
                '$locationText',
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.share_location_rounded,
          color: AppColors.primary,
          size: 24.sp,
        ),
      ),
    );
  }

  Widget _buildSOSButton(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.heavyImpact();
        _showSOSDialog(context);
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.sos_rounded, color: Colors.white, size: 24.sp),
      ),
    );
  }

  void _showSOSDialog(BuildContext context) {
    // Determine emergency number based on device locale
    final locale = Localizations.localeOf(context);
    final emergencyNumber = _getEmergencyNumber(locale.countryCode);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency SOS'),
        content: Text(
          'Are you in an emergency? This will call emergency services '
          '($emergencyNumber) and share your live location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              
              final Uri emergencyUri = Uri(scheme: 'tel', path: emergencyNumber);
              try {
                if (await canLaunchUrl(emergencyUri)) {
                  await launchUrl(emergencyUri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot make emergency calls on this device'),
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to launch emergency dialer'),
                    ),
                  );
                }
              }
            },
            child: const Text('Call Emergency'),
          ),
        ],
      ),
    );
  }

  /// Returns the local emergency number based on country code
  String _getEmergencyNumber(String? countryCode) {
    switch (countryCode?.toUpperCase()) {
      case 'US':
      case 'CA':
        return '911';
      case 'GB':
      case 'IE':
        return '999';
      case 'AU':
        return '000';
      case 'NZ':
        return '111';
      case 'JP':
        return '110';
      case 'CN':
        return '110';
      case 'IN':
        return '112';
      case 'BR':
        return '190';
      case 'MX':
        return '911';
      default:
        // 112 is the international standard emergency number
        return '112';
    }
  }

  Widget _buildBottomPanel(
    BuildContext context,
    RideModel ride,
    AppLocalizations l10n,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          // Progress bar
          _buildProgressBar(),
          SizedBox(height: 20.h),

          // ETA and distance
          Row(
            children: [
              _buildInfoTile(
                icon: Icons.access_time_rounded,
                label: 'ETA',
                value: _eta,
                color: AppColors.primary,
              ),
              SizedBox(width: 16.w),
              _buildInfoTile(
                icon: Icons.straighten_rounded,
                label: 'Distance',
                value: _distanceRemaining,
                color: AppColors.warning,
              ),
              SizedBox(width: 16.w),
              _buildInfoTile(
                icon: Icons.speed_rounded,
                label: 'Speed',
                value: '${_speedKmh.toStringAsFixed(0)} km/h',
                color: AppColors.success,
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Route summary
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                _buildMiniRouteRow(
                  Icons.trip_origin_rounded,
                  AppColors.success,
                  ride.origin.address,
                ),
                // Show intermediate waypoints
                for (final wp in ride.route.waypoints)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: _buildMiniRouteRow(
                      Icons.circle,
                      AppColors.warning,
                      wp.location.address,
                    ),
                  ),
                SizedBox(height: 8.h),
                _buildMiniRouteRow(
                  Icons.location_on_rounded,
                  AppColors.error,
                  ride.destination.address,
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: PremiumButton(
                  text: "I've Arrived",
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    _positionSubscription?.cancel();
                    context.pushReplacement(
                      AppRoutes.rideCompletion.path.replaceFirst(
                        ':id',
                        widget.rideId,
                      ),
                    );
                  },
                  icon: Icons.flag_rounded,
                  style: PremiumButtonStyle.success,
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 52.w,
                child: PremiumButton(
                  text: '',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.pop();
                  },
                  style: PremiumButtonStyle.ghost,
                  icon: Icons.close_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(
      begin: 0.3,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trip Progress',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(_progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6.h,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniRouteRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Subtle grid painter to give the map placeholder a spatial feel.
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
