import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

/// Auto safety check-in widget (#69)
class SafetyCheckInBanner extends StatelessWidget {
  final VoidCallback onCheckIn;
  final int minutesSinceLastCheckIn;

  const SafetyCheckInBanner({
    super.key,
    required this.onCheckIn,
    this.minutesSinceLastCheckIn = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = minutesSinceLastCheckIn > 15;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isOverdue
            ? AppColors.warning.withValues(alpha: 0.08)
            : AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isOverdue
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.success.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.security_rounded,
            size: 24.sp,
            color: isOverdue ? AppColors.warning : AppColors.success,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue ? 'Safety check-in overdue' : 'Safety check-in',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  isOverdue
                      ? 'Last checked in $minutesSinceLastCheckIn min ago'
                      : 'Let your contacts know you\'re safe',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onCheckIn();
            },
            child: const Text('I\'m OK'),
          ),
        ],
      ),
    );
  }
}

/// Incident report flow (#70)
class IncidentReportSheet extends StatefulWidget {
  final String rideId;
  final ValueChanged<IncidentReport> onSubmit;

  const IncidentReportSheet({
    super.key,
    required this.rideId,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required String rideId,
    required ValueChanged<IncidentReport> onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierLabel: 'Report incident',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: IncidentReportSheet(rideId: rideId, onSubmit: onSubmit),
      ),
    );
  }

  @override
  State<IncidentReportSheet> createState() => _IncidentReportSheetState();
}

class _IncidentReportSheetState extends State<IncidentReportSheet> {
  IncidentType? _selectedType;
  final _descriptionController = TextEditingController();
  IncidentSeverity _severity = IncidentSeverity.low;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Report an Incident',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          // Type selection
          Text(
            'Type of incident',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: IncidentType.values.map((type) {
              final selected = type == _selectedType;
              return ChoiceChip(
                label: Text(type.label),
                selected: selected,
                onSelected: (v) => setState(() => _selectedType = type),
                avatar: Icon(type.icon, size: 16.sp),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
          // Severity
          Text(
            'Severity',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          SegmentedButton<IncidentSeverity>(
            segments: IncidentSeverity.values
                .map((s) => ButtonSegment(value: s, label: Text(s.label)))
                .toList(),
            selected: {_severity},
            onSelectionChanged: (s) => setState(() => _severity = s.first),
          ),
          SizedBox(height: 16.h),
          // Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Describe what happened...',
              alignLabelWithHint: true,
            ),
          ),
          SizedBox(height: 20.h),
          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedType == null
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      widget.onSubmit(
                        IncidentReport(
                          rideId: widget.rideId,
                          type: _selectedType!,
                          severity: _severity,
                          description: _descriptionController.text.trim(),
                        ),
                      );
                      Navigator.pop(context);
                    },
              child: const Text('Submit Report'),
            ),
          ),
        ],
      ),
    );
  }
}

enum IncidentType {
  unsafeDriving('Unsafe Driving', Icons.speed_rounded),
  harassment('Harassment', Icons.report_gmailerrorred_rounded),
  routeDeviation('Route Deviation', Icons.wrong_location_rounded),
  vehicleIssue('Vehicle Issue', Icons.car_crash_rounded),
  noShow('No-Show', Icons.person_off_rounded),
  other('Other', Icons.more_horiz_rounded);

  final String label;
  final IconData icon;
  const IncidentType(this.label, this.icon);
}

enum IncidentSeverity {
  low('Low'),
  medium('Medium'),
  high('High');

  final String label;
  const IncidentSeverity(this.label);
}

class IncidentReport {
  final String rideId;
  final IncidentType type;
  final IncidentSeverity severity;
  final String description;

  const IncidentReport({
    required this.rideId,
    required this.type,
    required this.severity,
    required this.description,
  });
}

/// Drive history transparency card (#71)
class DriveHistoryCard extends StatelessWidget {
  final int totalRides;
  final double averageRating;
  final int cancelCount;
  final int noShowCount;
  final DateTime memberSince;
  final bool isVerified;

  const DriveHistoryCard({
    super.key,
    required this.totalRides,
    required this.averageRating,
    required this.cancelCount,
    required this.noShowCount,
    required this.memberSince,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = DateTime.now().difference(memberSince).inDays ~/ 30;
    final reliability = totalRides > 0
        ? ((totalRides - cancelCount - noShowCount) / totalRides * 100).round()
        : 100;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 20.sp, color: AppColors.info),
              SizedBox(width: 8.w),
              Text(
                'Driver History',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isVerified)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 14.sp,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _statBadge(
                context,
                '$totalRides',
                'Rides',
                Icons.directions_car_rounded,
              ),
              SizedBox(width: 8.w),
              _statBadge(
                context,
                averageRating.toStringAsFixed(1),
                'Rating',
                Icons.star_rounded,
              ),
              SizedBox(width: 8.w),
              _statBadge(
                context,
                '$reliability%',
                'Reliable',
                Icons.verified_user_rounded,
              ),
              SizedBox(width: 8.w),
              _statBadge(
                context,
                '${months}mo',
                'Member',
                Icons.calendar_month_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.primary),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
