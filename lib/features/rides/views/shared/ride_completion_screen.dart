import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/pdf_receipt_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Ride Completion / Trip Summary screen shown after a ride finishes.
///
/// Displays:
/// - Success confetti-style header
/// - Route summary with origin/destination
/// - Trip duration, distance, and CO2 saved
/// - Fare breakdown (base, service fee, total)
/// - Driver/rider info with avatar and rating
/// - Share receipt
/// - Rating & review CTA
class RideCompletionScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RideCompletionScreen({super.key, required this.rideId});

  @override
  ConsumerState<RideCompletionScreen> createState() =>
      _RideCompletionScreenState();
}

class _RideCompletionScreenState extends ConsumerState<RideCompletionScreen> {
  bool _isGeneratingPdf = false;

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
                  'Unable to load ride completion details.',
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
          return _buildContent(context, ref, ride, l10n);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    RideModel ride,
    AppLocalizations l10n,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),

            // Success header
            _buildSuccessHeader(context)
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            SizedBox(height: 24.h),

            // Environmental impact card
            _buildImpactCard(
              context,
              ride,
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05),

            SizedBox(height: 16.h),

            // Trip summary card
            _buildTripSummaryCard(
              context,
              ride,
              dateFormat,
              timeFormat,
              l10n,
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05),

            SizedBox(height: 16.h),

            // Fare breakdown card
            _buildFareBreakdownCard(
              context,
              ride,
              l10n,
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05),

            SizedBox(height: 16.h),

            // Driver/Rider info card
            _buildParticipantCard(
              context,
              ref,
              ride,
              l10n,
            ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05),

            SizedBox(height: 32.h),

            // Action buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: PremiumButton(
                      text: 'Rate & Review',
                      onPressed: () async {
                        HapticFeedback.mediumImpact();

                        // Fetch driver profile to get name for review screen
                        final driverProfile = await ref.read(
                          userProfileProvider(ride.driverId).future,
                        );

                        if (!context.mounted) return;

                        context.push(
                          '${AppRoutes.submitReview.path}'
                          '?rideId=${widget.rideId}'
                          '&revieweeId=${ride.driverId}'
                          '&revieweeName=${Uri.encodeComponent(driverProfile?.displayName ?? 'Driver')}'
                          '&type=driver',
                        );
                      },
                      icon: Icons.star_rounded,
                    ),
                  ).animate().fadeIn(delay: 550.ms),

                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                        child: _isGeneratingPdf
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            : PremiumButton(
                                text: 'Share Receipt',
                                onPressed: () async {
                                  HapticFeedback.lightImpact();
                                  await _shareReceipt(context, ref, ride);
                                },
                                style: PremiumButtonStyle.secondary,
                                icon: Icons.receipt_long_rounded,
                              ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: PremiumButton(
                          text: 'Report Issue',
                          onPressed: () {
                            context.push(
                              '${AppRoutes.reportIssue.path}?rideId=${widget.rideId}',
                            );
                          },
                          style: PremiumButtonStyle.ghost,
                          icon: Icons.flag_outlined,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 650.ms),

                  SizedBox(height: 16.h),

                  TextButton(
                    onPressed: () => context.go(AppRoutes.home.path),
                    child: Text(
                      l10n.goHome,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).animate().fadeIn(delay: 750.ms),
                ],
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Future<void> _shareReceipt(
    BuildContext context,
    WidgetRef ref,
    RideModel ride,
  ) async {
    // Show loading indicator
    setState(() => _isGeneratingPdf = true);

    try {
      // Fetch driver profile to get name
      final driverProfile = await ref.read(
        userProfileProvider(ride.driverId).future,
      );

      final driverName = driverProfile?.displayName ?? 'Driver';
      final driverPhone = driverProfile?.phoneNumber;

      // Get current user for passenger name
      final currentUser = ref.read(currentUserProvider).value;
      final passengerName = currentUser?.displayName;

      final baseFare = ride.pricePerSeat;
      final serviceFee = (baseFare * 0.10).roundToDouble();

      // Generate PDF receipt
      final pdfBytes = await PdfReceiptService.instance.generateRideReceipt(
        rideId: ride.id,
        fromAddress: ride.origin.address,
        toAddress: ride.destination.address,
        departureTime: ride.departureTime,
        completedTime: DateTime.now(),
        driverName: driverName,
        driverPhone: driverPhone,
        pricePerSeat: ride.pricePerSeat,
        seatsBooked: 1,
        serviceFee: serviceFee,
        passengerName: passengerName,
      );

      // Share the PDF
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'SportConnect_Receipt_${ride.id.substring(0, 8)}.pdf',
      );
    } catch (e) {
      // Fallback to text receipt
      final driverProfile = await ref.read(
        userProfileProvider(ride.driverId).future,
      );
      final driverName = driverProfile?.displayName ?? 'Driver';
      final baseFare = ride.pricePerSeat;
      final serviceFee = (baseFare * 0.10).roundToDouble();
      final total = baseFare + serviceFee;

      final receipt =
          '''SportConnect - Trip Receipt
${'=' * 30}
From: ${ride.origin.address}
To: ${ride.destination.address}
Date: ${DateFormat('MMM d, yyyy h:mm a').format(ride.departureTime)}
Driver: $driverName

Base Fare: €${baseFare.toStringAsFixed(2)}
Service Fee: €${serviceFee.toStringAsFixed(2)}
Total: €${total.toStringAsFixed(2)}
${'=' * 30}
Ride ID: ${ride.id}''';

      await SharePlus.instance.share(ShareParams(text: receipt));
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Widget _buildSuccessHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withValues(alpha: 0.15),
                AppColors.success.withValues(alpha: 0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 64.sp,
            color: AppColors.success,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Trip Completed!',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Thanks for riding with SportConnect',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildImpactCard(BuildContext context, RideModel ride) {
    // Estimate: carpooling saves ~120g CO2/km on average
    final riders = ride.bookings.length.clamp(1, 10);
    final co2SavedKg = (riders * 0.12 * 15).toStringAsFixed(1); // ~15km avg

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF43A047).withValues(alpha: 0.12),
            const Color(0xFF66BB6A).withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF43A047).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.eco_rounded,
              size: 24.sp,
              color: const Color(0xFF2E7D32),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You helped save $co2SavedKg kg CO₂',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'By sharing this ride with $riders other '
                  '${riders == 1 ? 'person' : 'people'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripSummaryCard(
    BuildContext context,
    RideModel ride,
    DateFormat dateFormat,
    DateFormat timeFormat,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Summary',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          // Route
          _buildRouteRow(
            Icons.trip_origin_rounded,
            AppColors.success,
            ride.origin.address,
          ),
          _buildRouteLine(),
          _buildRouteRow(
            Icons.location_on_rounded,
            AppColors.error,
            ride.destination.address,
          ),

          Divider(height: 28.h, color: AppColors.border),

          // Stats row
          Row(
            children: [
              _buildStatItem(
                Icons.calendar_today_rounded,
                dateFormat.format(ride.departureTime),
                'Date',
              ),
              _buildStatDivider(),
              _buildStatItem(
                Icons.access_time_rounded,
                timeFormat.format(ride.departureTime),
                'Time',
              ),
              _buildStatDivider(),
              _buildStatItem(
                Icons.people_rounded,
                '${ride.bookings.length}',
                'Riders',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteLine() {
    return Padding(
      padding: EdgeInsets.only(left: 9.w),
      child: Container(height: 24.h, width: 2, color: AppColors.border),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 32.h, width: 1, color: AppColors.border);
  }

  Widget _buildFareBreakdownCard(
    BuildContext context,
    RideModel ride,
    AppLocalizations l10n,
  ) {
    final baseFare = ride.pricePerSeat;
    final serviceFee = (baseFare * 0.10).roundToDouble();
    final total = baseFare + serviceFee;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fare Breakdown',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'PAID',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildFareRow('Base Fare', '€${baseFare.toStringAsFixed(2)}'),
          SizedBox(height: 8.h),
          _buildFareRow(
            'Service Fee (10%)',
            '€${serviceFee.toStringAsFixed(2)}',
          ),
          Divider(height: 24.h),
          _buildFareRow('Total', '€${total.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 18.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantCard(
    BuildContext context,
    WidgetRef ref,
    RideModel ride,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DriverInfoWidget(
        driverId: ride.driverId,
        builder: (context, displayName, photoUrl, rating) {
          return Row(
            children: [
              PremiumAvatar(imageUrl: photoUrl, name: displayName, size: 48),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16.sp,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${rating.average.toStringAsFixed(1)} rating',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Message driver',
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  final currentUser = ref.read(currentUserProvider).value;
                  if (currentUser == null) return;

                  try {
                    final chat = await ref.read(
                      getOrCreateChatProvider(
                        userId1: currentUser.uid,
                        userId2: ride.driverId,
                        userName1: currentUser.displayName,
                        userName2: displayName,
                        userPhoto1: currentUser.photoUrl,
                        userPhoto2: photoUrl,
                      ).future,
                    );

                    if (!context.mounted) return;

                    final driverUser = UserModel.driver(
                      uid: ride.driverId,
                      email: '',
                      displayName: displayName,
                      photoUrl: photoUrl,
                    );

                    context.pushNamed(
                      AppRoutes.chatDetail.name,
                      pathParameters: {'id': chat.id},
                      extra: driverUser,
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Failed to open chat. Please try again.',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primarySurface,
                ),
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
