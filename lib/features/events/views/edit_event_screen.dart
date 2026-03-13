import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';

/// Full-screen event editing form — pre-populated from an existing event.
///
/// Expects an [EventModel] passed via GoRouter `extra`.
/// On success, pops with the updated [EventModel].
class EditEventScreen extends ConsumerStatefulWidget {
  const EditEventScreen({super.key, required this.event});

  final EventModel event;

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  final _dateFmt = DateFormat('EEE, MMM d, yyyy');
  final _timeFmt = DateFormat('h:mm a');

  EditEventFormState get _formState =>
      ref.watch(editEventFormViewModelProvider(widget.event.id));

  EditEventFormViewModel get _formNotifier =>
      ref.read(editEventFormViewModelProvider(widget.event.id).notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _formNotifier.initFromEvent(widget.event));
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(
      eventDetailViewModelProvider(widget.event.id),
    );
    final formState = _formState;

    ref.listen(eventDetailViewModelProvider(widget.event.id), (previous, next) {
      if (next.error != null &&
          next.error != previous?.error &&
          context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    ref.listen(editEventFormViewModelProvider(widget.event.id), (
      previous,
      next,
    ) {
      if (next.error != null &&
          next.error != previous?.error &&
          context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
      if (next.isSaved && previous?.isSaved != true && context.mounted) {
        final updated = widget.event.copyWith(
          title: next.title.trim(),
          type: next.type,
          location: next.location!,
          startsAt: next.startsAt!,
          endsAt: next.endsAt,
          description: next.description.trim().isEmpty
              ? null
              : next.description.trim(),
          venueName: next.venueName.trim().isEmpty
              ? null
              : next.venueName.trim(),
          imageUrl: next.removeExistingImage ? null : next.existingImageUrl,
          maxParticipants: next.maxParticipants,
          parkingInfo: next.parkingInfo.trim().isEmpty
              ? null
              : next.parkingInfo.trim(),
          isRecurring: next.isRecurring,
          recurringDays: [...next.recurringDays]..sort(),
          recurringEndDate: next.recurringEndDate,
          costSplitEnabled: next.costSplitEnabled,
          updatedAt: DateTime.now(),
        );
        context.pop(updated);
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
          AppLocalizations.of(context).editEventTitle,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: FormBuilder(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
          children: [
            _buildSportTypeSelector(),
            SizedBox(height: 20.h),
            _buildTitleField(),
            SizedBox(height: 14.h),
            _buildVenueField(),
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
            _buildParkingInfoField(),
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
    return FormBuilderTextField(
      name: 'title',
      initialValue: _formState.title,
      maxLength: 100,
      textCapitalization: TextCapitalization.words,
      decoration: _deco(
        AppLocalizations.of(context).eventTitleField,
        Icons.title_rounded,
      ),
      onChanged: (value) => _formNotifier.setTitle(value ?? ''),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(
          errorText: AppLocalizations.of(context).eventTitleRequired,
        ),
        FormBuilderValidators.minLength(
          3,
          errorText: AppLocalizations.of(context).eventTitleMinLength,
        ),
      ]),
    ).animate().fadeIn(duration: 250.ms, delay: 60.ms);
  }

  Widget _buildVenueField() {
    return FormBuilderTextField(
      name: 'venue',
      initialValue: _formState.venueName,
      textCapitalization: TextCapitalization.words,
      onChanged: (value) => _formNotifier.setVenueName(value ?? ''),
      decoration: _deco(
        AppLocalizations.of(context).eventVenueName,
        Icons.stadium_rounded,
      ),
    ).animate().fadeIn(duration: 250.ms, delay: 100.ms);
  }

  Widget _buildDescriptionField() {
    return FormBuilderTextField(
      name: 'description',
      initialValue: _formState.description,
      maxLines: 3,
      minLines: 2,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (value) => _formNotifier.setDescription(value ?? ''),
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
        Slider(
          value: _formState.maxParticipants.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          label: _formState.maxParticipants == 0
              ? AppLocalizations.of(context).eventUnlimited
              : '${_formState.maxParticipants}',
          onChanged: (v) => _formNotifier.setMaxParticipants(v.round()),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 260.ms);
  }

  // ── Parking Info ───────────────────────────────────────────
  Widget _buildParkingInfoField() {
    return FormBuilderTextField(
      name: 'parkingInfo',
      initialValue: _formState.parkingInfo,
      maxLines: 2,
      minLines: 1,
      maxLength: 300,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (value) => _formNotifier.setParkingInfo(value ?? ''),
      decoration: _deco(
        AppLocalizations.of(context).eventParkingInstructions,
        Icons.local_parking_rounded,
      ),
    ).animate().fadeIn(duration: 250.ms, delay: 270.ms);
  }

  // ── Recurring Toggle + Day Selector ──────────────────────────
  Widget _buildRecurringToggle() {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
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
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final day = i + 1;
              final selected = _formState.recurringDays.contains(day);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _formNotifier.toggleRecurringDay(day);
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
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) return;
    if (_formState.location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).selectLocationError),
        ),
      );
      return;
    }
    if ((_formState.startsAt ?? DateTime.now()).isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).eventStartTimeFuture),
        ),
      );
      return;
    }
    if (_formState.endsAt != null &&
        !_formState.endsAt!.isAfter(_formState.startsAt!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).eventEndTimeAfterStart),
        ),
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
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
      prefixIcon: Icon(icon, size: 20.sp, color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: AppColors.border),
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
