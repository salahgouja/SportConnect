import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';

/// Report Issue screen for reporting ride problems, safety concerns, or users.
///
/// Features:
/// - Issue type selection (Safety, Payment, Behavior, Technical, Other)
/// - Severity level indicator
/// - Ride reference (optional)
/// - Evidence attachment placeholder
/// - Firebase submission
class ReportIssueScreen extends ConsumerStatefulWidget {
  final String? rideId;
  final String? reportedUserId;

  const ReportIssueScreen({super.key, this.rideId, this.reportedUserId});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<File> _attachedFiles = [];
  _ReportType? _selectedType;
  _Severity _severity = _Severity.medium;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  static const _maxAttachments = 5;
  static const _maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    if (_attachedFiles.length >= _maxAttachments) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $_maxAttachments files allowed'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final accepted = await PermissionDialogHelper.showCameraRationale(
      context,
      customMessage:
          'Access to your ${source == ImageSource.camera ? 'camera' : 'photo library'} '
          'is needed to attach screenshots or photos to your '
          'issue report.',
    );
    if (!accepted) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );

    if (picked == null) return;

    final file = File(picked.path);
    final size = await file.length();

    if (size > _maxFileSizeBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('File exceeds 10 MB limit'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    setState(() => _attachedFiles.add(file));
  }

  Future<void> _submitReport() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an issue type'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please describe the issue'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider).value;
      await ref
          .read(profileActionsViewModelProvider)
          .submitReport(
            reporterId: user?.uid ?? 'anonymous',
            reporterEmail: user?.email ?? '',
            type: _selectedType!.label,
            severity: _severity.name,
            description: _descriptionController.text.trim(),
            reportedUserId: widget.reportedUserId,
            rideId: widget.rideId,
            attachments: _attachedFiles,
          );

      if (mounted) {
        HapticFeedback.mediumImpact();
        setState(() {
          _isSubmitting = false;
          _isSubmitted = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to submit report. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Report an Issue',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: _isSubmitted ? _buildSuccessState() : _buildFormState(),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),

        // Ride reference
        if (widget.rideId != null)
          Container(
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  size: 18.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Ride: ${widget.rideId}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

        // Issue type
        Text(
          'What happened?',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 100.ms),

        SizedBox(height: 12.h),

        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _ReportType.values.asMap().entries.map((entry) {
            final type = entry.value;
            final isSelected = _selectedType == type;
            return _buildTypeChip(type, isSelected);
          }).toList(),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 24.h),

        // Severity
        Text(
          'How severe is this issue?',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 300.ms),

        SizedBox(height: 12.h),

        Row(
          children: _Severity.values.map((sev) {
            final isSelected = _severity == sev;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _severity = sev);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? sev.color.withValues(alpha: 0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSelected ? sev.color : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(sev.icon, size: 20.sp, color: sev.color),
                      SizedBox(height: 4.h),
                      Text(
                        sev.label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? sev.color
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ).animate().fadeIn(delay: 350.ms),

        SizedBox(height: 24.h),

        // Description
        Text(
          'Describe the issue',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 400.ms),

        SizedBox(height: 8.h),

        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Please provide as much detail as possible...',
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ).animate().fadeIn(delay: 450.ms),

        SizedBox(height: 24.h),

        // Evidence attachment
        Text(
          'Evidence (optional)',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 470.ms),

        SizedBox(height: 8.h),

        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 32.sp,
                  color: _attachedFiles.isEmpty
                      ? AppColors.textTertiary
                      : AppColors.primary,
                ),
                SizedBox(height: 8.h),
                Text(
                  _attachedFiles.isEmpty
                      ? 'Tap to attach screenshots or evidence'
                      : '${_attachedFiles.length}/$_maxAttachments files attached',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: _attachedFiles.isEmpty
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Supports images (max 10MB each)',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 490.ms),

        if (_attachedFiles.isNotEmpty) ...[
          SizedBox(height: 10.h),
          SizedBox(
            height: 80.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _attachedFiles.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        _attachedFiles[index],
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _attachedFiles.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],

        SizedBox(height: 32.h),

        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: 'Submit Report',
            onPressed: _isSubmitting ? null : _submitReport,
            isLoading: _isSubmitting,
            icon: Icons.flag_rounded,
            style: PremiumButtonStyle.danger,
          ),
        ).animate().fadeIn(delay: 500.ms),

        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildTypeChip(_ReportType type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedType = type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? type.color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? type.color : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 16.sp,
              color: isSelected ? type.color : AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? type.color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        SizedBox(height: 80.h),

        Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 64.sp,
                color: AppColors.success,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.5, 0.5)),

        SizedBox(height: 24.h),

        Text(
          'Report Submitted',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 12.h),

        Text(
          'Thank you for reporting this issue. Our safety team will '
          'review it and take appropriate action within 24-48 hours.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms),

        SizedBox(height: 40.h),

        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: 'Done',
            onPressed: () => context.pop(),
            icon: Icons.check_rounded,
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}

enum _ReportType {
  safety('Safety', Icons.shield_rounded, Color(0xFFF44336)),
  payment('Payment', Icons.payment_rounded, Color(0xFFFF9800)),
  behavior('Behavior', Icons.person_off_rounded, Color(0xFF9C27B0)),
  technical('Technical', Icons.bug_report_rounded, Color(0xFF2196F3)),
  discrimination(
    'Discrimination',
    Icons.do_not_disturb_rounded,
    Color(0xFFE91E63),
  ),
  other('Other', Icons.more_horiz_rounded, Color(0xFF607D8B));

  final String label;
  final IconData icon;
  final Color color;

  const _ReportType(this.label, this.icon, this.color);
}

enum _Severity {
  low('Low', Icons.info_outline_rounded, Color(0xFF4CAF50)),
  medium('Medium', Icons.warning_amber_rounded, Color(0xFFFF9800)),
  high('High', Icons.error_outline_rounded, Color(0xFFF44336)),
  critical('Critical', Icons.dangerous_rounded, Color(0xFF9C27B0));

  final String label;
  final IconData icon;
  final Color color;

  const _Severity(this.label, this.icon, this.color);
}
