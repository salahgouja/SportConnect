import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/widgets/analytics_payment_widgets.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:sport_connect/features/rides/models/driver_stats.dart';
import 'package:sport_connect/features/rides/view_models/driver_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Driver Earnings Screen  - View earnings with real Firestore data
///
/// Uses [driverStatsProvider] from the rides feature (denormalized aggregate
/// in `driver_stats` collection) for performance — single document read
/// instead of aggregating all payment transactions on-the-fly.
/// The payments feature's [driverEarningsSummaryProvider] computes the same
/// data from the `payments` collection and can be used for reconciliation.
class DriverEarningsScreen extends ConsumerWidget {
  const DriverEarningsScreen({super.key});

  static const List<String> _periodKeys = [
    'today',
    'thisWeek',
    'thisMonth',
    'allTime',
  ];

  String _periodLabel(BuildContext context, String key) {
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
  String _currencyCode(WidgetRef ref) {
    final stripeStatus = ref.watch(driverStripeStatusProvider).value;
    return stripeStatus?.currency ?? 'EUR';
  }

  void _exportEarnings(BuildContext context, WidgetRef ref) {
    final driverState = ref.read(driverViewModelProvider);
    final driverStats = driverState.stats;
    final transactions = driverState.earningsTransactions;

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
        '  ${l10n.periodToday}:      ${stats.earningsToday.toStringAsFixed(2)} ${_currencyCode(ref)}',
      )
      ..writeln(
        '  ${l10n.periodThisWeek}:  ${stats.earningsThisWeek.toStringAsFixed(2)} ${_currencyCode(ref)}',
      )
      ..writeln(
        '  ${l10n.periodThisMonth}: ${stats.earningsThisMonth.toStringAsFixed(2)} ${_currencyCode(ref)}',
      )
      ..writeln(
        '  ${l10n.periodAllTime}:      ${stats.totalEarnings.toStringAsFixed(2)} ${_currencyCode(ref)}',
      )
      ..writeln()
      ..writeln(l10n.exportRideStatistics)
      ..writeln('  ${l10n.statRides}: ${stats.totalRides}')
      ..writeln(
        '  ${l10n.distance}: ${stats.totalDistance.toStringAsFixed(1)} km',
      )
      ..writeln();

    if (txList != null && txList.isNotEmpty) {
      buffer
        ..writeln(l10n.exportRecentTransactions)
        ..writeln('--------------------------------');
      for (final tx in txList.take(20)) {
        final date = dateFormat.format(tx.createdAt);
        buffer.writeln(
          '  $date | ${tx.amount.toStringAsFixed(2)} ${_currencyCode(ref)} | ${tx.description}',
        );
      }
    }

    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverState = ref.watch(driverViewModelProvider);
    final driverStats = driverState.stats;
    final transactions = driverState.earningsTransactions;
    final selectedPeriod = ref
        .watch(driverEarningsPeriodViewModelProvider)
        .selectedPeriod;
    // Watch Stripe status to reactively resolve the driver's currency.
    ref.watch(driverStripeStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          ref.invalidate(driverStripeStatusProvider);
          ref.read(driverViewModelProvider.notifier).refresh();
          await ref.read(driverStripeStatusProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 160.h,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildEarningsHeader(
                  context,
                  ref,
                  driverStats,
                  selectedPeriod,
                ),
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
                  onPressed: () => _exportEarnings(context, ref),
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                ),
              ],
            ),

            // Period Selector
            SliverToBoxAdapter(
              child: _buildPeriodSelector(context, ref, selectedPeriod),
            ),

            // Stats Grid
            SliverToBoxAdapter(
              child: _buildStatsGrid(context, ref, driverStats, selectedPeriod),
            ),

            // Monthly Summary Card
            SliverToBoxAdapter(
              child: driverStats.when(
                data: (stats) => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  child: MonthlyRideSummary(
                    totalRides: stats.totalRides,
                    totalSpent: stats.totalSpent,
                    totalEarned: stats.totalEarnings,
                    totalDistance: stats.totalDistance,
                    month: DateFormat('MMMM yyyy').format(DateTime.now()),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),

            // Earnings Chart
            SliverToBoxAdapter(
              child: _buildEarningsChart(context, driverStats, selectedPeriod),
            ),

            // Monthly cost history chart – from real earnings transactions
            SliverToBoxAdapter(
              child: transactions.when(
                data: (txList) {
                  if (txList.isEmpty) return const SizedBox.shrink();
                  // Group transactions by month and sum amounts
                  final monthlyMap = <String, double>{};
                  for (final tx in txList) {
                    final key = DateFormat('MMM yyyy').format(tx.createdAt);
                    monthlyMap[key] = (monthlyMap[key] ?? 0) + tx.amount;
                  }
                  final monthlyCosts = monthlyMap.entries
                      .map((e) => MonthlyCost(e.key, e.value))
                      .toList();
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 8.h,
                    ),
                    child: RideCostHistoryChart(data: monthlyCosts),
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),

            // Payout Section
            SliverToBoxAdapter(child: _buildPayoutSection(context, ref)),

            // Recent Transactions
            SliverToBoxAdapter(
              child: _buildRecentTransactions(context, ref, transactions),
            ),

            // Bottom Padding
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<DriverStats> statsAsync,
    String selectedPeriod,
  ) {
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
                  _periodLabel(context, selectedPeriod),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  AppLocalizations.of(context).value5(
                    (() {
                      switch (selectedPeriod) {
                        case 'today':
                          return stats.earningsToday;
                        case 'thisWeek':
                          return stats.earningsThisWeek;
                        case 'thisMonth':
                          return stats.earningsThisMonth;
                        default:
                          return stats.totalEarnings;
                      }
                    })().toStringAsFixed(0),
                  ),
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                SizedBox(height: 6.h),
                Text(
                  () {
                    final rides = switch (selectedPeriod) {
                      'thisWeek' => stats.ridesThisWeek,
                      'thisMonth' => stats.ridesThisMonth,
                      _ => stats.totalRides,
                    };
                    return '$rides ${AppLocalizations.of(context).totalRides.toLowerCase()}';
                  }(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
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
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
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
                onPressed: () =>
                    ref.read(driverViewModelProvider.notifier).refresh(),
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

  Widget _buildPeriodSelector(
    BuildContext context,
    WidgetRef ref,
    String selectedPeriod,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: SegmentedButton<String>(
        segments: _periodKeys
            .map(
              (p) => ButtonSegment<String>(
                value: p,
                label: Text(
                  _periodLabel(context, p),
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
              ),
            )
            .toList(),
        selected: {selectedPeriod},
        onSelectionChanged: (value) => ref
            .read(driverEarningsPeriodViewModelProvider.notifier)
            .setPeriod(value.first),
        style: SegmentedButton.styleFrom(
          backgroundColor: AppColors.surface,
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: Colors.white,
          foregroundColor: AppColors.textSecondary,
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<DriverStats> statsAsync,
    String selectedPeriod,
  ) {
    return statsAsync.when(
      data: (stats) {
        double displayEarnings;
        int displayRides;

        switch (selectedPeriod) {
          case 'today':
            displayEarnings = stats.earningsToday;
            displayRides = stats.totalRides;
          case 'thisWeek':
            displayEarnings = stats.earningsThisWeek;
            displayRides = stats.ridesThisWeek;
          case 'thisMonth':
            displayEarnings = stats.earningsThisMonth;
            displayRides = stats.ridesThisMonth;
          default:
            displayEarnings = stats.totalEarnings;
            displayRides = stats.totalRides;
        }

        final avgPerRide = displayRides > 0
            ? '${(displayEarnings / displayRides).toStringAsFixed(0)} ${_currencyCode(ref)}'
            : '— ${_currencyCode(ref)}';

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
                      value: '${displayEarnings.toStringAsFixed(0)} ${_currencyCode(ref)}',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.star_rounded,
                      iconColor: AppColors.starFilled,
                      title: AppLocalizations.of(context).statAvgRating,
                      value: stats.rating > 0
                          ? stats.rating.toStringAsFixed(2)
                          : '—',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.secondary,
                      title: AppLocalizations.of(context).avgPerRide,
                      value: avgPerRide,
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
      error: (_, _) => _buildErrorPlaceholder(context),
    );
  }

  /// Displays a compact error message when earnings data fails to load.
  Widget _buildErrorPlaceholder(BuildContext context) {
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
      child: const Center(
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      ),
    );
  }

  Widget _buildEarningsChart(
    BuildContext context,
    AsyncValue<DriverStats> statsAsync,
    String selectedPeriod,
  ) {
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
            Text(
              AppLocalizations.of(context).earningsOverview,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20.h),
            // Total earnings breakdown
            _buildEarningsBreakdownItem(
              context,
              AppLocalizations.of(context).statEarnings,
              switch (selectedPeriod) {
                'today' => stats.earningsToday,
                'thisWeek' => stats.earningsThisWeek,
                'thisMonth' => stats.earningsThisMonth,
                _ => stats.totalEarnings,
              },
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
                          AppLocalizations.of(context).totalDistance,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${stats.totalDistance.toStringAsFixed(1)} km',
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
        child: const Center(
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
      ),
      error: (_, _) => _buildErrorPlaceholder(context),
    );
  }

  Widget _buildEarningsBreakdownItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
  ) {
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
  Widget _buildPayoutSection(BuildContext context, WidgetRef ref) {
    final user = ref.watch(driverViewModelProvider).user;
    final stripeStatus = ref.watch(driverStripeStatusProvider);

    return user.when(
      data: (userData) {
        if (userData == null) return const SizedBox.shrink();

        return stripeStatus.when(
          data: (status) => _buildPayoutCard(context, ref, status),
          loading: _buildPayoutCardLoading,
          error: (_, _) => _buildPayoutCard(context, ref, null),
        );
      },
      loading: _buildPayoutCardLoading,
      error: (_, _) => _buildErrorPlaceholder(context),
    );
  }

  Widget _buildPayoutCard(
    BuildContext context,
    WidgetRef ref,
    DriverStripeStatus? status,
  ) {
    final isConnected = status?.isConnected ?? false;
    final payoutsEnabled = status?.payoutsEnabled ?? false;
    final availableBalance = status?.availableBalance ?? 0.0;
    final stripeAccountId = status?.stripeAccountId;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Available Balance
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context).availableBalance,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                GestureDetector(
                                  onTap: () async => showDialog<void>(
                                    context: context,
                                    builder: (_) => AlertDialog.adaptive(
                                      title: Text(AppLocalizations.of(context).availableBalance),
                                      content: const Text(
                                        'Available Balance is what Stripe has settled and is ready to withdraw to your bank.\n\n'
                                        'Total Earnings (shown above) is your lifetime trip revenue — some may still be processing through Stripe.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Got it'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    size: 14.sp,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
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
                        onPressed: () => _onWithdrawPressed(
                          context,
                          ref,
                          stripeAccountId: stripeAccountId,
                          availableBalance: availableBalance,
                          isFullySetup: payoutsEnabled,
                        ),
                        style: PremiumButtonStyle.secondary,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Total earnings are trip stats. Withdrawals use settled Stripe balance.',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
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
      child: const Center(
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      ),
    );
  }

  Future<void> _requestPayout(
    BuildContext context,
    WidgetRef ref,
    String stripeAccountId,
    double amount,
  ) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
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
            currency: _currencyCode(ref),
          );

      if (success) {
        if (!context.mounted) return;
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
        ref.read(driverViewModelProvider.notifier).refresh();
      } else {
        if (!context.mounted) return;
        final payoutState = ref.read(driverPayoutViewModelProvider);
        final detailedError = payoutState.hasError
            ? payoutState.error.toString()
            : null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              detailedError ??
                  AppLocalizations.of(context).payoutFailedPleaseTryAgain,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } on Exception catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorValue(e)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _onWithdrawPressed(
    BuildContext context,
    WidgetRef ref, {
    required String? stripeAccountId,
    required double availableBalance,
    required bool isFullySetup,
  }) async {
    if (!isFullySetup) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).completeVerification),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (stripeAccountId == null || stripeAccountId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).tryAgain),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (availableBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noData),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await _requestPayout(context, ref, stripeAccountId, availableBalance);
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    WidgetRef ref,
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
                  currency: _currencyCode(ref),
                  date: DateFormat(
                    'MMM d, h:mm a',
                  ).format(transaction.createdAt),
                  onTap: transaction.type == TransactionType.payout
                      ? () => context.push(
                            AppRoutes.payoutDetail.path
                                .replaceFirst(':id', transaction.id),
                          )
                      : null,
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
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
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
                const Icon(Icons.error_outline, color: AppColors.error),
                SizedBox(width: 12.w),
                Text(
                  AppLocalizations.of(context).failedToLoadTransactions,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

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
  const _TransactionItem({
    required this.description,
    required this.amount,
    required this.type,
    required this.currency,
    required this.date,
    this.onTap,
  });
  final String description;
  final double amount;
  final TransactionType type;
  final String currency;
  final String date;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case TransactionType.ride:
        icon = Icons.directions_car;
        color = AppColors.primary;
      case TransactionType.bonus:
        icon = Icons.star;
        color = AppColors.starFilled;
      case TransactionType.refund:
        icon = Icons.replay;
        color = AppColors.warning;
      case TransactionType.payout:
        icon = Icons.account_balance;
        color = AppColors.success;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(2)} $currency',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: amount >= 0 ? AppColors.success : AppColors.error,
                ),
              ),
              if (onTap != null) ...[
                SizedBox(width: 4.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18.sp,
                  color: AppColors.textTertiary,
                ),
              ],
            ],
          ),
        ],
      ),
      ),
    );
  }
}
