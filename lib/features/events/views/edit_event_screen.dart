import 'dart:io';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Full-screen event editing form — pre-populated from an existing event.
///
/// Expects an [EventModel] passed via GoRouter `extra`.
/// On success, pops with the updated [EventModel].
class EditEventScreen extends ConsumerStatefulWidget {
  const EditEventScreen({required this.eventId, super.key});

  final String eventId;

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  late final FormGroup _form;

  final _dateFmt = DateFormat('EEE, MMM d, yyyy');
  final _timeFmt = DateFormat('h:mm a');

  EditEventFormState get _formState =>
      ref.watch(editEventFormViewModelProvider(widget.eventId));

  EditEventFormViewModel get _formNotifier =>
      ref.read(editEventFormViewModelProvider(widget.eventId).notifier);

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'title': FormControl<String>(
        value: '',
        validators: [Validators.required, Validators.minLength(3)],
      ),
      'description': FormControl<String>(
        value: '',
      ),
    });
    _formNotifier.initFromEventId(widget.eventId);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(
      eventDetailViewModelProvider(widget.eventId),
    );
    final formState = _formState;

    ref.listen(eventDetailViewModelProvider(widget.eventId), (previous, next) {
      if (next.error != null &&
          next.error != previous?.error &&
          context.mounted) {
        AdaptiveSnackBar.show(
          context,
          message: _localizedEventError(next.error!),
          type: AdaptiveSnackBarType.error,
        );
      }
    });

    ref.listen(editEventFormViewModelProvider(widget.eventId), (
      previous,
      next,
    ) {
      if (next.error != null &&
          next.error != previous?.error &&
          context.mounted) {
        AdaptiveSnackBar.show(
          context,
          message: _localizedEventError(next.error!),
          type: AdaptiveSnackBarType.error,
        );
      }
      if (next.isSaved && previous?.isSaved != true && context.mounted) {
        final event = ref.read(eventByIdProvider(widget.eventId)).value;
        final updated = event?.copyWith(
          title: next.title.trim(),
          type: next.type,
          location: next.location!,
          startsAt: next.startsAt!,
          endsAt: next.endsAt,
          description: next.description.trim().isEmpty
              ? null
              : next.description.trim(),
          imageUrl: next.removeExistingImage ? null : next.existingImageUrl,
          maxParticipants: next.maxParticipants,
          isRecurring: next.isRecurring,
          recurringPattern: next.recurringPattern,
          recurringEndDate: next.recurringEndDate,
          costSplitEnabled: next.costSplitEnabled,
          updatedAt: DateTime.now(),
        );
        context.pop(updated);
      }
    });

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            size: 22.sp,
            color: AppColors.textSecondary,
          ),
          onPressed: () => context.pop(),
        ),
        title: AppLocalizations.of(context).editEventTitle,
      ),
      body: ReactiveForm(
        formGroup: _form,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
          children: [
            _buildSportTypeSelector(),
            SizedBox(height: 20.h),
            _buildTitleField(),
            SizedBox(height: 14.h),
            _buildDescriptionField(),
            SizedBox(height: 20.h),
            _buildImagePicker(),
            SizedBox(height: 20.h),
            _buildLocationPicker(),
            SizedBox(height: 20.h),
            _buildWhenSection(),
            SizedBox(height: 20.h),
            _buildParticipantSlider(),
            SizedBox(height: 20.h),
            _buildRecurringToggle(),
            SizedBox(height: 20.h),
            _buildCostSplitToggle(),
            SizedBox(height: 32.h),
            _buildSubmitButton(detailState.isLoading || formState.isSubmitting),
          ],
        ),
      ),
    );
  }

  // ── Sport type ─────────────────────────────────────────────
  Widget _buildSportTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(AppLocalizations.of(context).eventSportType),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: EventType.values.map((type) {
            final active = _formState.type == type;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                _formNotifier.setType(type);
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

  // ── Fields ─────────────────────────────────────────────────
  Widget _buildTitleField() {
    return ReactiveTextField<String>(
      formControlName: 'title',
      maxLength: 100,
      textCapitalization: TextCapitalization.words,
      decoration: _deco(
        AppLocalizations.of(context).eventTitleField,
        Icons.title_rounded,
      ),
      onChanged: (control) => _formNotifier.setTitle(control.value ?? ''),
      validationMessages: {
        ValidationMessage.required: (_) =>
            AppLocalizations.of(context).eventTitleRequired,
        ValidationMessage.minLength: (_) =>
            AppLocalizations.of(context).eventTitleMinLength,
      },
    ).animate().fadeIn(duration: 250.ms, delay: 60.ms);
  }

  Widget _buildDescriptionField() {
    return ReactiveTextField<String>(
      formControlName: 'description',
      maxLines: 3,
      minLines: 2,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (control) => _formNotifier.setDescription(control.value ?? ''),
      decoration: _deco(
        AppLocalizations.of(context).eventDescriptionField,
        Icons.notes_rounded,
      ),
    ).animate().fadeIn(duration: 250.ms, delay: 140.ms);
  }

  // ── Cover Image ──────────────────────────────────────────────
  Widget _buildImagePicker() {
    final existingUrl = _formState.removeExistingImage
        ? null
        : _formState.existingImageUrl;
    final hasImage =
        _formState.imageFile != null || (existingUrl?.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(AppLocalizations.of(context).eventCoverImage),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              image: _formState.imageFile != null
                  ? DecorationImage(
                      image: FileImage(_formState.imageFile!),
                      fit: BoxFit.cover,
                    )
                  : existingUrl != null && existingUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(existingUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage
                ? Align(
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
                          onPressed: _formNotifier.clearSelectedImage,
                        ),
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 36.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppLocalizations.of(context).eventTapToAddPhoto,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 160.ms);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      _formNotifier.setImageFile(File(image.path));
    }
  }

  // ── Location ───────────────────────────────────────────────
  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(AppLocalizations.of(context).eventLocationField),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _pickLocation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: _formState.location != null
                    ? AppColors.success
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _formState.location != null
                      ? Icons.check_circle_rounded
                      : Icons.location_on_outlined,
                  size: 20.sp,
                  color: _formState.location != null
                      ? AppColors.success
                      : AppColors.textTertiary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _formState.location?.address ??
                        AppLocalizations.of(context).eventTapToPickLocation,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _formState.location != null
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
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 180.ms);
  }

  Future<void> _pickLocation() async {
    final result = await MapLocationPicker.show(
      context,
      title: AppLocalizations.of(context).eventLocationTitle,
    );
    if (result != null && context.mounted) {
      _formNotifier.setLocation(
        LocationPoint(
          latitude: result.location.latitude,
          longitude: result.location.longitude,
          address: result.address,
        ),
      );
    }
  }

  // ── When ───────────────────────────────────────────────────
  Widget _buildWhenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(
          AppLocalizations.of(context).eventWhenField.replaceAll(' *', ''),
        ),
        SizedBox(height: 8.h),
        // Start date + time
        Row(
          children: [
            Expanded(
              child: _DateTimeChip(
                icon: Icons.calendar_today_rounded,
                label: _dateFmt.format(_formState.startsAt!),
                onTap: () => _pickDate(isStart: true),
              ),
            ),
            SizedBox(width: 8.w),
            _DateTimeChip(
              icon: Icons.access_time_rounded,
              label: _timeFmt.format(_formState.startsAt!),
              onTap: () => _pickTime(isStart: true),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        // End time (optional)
        Row(
          children: [
            Text(
              AppLocalizations.of(context).eventEndLabel,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _formState.endsAt != null
                  ? GestureDetector(
                      onTap: () => _pickTime(isStart: false),
                      child: Row(
                        children: [
                          _DateTimeChip(
                            icon: Icons.access_time_rounded,
                            label: _timeFmt.format(_formState.endsAt!),
                            onTap: () => _pickTime(isStart: false),
                          ),
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () => _formNotifier.setEndsAt(null),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18.sp,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: () => _pickTime(isStart: false),
                      child: Text(
                        AppLocalizations.of(context).eventAddEndTime,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 220.ms);
  }

  // ── Participant slider ─────────────────────────────────────
  Widget _buildParticipantSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _label(AppLocalizations.of(context).eventMaxParticipants),
            const Spacer(),
            Text(
              _formState.maxParticipants == 0
                  ? AppLocalizations.of(context).eventUnlimited
                  : '${_formState.maxParticipants}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        AdaptiveSlider(
          value: _formState.maxParticipants.toDouble(),
          max: 100,
          divisions: 20,
          activeColor: AppColors.primary,
          label: _formState.maxParticipants == 0
              ? AppLocalizations.of(context).eventUnlimited
              : '${_formState.maxParticipants}',
          onChanged: (v) => _formNotifier.setMaxParticipants(v.round()),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 260.ms);
  }

  // ── Recurring Toggle + Day Selector ──────────────────────────
  Widget _buildRecurringToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          value: _formState.isRecurring,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            _formNotifier.setRecurring(v);
          },
          title: Text(
            AppLocalizations.of(context).eventRecurring,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            AppLocalizations.of(context).eventRecurringSubtitle,
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
        if (_formState.isRecurring) ...[
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _showRecurrencePatternPicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        _formState.recurringPattern?.label ?? 'Select pattern',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: _formState.recurringPattern != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 18.sp,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _pickRecurringEndDate,
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
                    _formState.recurringEndDate != null
                        ? AppLocalizations.of(context).eventRepeatsUntil(
                            DateFormat(
                              'MMM d, y',
                            ).format(_formState.recurringEndDate!),
                          )
                        : AppLocalizations.of(context).eventRepeatEndDate,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: _formState.recurringEndDate != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 280.ms);
  }

  Future<void> _showRecurrencePatternPicker() async {
    final liveState = ref.read(editEventFormViewModelProvider(widget.eventId));
    final patterns = liveState.applicablePatterns;

    await AppModalSheet.show<void>(
      context: context,
      title: 'Repeat',
      maxHeightFactor: 0.7,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                'Repeat',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
            if (patterns.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Text(
                  'No recurrence pattern fits this start/end window. '
                  'Extend end time or set a later repeat end date.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...patterns.map((pattern) {
                final selected = liveState.recurringPattern == pattern;
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _formNotifier.setRecurringPattern(pattern);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 20.sp,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            pattern.label,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Future<void> _pickRecurringEndDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate:
          _formState.recurringEndDate ?? now.add(const Duration(days: 30)),
    );
    if (date != null && context.mounted) {
      _formNotifier.setRecurringEndDate(date);
    }
  }

  // ── Cost Split Toggle ────────────────────────────────────────
  Widget _buildCostSplitToggle() {
    return SwitchListTile.adaptive(
      value: _formState.costSplitEnabled,
      onChanged: (v) {
        HapticFeedback.selectionClick();
        _formNotifier.setCostSplitEnabled(v);
      },
      title: Text(
        AppLocalizations.of(context).eventCostSplit,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        AppLocalizations.of(context).eventCostSplitSubtitle,
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

  // ── Submit ─────────────────────────────────────────────────
  Widget _buildSubmitButton(bool isSubmitting) {
    return PremiumButton(
      text: AppLocalizations.of(context).eventSaveChanges,
      icon: Icons.check_rounded,
      fullWidth: true,
      isLoading: isSubmitting,
      onPressed: _submit,
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  Future<void> _submit() async {
    _form.markAllAsTouched();
    if (!_form.valid) return;
    if (_formState.location == null) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).selectLocationError,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }
    if ((_formState.startsAt ?? DateTime.now()).isBefore(DateTime.now())) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).eventStartTimeFuture,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }
    if (_formState.endsAt != null &&
        !_formState.endsAt!.isAfter(_formState.startsAt!)) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).eventEndTimeAfterStart,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    await _formNotifier.submit();
  }

  // ════════════════════════════════════════════════════════════
  // HELPER PICKERS
  // ════════════════════════════════════════════════════════════
  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final raw = isStart
        ? (_formState.startsAt ?? now)
        : (_formState.endsAt ?? _formState.startsAt ?? now);
    final initial = raw.isBefore(today) ? today : raw;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    if (isStart) {
      final base = _formState.startsAt ?? now;
      _formNotifier.setStartsAt(
        DateTime(picked.year, picked.month, picked.day, base.hour, base.minute),
      );
      return;
    }
    final base = _formState.endsAt ?? _formState.startsAt ?? now;
    _formNotifier.setEndsAt(
      DateTime(picked.year, picked.month, picked.day, base.hour, base.minute),
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? TimeOfDay.fromDateTime(_formState.startsAt ?? DateTime.now())
        : TimeOfDay.fromDateTime(
            _formState.endsAt ?? _formState.startsAt ?? DateTime.now(),
          );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    if (isStart) {
      final base = _formState.startsAt ?? DateTime.now();
      _formNotifier.setStartsAt(
        DateTime(base.year, base.month, base.day, picked.hour, picked.minute),
      );
      return;
    }
    final base = _formState.endsAt ?? _formState.startsAt ?? DateTime.now();
    _formNotifier.setEndsAt(
      DateTime(base.year, base.month, base.day, picked.hour, picked.minute),
    );
  }

  // ════════════════════════════════════════════════════════════
  // DECORATION HELPERS
  // ════════════════════════════════════════════════════════════
  InputDecoration _deco(String hint, IconData icon) {
    return InputDecoration(
      labelText: hint,
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
      prefixIcon: Icon(icon, size: 20.sp, color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  String _localizedEventError(String error) {
    final l10n = AppLocalizations.of(context);
    switch (error) {
      case 'Unable to load the original event.':
        return l10n.eventUnableToLoadOriginal;
      case 'Unable to update event. Please try again.':
        return l10n.eventUnableToUpdate;
      case 'Please sign in to create an event.':
        return l10n.eventSignInRequired;
      default:
        return error;
    }
  }
}

// ═════════════════════════════════════════════════════════════
// Date/Time Chip (reusable)
// ═════════════════════════════════════════════════════════════
class _DateTimeChip extends StatelessWidget {
  const _DateTimeChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: AppColors.primary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
