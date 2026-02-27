import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/rides/models/driver_stats.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';

/// Driver Earnings Screen  - View earnings with real Firestore data
///
/// Uses [driverStatsProvider] from the rides feature (denormalized aggregate
/// in `driver_stats` collection) for performance — single document read
/// instead of aggregating all payment transactions on-the-fly.
/// The payments feature's [driverEarningsSummaryProvider] computes the same
/// data from the `payments` collection and can be used for reconciliation.
class DriverEarningsScreen extends ConsumerStatefulWidget {
  const DriverEarningsScreen({super.key});

  @override
  ConsumerState<DriverEarningsScreen> createState() =>
      _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends ConsumerState<DriverEarningsScreen> {
  String _selectedPeriod = 'thisWeek';
  static const List<String> _periodKeys = [
    'today',
    'thisWeek',
    'thisMonth',
    'allTime',
  ];

  String _periodLabel(String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'today':
        return l10n.periodToday;
      case 'thisWeek':
        return l10n.periodThisWeek;
      case 'thisMonth':
        return l10n.periodThisMonth;
      case 'allTime':
        return l10n.periodAllTime;
      default:
        return key;
    }
  }

  /// Resolves the driver's currency code from their Stripe connected account.
  String get _currencyCode {
    final stripeStatus = ref.read(driverStripeStatusProvider).value;
    return stripeStatus?.currency ?? 'EUR';
  }

  void _exportEarnings() {
    final driverStats = ref.read(driverStatsProvider);
    final transactions = ref.read(earningsTransactionsProvider);

    final stats = driverStats.value;
    final txList = transactions.value;

    if (stats == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noData),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final buffer = StringBuffer()
      ..writeln('SportConnect - ${l10n.exportEarningsReport}')
      ..writeln('${l10n.exportGenerated}: $now')
      ..writeln('================================')
      ..writeln()
      ..writeln(l10n.exportEarningsSummary)
      ..writeln(
        '  ${l10n.periodToday}:      ${stats.earningsToday.toStringAsFixed(2)} $_currencyCode',
      )
      ..writeln(
        '  ${l10n.periodThisWeek}:  ${stats.earningsThisWeek.toStringAsFixed(2)} $_currencyCode',
      )
      ..writeln(
        '  ${l10n.periodThisMonth}: ${stats.earningsThisMonth.toStringAsFixed(2)} $_currencyCode',
      )
      ..writeln(
        '  ${l10n.periodAllTime}:      ${stats.totalEarnings.toStringAsFixed(2)} $_currencyCode',
      )
      ..writeln()
      ..writeln(l10n.exportRideStatistics)
      ..writeln('  ${l10n.statRides}: ${stats.totalRides}')
      ..writeln('  CO2:   ${stats.co2Saved.toStringAsFixed(1)} kg')
      ..writeln();

    if (txList != null && txList.isNotEmpty) {
      buffer
        ..writeln(l10n.exportRecentTransactions)
        ..writeln('--------------------------------');
      for (final tx in txList.take(20)) {
        final date = dateFormat.format(tx.createdAt);
        buffer.writeln(
          '  $date | ${tx.amount.toStringAsFixed(2)} $_currencyCode | ${tx.description}',
        );
      }
    }

    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final driverStats = ref.watch(driverStatsProvider);
    final transactions = ref.watch(earningsTransactionsProvider);
    // Watch the Stripe status to reactively resolve the driver's currency.
    ref.watch(driverStripeStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(driverStatsProvider);
          ref.invalidate(earningsTransactionsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 280.h,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildEarningsHeader(driverStats),
              ),
              title: Text(
                AppLocalizations.of(context).earnings,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _exportEarnings,
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                ),
              ],
            ),

            // Period Selector
            SliverToBoxAdapter(child: _buildPeriodSelector()),

            // Stats Grid
            SliverToBoxAdapter(child: _buildStatsGrid(driverStats)),

            // Earnings Chart
            SliverToBoxAdapter(child: _buildEarningsChart(driverStats)),

            // Payout Section
            SliverToBoxAdapter(child: _buildPayoutSection()),

            // Recent Transactions
            SliverToBoxAdapter(child: _buildRecentTransactions(transactions)),

            // Bottom Padding
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsHeader(AsyncValue<DriverStats> statsAsync) {
    return statsAsync.when(
      data: (stats) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  AppLocalizations.of(context).totalEarnings,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(
                    context,
                  ).value5(stats.totalEarnings.toStringAsFixed(0)),
                  style: TextStyle(
                    fontSize: 42.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.successLight,
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        AppLocalizations.of(context).thisWeekValue(
                          stats.earningsThisWeek.toStringAsFixed(0),
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _HeaderStat(
                      value: stats.totalRides.toString(),
                      label: AppLocalizations.of(context).totalRides,
                    ),
                    Container(
                      width: 1,
                      height: 40.h,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    _HeaderStat(
                      value: stats.totalRides > 0
                          ? '${(stats.totalEarnings / stats.totalRides).toStringAsFixed(0)} $_currencyCode'
                          : '0 $_currencyCode',
                      label: AppLocalizations.of(context).avgPerRide,
                    ),
                    Container(
                      width: 1,
                      height: 40.h,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    _HeaderStat(
                      value: '${stats.hoursOnline.toStringAsFixed(0)}h',
                      label: AppLocalizations.of(context).driveTime,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary,
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (_, _) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context).failedToLoadEarnings,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
              SizedBox(height: 12.h),
              TextButton.icon(
                onPressed: () => ref.invalidate(driverStatsProvider),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  AppLocalizations.of(context).tryAgain,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _periodKeys.map((period) {
            final isSelected = period == _selectedPeriod;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => setState(() => _selectedPeriod = period),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    boxShadow: isSelected ? AppSpacing.shadowSm : null,
                  ),
                  child: Text(
                    _periodLabel(period),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(AsyncValue<DriverStats> statsAsync) {
    return statsAsync.when(
      data: (stats) {
        double displayEarnings;
        int displayRides;

        switch (_selectedPeriod) {
          case 'today':
            displayEarnings = stats.earningsToday;
            displayRides = stats.ridesCompleted;
            break;
          case 'thisWeek':
            displayEarnings = stats.earningsThisWeek;
            displayRides = stats.ridesThisWeek;
            break;
          case 'thisMonth':
            displayEarnings = stats.earningsThisMonth;
            displayRides = stats.ridesThisMonth;
            break;
          default:
            displayEarnings = stats.totalEarnings;
            displayRides = stats.totalRides;
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.directions_car_rounded,
                      iconColor: AppColors.primary,
                      title: AppLocalizations.of(context).statRides,
                      value: displayRides.toString(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.attach_money_rounded,
                      iconColor: AppColors.success,
                      title: AppLocalizations.of(context).statEarnings,
                      value:
                          '${displayEarnings.toStringAsFixed(0)} $_currencyCode',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer_outlined,
                      iconColor: AppColors.warning,
                      title: AppLocalizations.of(context).statOnlineHours,
                      value: '${stats.hoursOnlineThisWeek.toStringAsFixed(1)}h',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.star_rounded,
                      iconColor: AppColors.starFilled,
                      title: AppLocalizations.of(context).statAvgRating,
                      value: stats.rating > 0
                          ? stats.rating.toStringAsFixed(2)
                          : '-',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildLoadingStatCard()),
                SizedBox(width: 12.w),
                Expanded(child: _buildLoadingStatCard()),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(child: _buildLoadingStatCard()),
                SizedBox(width: 12.w),
                Expanded(child: _buildLoadingStatCard()),
              ],
            ),
          ],
        ),
      ),
      error: (_, _) => _buildErrorPlaceholder(),
    );
  }

  /// Displays a compact error message when earnings data fails to load.
  Widget _buildErrorPlaceholder() {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              AppLocalizations.of(context).unableToLoadData,
              style: TextStyle(fontSize: 13.sp, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatCard() {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildEarningsChart(AsyncValue<DriverStats> statsAsync) {
    return statsAsync.when(
      data: (stats) => Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: AppSpacing.shadowMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).earningsOverview,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14.sp,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppLocalizations.of(context).active,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // Total earnings breakdown
            _buildEarningsBreakdownItem(
              AppLocalizations.of(context).statEarnings,
              stats.totalEarnings,
              AppColors.primary,
            ),
            SizedBox(height: 20.h),
            // CO2 Impact
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.eco, color: AppColors.success, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).environmentalImpact,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).valueKgCoSaved(stats.co2Saved.toStringAsFixed(1)),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
      loading: () => Container(
        margin: EdgeInsets.all(20.w),
        height: 200.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildEarningsBreakdownItem(String label, double amount, Color color) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ),
        Text(
          AppLocalizations.of(context).value5(amount.toStringAsFixed(0)),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Build the payout section with Stripe integration
  Widget _buildPayoutSection() {
    final user = ref.watch(currentUserProvider);
    final stripeStatus = ref.watch(driverStripeStatusProvider);

    return user.when(
      data: (userData) {
        if (userData == null) return const SizedBox.shrink();

        return stripeStatus.when(
          data: (status) => _buildPayoutCard(status, userData.uid),
          loading: () => _buildPayoutCardLoading(),
          error: (_, _) => _buildPayoutCard(null, userData.uid),
        );
      },
      loading: () => _buildPayoutCardLoading(),
      error: (_, _) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildPayoutCard(DriverStripeStatus? status, String userId) {
    final bool isConnected = status?.isConnected ?? false;
    final bool payoutsEnabled = status?.payoutsEnabled ?? false;
    final double availableBalance = status?.availableBalance ?? 0.0;
    final String? stripeAccountId = status?.stripeAccountId;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: isConnected
            ? LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.1),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isConnected
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isConnected ? Icons.account_balance_wallet : Icons.link,
                  color: isConnected ? AppColors.success : AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected
                          ? AppLocalizations.of(context).stripeConnected
                          : AppLocalizations.of(context).setUpPayouts,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isConnected
                          ? (payoutsEnabled
                                ? AppLocalizations.of(
                                    context,
                                  ).receivePaymentsFromRiders
                                : AppLocalizations.of(
                                    context,
                                  ).completeVerification)
                          : AppLocalizations.of(context).connectYourBankAccount,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isConnected)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        AppLocalizations.of(context).active,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (isConnected && payoutsEnabled) ...[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).availableBalance,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).value5(availableBalance.toStringAsFixed(2)),
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PremiumButton(
                    text: AppLocalizations.of(context).withdraw,
                    onPressed: availableBalance > 0 && stripeAccountId != null
                        ? () => _requestPayout(
                            userId,
                            stripeAccountId,
                            availableBalance,
                            isFullySetup: payoutsEnabled,
                          )
                        : null,
                    style: PremiumButtonStyle.secondary,
                  ),
                ],
              ),
            ),
          ],
          if (!isConnected) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: PremiumButton(
                text: AppLocalizations.of(context).connectStripeAccount,
                onPressed: () =>
                    context.push(AppRoutes.driverStripeOnboarding.path),
                style: PremiumButtonStyle.primary,
              ),
            ),
          ],
          if (isConnected && !payoutsEnabled) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: PremiumButton(
                text: AppLocalizations.of(context).completeVerification,
                onPressed: () =>
                    context.push(AppRoutes.driverStripeOnboarding.path),
                style: PremiumButtonStyle.primary,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildPayoutCardLoading() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 120.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Future<void> _requestPayout(
    String userId,
    String stripeAccountId,
    double amount, {
    bool isFullySetup = true,
  }) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(AppLocalizations.of(context).confirmPayout),
        content: Text(
          AppLocalizations.of(
            context,
          ).withdrawValueToYourConnected(amount.toStringAsFixed(2)),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(AppLocalizations.of(context).withdraw),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await ref
          .read(driverPayoutViewModelProvider.notifier)
          .requestInstantPayout(
            stripeAccountId: stripeAccountId,
            amount: amount,
            currency: _currencyCode,
          );

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).payoutOfValueInitiated(amount.toStringAsFixed(2)),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        ref.invalidate(driverStripeStatusProvider);
        ref.invalidate(earningsTransactionsProvider);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).payoutFailedPleaseTryAgain,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorValue(e)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildRecentTransactions(
    AsyncValue<List<EarningsTransaction>> transactionsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            AppLocalizations.of(context).recentTransactions,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        transactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(30.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 40.sp,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      AppLocalizations.of(context).noTransactionsYet,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _TransactionItem(
                  description: transaction.description,
                  amount: transaction.amount,
                  type: transaction.type,
                  date: DateFormat(
                    'MMM d, h:mm a',
                  ).format(transaction.createdAt),
                ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
              },
            );
          },
          loading: () => Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            height: 100.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (_, _) => Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error),
                SizedBox(width: 12.w),
                Text(
                  AppLocalizations.of(context).failedToLoadTransactions,
                  style: TextStyle(color: AppColors.error),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String description;
  final double amount;
  final String type;
  final String date;

  const _TransactionItem({
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case 'ride':
        icon = Icons.directions_car;
        color = AppColors.primary;
        break;
      case 'bonus':
        icon = Icons.star;
        color = AppColors.starFilled;
        break;
      case 'refund':
        icon = Icons.replay;
        color = AppColors.warning;
        break;
      case 'payout':
        icon = Icons.account_balance;
        color = AppColors.success;
        break;
      default:
        icon = Icons.receipt;
        color = AppColors.textSecondary;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            AppLocalizations.of(
              context,
            ).valueValue3(amount >= 0 ? '+' : '', amount.toStringAsFixed(0)),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: amount >= 0 ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
