import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

class RideStatItem extends StatelessWidget {
  const RideStatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.highlight = false,
    super.key,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: highlight ? AppColors.warning : Colors.white,
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.white70),
        ),
      ],
    );
  }
}
