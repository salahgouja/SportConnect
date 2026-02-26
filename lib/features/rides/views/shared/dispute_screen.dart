import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/rides/repositories/dispute_repository.dart';

/// Dispute filing screen for ride fare or service disagreements.
class DisputeScreen extends ConsumerStatefulWidget {
  const DisputeScreen({required this.rideId, this.rideSummary, super.key});

  final String rideId;
  final String? rideSummary;

  @override
  ConsumerState<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends ConsumerState<DisputeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<File> _attachedFiles = [];
  String? _selectedDisputeType;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  static const _maxAttachments = 5;
  static const _maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

  static const _disputeTypes = [
    _DisputeType(
      id: 'incorrect_fare',
      icon: Icons.attach_money_rounded,
      title: 'Incorrect Fare',
      description: 'The fare charged was different from the quoted amount',
    ),
    _DisputeType(
      id: 'incomplete_ride',
      icon: Icons.wrong_location_rounded,
      title: 'Incomplete Ride',
      description: 'The ride did not reach the intended destination',
    ),
    _DisputeType(
      id: 'unauthorized_charge',
      icon: Icons.credit_card_off_rounded,
      title: 'Unauthorized Charge',
      description:
          'I was charged without authorization or for a cancelled ride',
    ),
    _DisputeType(
      id: 'poor_service',
      icon: Icons.sentiment_dissatisfied_rounded,
      title: 'Poor Service',
      description: 'The ride quality was unacceptable',
    ),
    _DisputeType(
      id: 'safety_concern',
      icon: Icons.health_and_safety_rounded,
      title: 'Safety Concern',
      description: 'I felt unsafe during the ride',
    ),
    _DisputeType(
      id: 'other',
      icon: Icons.more_horiz_rounded,
      title: 'Other',
      description: 'A different issue not listed above',
    ),
  ];

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
          'is needed to attach evidence to your dispute. '
          'Photos are only uploaded when you submit the dispute.',
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

  Future<void> _submitDispute() async {
    if (!_formKey.currentState!.validate() || _selectedDisputeType == null) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      final repo = ref.read(disputeRepositoryProvider);

      final disputeId = await repo.submitDispute(
        rideId: widget.rideId,
        userId: user.uid,
        userEmail: user.email,
        disputeType: _selectedDisputeType!,
        description: _descriptionController.text.trim(),
        rideSummary: widget.rideSummary,
      );

      if (_attachedFiles.isNotEmpty) {
        await repo.uploadAttachments(
          disputeId: disputeId,
          files: _attachedFiles,
        );
      }

      if (mounted) {
        setState(() {
          _isSubmitted = true;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to submit dispute. Please try again.'),
            backgroundColor: AppColors.error,
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
          'File a Dispute',
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
      body: _isSubmitted ? _buildSuccessView() : _buildFormView(),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 56.sp,
                color: AppColors.success,
              ),
            ).animate().scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),
            SizedBox(height: 24.h),
            Text(
              'Dispute Submitted',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: 12.h),
            Text(
              'Our team will review your dispute within 24-48 hours. '
              "You'll receive a notification once it's resolved.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 300.ms),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        children: [
          SizedBox(height: 16.h),

          // Ride info card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ride ID',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.rideId,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          SizedBox(height: 24.h),

          // Dispute type selection
          Text(
            'Dispute Type',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(delay: 100.ms),
          SizedBox(height: 4.h),
          Text(
            'Select the reason for your dispute',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 150.ms),

          SizedBox(height: 16.h),

          ..._disputeTypes.asMap().entries.map((entry) {
            final index = entry.key;
            final type = entry.value;
            final isSelected = _selectedDisputeType == type.id;

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child:
                  GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDisputeType = type.id),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(
                                          alpha: 0.15,
                                        )
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  type.icon,
                                  size: 20.sp,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      type.title,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      type.description,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 22.sp,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: (200 + index * 50).ms)
                      .slideX(begin: 0.03),
            );
          }),

          if (_selectedDisputeType == null) ...[
            SizedBox(height: 4.h),
            Text(
              'Please select a dispute type',
              style: TextStyle(fontSize: 12.sp, color: Colors.transparent),
            ),
          ],

          SizedBox(height: 20.h),

          // Description
          Text(
            'Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: 'Describe your issue in detail...',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: Colors.white,
              counterStyle: TextStyle(fontSize: 11.sp),
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
              contentPadding: EdgeInsets.all(14.w),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please describe your issue';
              }
              if (value.trim().length < 20) {
                return 'Please provide more detail (at least 20 characters)';
              }
              return null;
            },
          ),

          SizedBox(height: 12.h),

          // Note
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18.sp,
                  color: AppColors.warning,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Disputes are reviewed within 24-48 hours. Submitting '
                    'false disputes may result in account restrictions.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Evidence attachment
          Text(
            'Evidence (optional)',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _pickFiles,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.attach_file_rounded,
                    size: 20.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      _attachedFiles.isEmpty
                          ? 'Attach receipts or screenshots'
                          : '${_attachedFiles.length}/$_maxAttachments files attached',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: _attachedFiles.isEmpty
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.add_circle_outline_rounded,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
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

          SizedBox(height: 20.h),

          // Resolution expectation
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What to expect',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildExpectationRow(
                  Icons.access_time_rounded,
                  'Review within 24-48 hours',
                ),
                SizedBox(height: 6.h),
                _buildExpectationRow(
                  Icons.email_outlined,
                  'Email notification on status updates',
                ),
                SizedBox(height: 6.h),
                _buildExpectationRow(
                  Icons.gavel_rounded,
                  'Fair resolution based on evidence',
                ),
              ],
            ),
          ),

          SizedBox(height: 28.h),

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isSubmitting || _selectedDisputeType == null)
                  ? null
                  : _submitDispute,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.4,
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Submit Dispute',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildExpectationRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.primary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _DisputeType {
  const _DisputeType({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String id;
  final IconData icon;
  final String title;
  final String description;
}
