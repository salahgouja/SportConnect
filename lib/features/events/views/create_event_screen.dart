import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';

/// Full-screen event creation — navigated to via GoRouter.
/// Returns [EventModel] via context.pop(created) on success.
///
/// Add to your router:
/// ```dart
/// GoRoute(
///   path: AppRoutes.createEvent.path,   // e.g. '/events/create'
///   parentNavigatorKey: rootNavigatorKey,
///   pageBuilder: (context, state) => SlideUpTransitionPage(
///     key: state.pageKey,
///     child: const CreateEventScreen(),
///   ),
/// ),
/// ```
class CreateEventScreen extends ConsumerWidget {
  const CreateEventScreen({super.key});

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createState = ref.watch(createEventFormViewModelProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen(createEventFormViewModelProvider, (previous, next) {
      if (next.error != null &&
          next.error != previous?.error &&
          context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }

      if (next.warningMessage != null &&
          next.warningMessage != previous?.warningMessage &&
          context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.warningMessage!)));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            size: 22.sp,
            color: AppColors.textSecondary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.createEventTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
        children: [
          _buildSportTypeSelector(ref, createState, l10n),
          SizedBox(height: 20.h),
          _buildTitleField(ref, createState, l10n),
          SizedBox(height: 14.h),
          _buildVenueField(ref, createState, l10n),
          SizedBox(height: 14.h),
          _buildDescriptionField(ref, createState, l10n),
          SizedBox(height: 20.h),
          _buildImagePicker(ref, createState, l10n),
          SizedBox(height: 20.h),
          _buildLocationPicker(context, ref, createState, l10n),
          SizedBox(height: 20.h),
          _buildWhenSection(context, ref, createState, l10n),
          SizedBox(height: 20.h),
          _buildParticipantSlider(ref, createState, l10n),
          SizedBox(height: 20.h),
          _buildParkingInfoField(ref, createState, l10n),
          SizedBox(height: 20.h),
          _buildRecurringToggle(context, ref, createState, l10n),
          SizedBox(height: 20.h),
          _buildCostSplitToggle(ref, createState, l10n),
          SizedBox(height: 32.h),
          _buildSubmitButton(context, ref, createState, l10n),
        ],
      ),
    );
  }

  // ── Sport type ───────────────────────────────────────────────
  Widget _buildSportTypeSelector(
    WidgetRef ref,
    CreateEventFormState createState,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.eventSportType),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: EventType.values.map((type) {
            final active = createState.type == type;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ref
                    .read(createEventFormViewModelProvider.notifier)
                    .setType(type);
              },
              child: AnimatedContainer(
                duration: 150.ms,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: active
                      ? type.color.withValues(alpha: 0.13)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: active ? type.color : AppColors.border,
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(type.icon, size: 14.sp, color: type.color),
                    SizedBox(width: 6.w),
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? type.color : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }

  // ── Fields ───────────────────────────────────────────────────
  Widget _buildTitleField(
    WidgetRef ref,
    CreateEventFormState createState,
    AppLocalizations l10n,
  ) {
    return TextFormField(
      initialValue: createState.title,
      textCapitalization: TextCapitalization.words,
      maxLength: 100,
      onChanged: ref.read(createEventFormViewModelProvider.notifier).setTitle,
      decoration: _deco(l10n.eventTitleField, Icons.title_rounded).copyWith(
        errorText: createState.hasAttemptedSubmit
            ? createState.titleError
            : null,
      ),
    ).animate().fadeIn(duration: 250.ms, delay: 60.ms);
  }

  Widget _buildVenueField(
    WidgetRef ref,
    CreateEventFormState createState,
    AppLocalizations l10n,
  ) {
    return TextFormField(
      initialValue: createState.venueName,
      textCapitalization: TextCapitalization.words,
      onChanged: ref
          .read(createEventFormViewModelProvider.notifier)
          .setVenueName,
      decoration: _deco(l10n.eventVenueName, Icons.stadium_rounded),
    ).animate().fadeIn(duration: 250.ms, delay: 100.ms);
  }

  Widget _buildDescriptionField(
    WidgetRef ref,
    CreateEventFormState createState,
    AppLocalizations l10n,
  ) {
    return TextFormField(
      initialValue: createState.description,
      maxLines: 3,
      minLines: 2,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      onChanged: ref
          .read(createEventFormViewModelProvider.notifier)
          .setDescription,
      decoration: _deco(l10n.eventDescriptionField, Icons.notes_rounded),
    ).animate().fadeIn(duration: 250.ms, delay: 140.ms);
  }

  // ── Cover Image ──────────────────────────────────────────────
  Widget _buildImagePicker(
    WidgetRef ref,
    CreateEventFormState createState,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.eventCoverImage),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _pickImage(ref),
          child: Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              image: createState.imageFile != null
                  ? DecorationImage(
                      image: FileImage(createState.imageFile!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: createState.imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 36.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.eventTapToAddPhoto,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: CircleAvatar(
                        radius: 16.r,
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () => ref
                              .read(createEventFormViewModelProvider.notifier)
                              .setImageFile(null),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 160.ms);
  }

  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      ref
          .read(createEventFormViewModelProvider.notifier)
          .setImageFile(File(image.path));
    }
  }

  // ── Location ─────────────────────────────────────────────────
  Widget _buildLocationPicker(
    BuildContext context,
    WidgetRef ref,
    CreateEventFormState createState,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.eventLocationField),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _pickLocation(context, ref, l10n),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: createState.location != null
                    ? AppColors.success
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  createState.location != null
                      ? Icons.check_circle_rounded
                      : Icons.location_on_outlined,
                  size: 20.sp,
                  color: createState.location != null
                      ? AppColors.success
                      : AppColors.textTertiary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    createState.location?.address ??
                        l10n.eventTapToPickLocation,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: createState.location != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
        if (createState.hasAttemptedSubmit && createState.locationError != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: _sectionError(createState.locationError!),
          ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 180.ms);
  }

  // ── When ─────────────────────────────────────────────────────
  Widget _buildWhenSection(
    BuildContext context,
    WidgetRef ref,
    CreateEventFormState createState,
    AppLocalizations l10n,
  ) {
    final df = DateFormat('EEE, MMM d');
    final tf = DateFormat('h:mm a');
    final whenError = createState.startsAtError ?? createState.endsAtError;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.eventWhenField),
        SizedBox(height: 8.h),
        // Start row
        Row(
          children: [
            Expanded(
              child: _dateTile(
                icon: Icons.calendar_today_rounded,
                label: l10n.eventStartDate,
                value: df.format(createState.startsAt),
                onTap: () =>
                    _pickDate(context, ref, createState, isStart: true),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _dateTile(
                icon: Icons.access_time_rounded,
                label: l10n.eventStartTime,
                value: tf.format(createState.startsAt),
                onTap: () =>
                    _pickTime(context, ref, createState, isStart: true),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        // End row (optional)
        Row(
          children: [
            Expanded(
              child: _dateTile(
                icon: Icons.event_rounded,
                label: l10n.eventEndDate,
                value: createState.endsAt != null
                    ? df.format(createState.endsAt!)
                    : l10n.eventOptional,
                onTap: () =>
                    _pickDate(context, ref, createState, isStart: false),
                muted: createState.endsAt == null,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _dateTile(
                icon: Icons.access_time_rounded,
                label: l10n.eventEndTime,
                value: createState.endsAt != null
                    ? tf.format(createState.endsAt!)
                    : l10n.eventOptional,
                onTap: () =>
                    _pickTime(context, ref, createState, isStart: false),
                muted: createState.endsAt == null,
              ),
            ),
          ],
        ),
        if (createState.hasAttemptedSubmit && whenError != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: _sectionError(whenError),
          ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 220.ms);
  }

  Widget _dateTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool muted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15.sp, color: AppColors.textTertiary),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: muted
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
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

  // ── Participants ──────────────────────────────────────────────
  Widget _buildParticipantSlider(
    WidgetRef ref,
    CreateEventFormState createState,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _label(l10n.eventMaxParticipants),
            const Spacer(),
            Text(
              createState.participantLabel,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: createState.type.color,
              ),
            ),
          ],
        ),
        Slider(
          value: createState.maxParticipants.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          activeColor: createState.type.color,
          onChanged: (value) => ref
              .read(createEventFormViewModelProvider.notifier)
              .setMaxParticipants(value.round()),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 260.ms);
  }

  // ── Parking Info ───────────────────────────────────────────
  Widget _buildParkingInfoField(
    WidgetRef ref,
    CreateEventFormState createState,
    AppLocalizations l10n,
  ) {
    return TextFormField(
      initialValue: createState.parkingInfo,
      maxLines: 2,
      minLines: 1,
      maxLength: 300,
      textCapitalization: TextCapitalization.sentences,
      onChanged: ref
          .read(createEventFormViewModelProvider.notifier)
          .setParkingInfo,
      decoration: _deco(
        l10n.eventParkingInstructions,
        Icons.local_parking_rounded,
      ),
    ).animate().fadeIn(duration: 250.ms, delay: 270.ms);
  }

  // ── Recurring Toggle + Day Selector ──────────────────────────
  Widget _buildRecurringToggle(
    BuildContext context,
    WidgetRef ref,
    CreateEventFormState createState,
    AppLocalizations l10n,
  ) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          value: createState.isRecurring,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            ref
                .read(createEventFormViewModelProvider.notifier)
                .setIsRecurring(v);
          },
          title: Text(
            l10n.eventRecurring,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            l10n.eventRecurringSubtitle,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          secondary: Icon(
            Icons.repeat_rounded,
            size: 22.sp,
            color: AppColors.primary,
          ),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
        if (createState.isRecurring) ...[
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final day = i + 1; // 1=Mon .. 7=Sun
              final selected = createState.recurringDays.contains(day);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref
                      .read(createEventFormViewModelProvider.notifier)
                      .toggleRecurringDay(day);
                },
                child: AnimatedContainer(
                  duration: 150.ms,
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayLabels[i],
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => _pickRecurringEndDate(context, ref, createState),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_repeat_rounded,
                    size: 18.sp,
                    color: AppColors.textTertiary,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    createState.recurringEndDate != null
                        ? l10n.eventRepeatsUntil(
                            DateFormat(
                              'MMM d, y',
                            ).format(createState.recurringEndDate!),
                          )
                        : l10n.eventRepeatEndDate,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: createState.recurringEndDate != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (createState.hasAttemptedSubmit &&
            createState.recurringError != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: _sectionError(createState.recurringError!),
          ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 280.ms);
  }

  Future<void> _pickRecurringEndDate(
    BuildContext context,
    WidgetRef ref,
    CreateEventFormState createState,
  ) async {
    final now = DateTime.now();
    final initialDate =
        createState.recurringEndDate ??
        DateTime(
          createState.startsAt.year,
          createState.startsAt.month,
          createState.startsAt.day,
        ).add(const Duration(days: 30));
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: initialDate.isBefore(now) ? now : initialDate,
    );
    if (date != null && context.mounted) {
      ref
          .read(createEventFormViewModelProvider.notifier)
          .setRecurringEndDate(date);
    }
  }

  // ── Cost Split Toggle ────────────────────────────────────────
  Widget _buildCostSplitToggle(
    WidgetRef ref,
    CreateEventFormState createState,
    AppLocalizations l10n,
  ) {
    return SwitchListTile.adaptive(
      value: createState.costSplitEnabled,
      onChanged: (v) {
        HapticFeedback.selectionClick();
        ref
            .read(createEventFormViewModelProvider.notifier)
            .setCostSplitEnabled(v);
      },
      title: Text(
        l10n.eventCostSplit,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        l10n.eventCostSplitSubtitle,
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
      ),
      secondary: Icon(
        Icons.payments_outlined,
        size: 22.sp,
        color: AppColors.primary,
      ),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    ).animate().fadeIn(duration: 250.ms, delay: 290.ms);
  }

  // ── Submit ────────────────────────────────────────────────────
  Widget _buildSubmitButton(
    BuildContext context,
    WidgetRef ref,
    CreateEventFormState createState,
    AppLocalizations l10n,
  ) {
    final buttonText = createState.isUploadingImage
        ? l10n.eventUploadingCover
        : createState.isSubmitting
        ? l10n.eventCreating
        : l10n.createEventTitle;

    return PremiumButton(
      text: buttonText,
      onPressed: createState.isBusy ? null : () => _submit(context, ref),
      isLoading: createState.isBusy,
      icon: Icons.check_rounded,
      style: PremiumButtonStyle.primary,
    ).animate().fadeIn(duration: 250.ms, delay: 300.ms);
  }

  // ── Helpers ──────────────────────────────────────────────────
  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.textSecondary,
    ),
  );

  Widget _sectionError(String message) => Text(
    message,
    style: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: ThemeData.light().colorScheme.error,
    ),
  );

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14.sp),
    prefixIcon: Icon(icon, size: 20.sp, color: AppColors.textTertiary),
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );

  // ── Pickers ──────────────────────────────────────────────────
  Future<void> _pickLocation(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final result = await MapLocationPicker.show(
      context,
      title: l10n.eventLocationTitle,
    );
    if (result != null && context.mounted) {
      ref
          .read(createEventFormViewModelProvider.notifier)
          .setLocation(
            LocationPoint(
              latitude: result.location.latitude,
              longitude: result.location.longitude,
              address: result.address,
            ),
          );
    }
  }

  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref,
    CreateEventFormState createState, {
    required bool isStart,
  }) async {
    final now = DateTime.now();
    final initial = isStart
        ? createState.startsAt
        : (createState.endsAt ??
              createState.startsAt.add(const Duration(hours: 2)));
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: initial.isBefore(now) ? now : initial,
    );
    if (date == null || !context.mounted) return;
    if (isStart) {
      ref
          .read(createEventFormViewModelProvider.notifier)
          .setStartsAt(
            DateTime(
              date.year,
              date.month,
              date.day,
              createState.startsAt.hour,
              createState.startsAt.minute,
            ),
          );
      return;
    }

    final base =
        createState.endsAt ??
        createState.startsAt.add(const Duration(hours: 2));
    ref
        .read(createEventFormViewModelProvider.notifier)
        .setEndsAt(
          DateTime(date.year, date.month, date.day, base.hour, base.minute),
        );
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    CreateEventFormState createState, {
    required bool isStart,
  }) async {
    final initial = isStart
        ? TimeOfDay.fromDateTime(createState.startsAt)
        : TimeOfDay.fromDateTime(
            createState.endsAt ??
                createState.startsAt.add(const Duration(hours: 2)),
          );
    final time = await showTimePicker(context: context, initialTime: initial);
    if (time == null || !context.mounted) return;
    if (isStart) {
      ref
          .read(createEventFormViewModelProvider.notifier)
          .setStartsAt(
            DateTime(
              createState.startsAt.year,
              createState.startsAt.month,
              createState.startsAt.day,
              time.hour,
              time.minute,
            ),
          );
      return;
    }

    final base =
        createState.endsAt ??
        createState.startsAt.add(const Duration(hours: 2));
    ref
        .read(createEventFormViewModelProvider.notifier)
        .setEndsAt(
          DateTime(base.year, base.month, base.day, time.hour, time.minute),
        );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(createEventFormViewModelProvider.notifier)
        .submit();

    if (!context.mounted || result == null) return;
    context.pop(result.event);
  }
}
