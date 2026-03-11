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
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// In-app contact support screen with message submission.
///
/// Features:
/// - Subject category selection
/// - Message composition
/// - Ticket submission to Firebase
/// - Previous tickets view
class ContactSupportScreen extends ConsumerStatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  ConsumerState<ContactSupportScreen> createState() =>
      _ContactSupportScreenState();
}

class _ContactSupportScreenState extends ConsumerState<ContactSupportScreen> {
  final _imagePicker = ImagePicker();

  static const _categories = [
    'General',
    'Account Issue',
    'Payment Problem',
    'Ride Issue',
    'Safety Concern',
    'Bug Report',
    'Feature Request',
    'Other',
  ];

  Future<void> _pickFiles() async {
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

    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 80,
    );

    if (picked == null) return;

    await ref
        .read(contactSupportViewModelProvider.notifier)
        .addAttachment(File(picked.path));
  }

  Future<void> _submitTicket() async {
    final user = ref.read(currentUserProvider).value;
    await ref
        .read(contactSupportViewModelProvider.notifier)
        .submitTicket(
          userId: user?.uid ?? 'anonymous',
          userEmail: user?.email ?? '',
          userName: user?.displayName ?? '',
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final supportState = ref.watch(contactSupportViewModelProvider);

    ref.listen(contactSupportViewModelProvider, (previous, next) {
      if (next.isSubmitted && previous?.isSubmitted != true) {
        HapticFeedback.mediumImpact();
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.contactSupport,
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
          child: supportState.isSubmitted
              ? _buildSuccessState()
              : _buildFormState(l10n, supportState),
        ),
      ),
    );
  }

  Widget _buildFormState(
    AppLocalizations l10n,
    ContactSupportState supportState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),

        // Info card
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.support_agent_rounded,
                color: AppColors.primary,
                size: 28.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How can we help?',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'We typically respond within 24 hours.',
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
        ).animate().fadeIn(duration: 300.ms),

        SizedBox(height: 24.h),

        // Category selector
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: supportState.selectedCategory,
              isExpanded: true,
              items: _categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                ref
                    .read(contactSupportViewModelProvider.notifier)
                    .setCategory(value);
              },
            ),
          ),
        ).animate().fadeIn(delay: 100.ms),

        SizedBox(height: 20.h),

        // Subject
        TextField(
          maxLength: 100,
          onChanged: ref
              .read(contactSupportViewModelProvider.notifier)
              .setSubject,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Subject',
            hintText: 'Brief description of your issue',
            prefixIcon: const Icon(Icons.subject_rounded),
            errorText: supportState.subjectError,
          ),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 20.h),

        // Message
        Text(
          'Message',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          maxLines: 6,
          maxLength: 2000,
          onChanged: ref
              .read(contactSupportViewModelProvider.notifier)
              .setMessage,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Describe your issue in detail...',
            errorText: supportState.messageError,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error),
            ),
          ),
        ).animate().fadeIn(delay: 300.ms),

        SizedBox(height: 20.h),

        // Attachment
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.border,
                style: BorderStyle.solid,
              ),
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
                    supportState.attachedFiles.isEmpty
                        ? 'Attach screenshots or files (optional)'
                        : '${supportState.attachedFiles.length}/${ContactSupportViewModel.maxAttachments} files attached',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: supportState.attachedFiles.isEmpty
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
        ).animate().fadeIn(delay: 350.ms),

        if (supportState.attachedFiles.isNotEmpty) ...[
          SizedBox(height: 10.h),
          SizedBox(
            height: 80.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: supportState.attachedFiles.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        supportState.attachedFiles[index],
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: GestureDetector(
                        onTap: () => ref
                            .read(contactSupportViewModelProvider.notifier)
                            .removeAttachmentAt(index),
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
            text: 'Submit Ticket',
            onPressed: supportState.isSubmitting ? null : _submitTicket,
            isLoading: supportState.isSubmitting,
            icon: Icons.send_rounded,
          ),
        ).animate().fadeIn(delay: 400.ms),

        SizedBox(height: 24.h),

        // Response time expectations
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 18.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average response time',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Most inquiries are answered within 12-24 hours',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 450.ms),

        SizedBox(height: 32.h),
      ],
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
          'Ticket Submitted!',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),

        SizedBox(height: 12.h),

        Text(
          'We\'ve received your message and will get back to you '
          'within 24 hours. Check your email for updates.',
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
            text: 'Back to Settings',
            onPressed: () => context.pop(),
            icon: Icons.arrow_back_rounded,
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}
