import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';

/// Polished bottom-sheet for quickly creating a new event.
///
/// Returns the created [EventModel] via [Navigator.pop] on success.
class CreateEventSheet extends ConsumerStatefulWidget {
  const CreateEventSheet({super.key});

  /// Convenience launcher.
  static Future<EventModel?> show(BuildContext context) {
    return showModalBottomSheet<EventModel>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateEventSheet(),
    );
  }

  @override
  ConsumerState<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends ConsumerState<CreateEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();

  EventType _selectedType = EventType.football;
  DateTime _startsAt = DateTime.now().add(const Duration(hours: 2));
  DateTime? _endsAt;
  LocationPoint? _location;
  int _maxParticipants = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.9.sh),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSportTypeSelector(),
                    SizedBox(height: 20.h),
                    _buildTitleField(),
                    SizedBox(height: 16.h),
                    _buildVenueField(),
                    SizedBox(height: 16.h),
                    _buildDescriptionField(),
                    SizedBox(height: 20.h),
                    _buildLocationPicker(),
                    SizedBox(height: 20.h),
                    _buildDateTimePickers(),
                    SizedBox(height: 20.h),
                    _buildParticipantSlider(),
                    SizedBox(height: 24.h),
                    _buildSubmitButton(),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Handle ──────────────────────────────────────────────────
  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 12.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 12.w, 8.h),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Event',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Set up a new sports event',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 22.sp,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // ── Sport Type Selector (horizontal grid) ───────────────────
  Widget _buildSportTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Sport Type'),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: EventType.values.map((type) {
            final isActive = _selectedType == type;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedType = type);
              },
              child: AnimatedContainer(
                duration: 200.ms,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? type.color.withValues(alpha: 0.15)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isActive ? type.color : AppColors.border,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(type.icon, size: 16.sp, color: type.color),
                    SizedBox(width: 6.w),
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive ? type.color : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 200.ms, delay: 50.ms);
  }

  // ── Title ───────────────────────────────────────────────────
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleCtrl,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
      decoration: _inputDeco('Event Title', Icons.title_rounded),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Title is required' : null,
    ).animate().fadeIn(duration: 200.ms, delay: 100.ms);
  }

  // ── Venue ───────────────────────────────────────────────────
  Widget _buildVenueField() {
    return TextFormField(
      controller: _venueCtrl,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
      decoration: _inputDeco('Venue Name (optional)', Icons.stadium_rounded),
    ).animate().fadeIn(duration: 200.ms, delay: 150.ms);
  }

  // ── Description ─────────────────────────────────────────────
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descCtrl,
      maxLines: 3,
      minLines: 2,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
      decoration: _inputDeco(
        'Description (optional)',
        Icons.description_outlined,
      ),
    ).animate().fadeIn(duration: 200.ms, delay: 200.ms);
  }

  // ── Location ────────────────────────────────────────────────
  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Location'),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _pickLocation,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  _location != null
                      ? Icons.check_circle_rounded
                      : Icons.location_on_outlined,
                  size: 20.sp,
                  color: _location != null
                      ? AppColors.success
                      : AppColors.textTertiary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _location?.address ?? 'Tap to pick a location on the map',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _location != null
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
    ).animate().fadeIn(duration: 200.ms, delay: 250.ms);
  }

  // ── Date & Time ─────────────────────────────────────────────
  Widget _buildDateTimePickers() {
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('When'),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _dateTile(
                icon: Icons.calendar_today_rounded,
                label: 'Start Date',
                value: dateFormat.format(_startsAt),
                onTap: () => _pickDate(isStart: true),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _dateTile(
                icon: Icons.schedule_rounded,
                label: 'Start Time',
                value: timeFormat.format(_startsAt),
                onTap: () => _pickTime(isStart: true),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _dateTile(
                icon: Icons.event_rounded,
                label: 'End Date',
                value: _endsAt != null
                    ? dateFormat.format(_endsAt!)
                    : 'Optional',
                onTap: () => _pickDate(isStart: false),
                muted: _endsAt == null,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _dateTile(
                icon: Icons.schedule_rounded,
                label: 'End Time',
                value: _endsAt != null
                    ? timeFormat.format(_endsAt!)
                    : 'Optional',
                onTap: () => _pickTime(isStart: false),
                muted: _endsAt == null,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 200.ms, delay: 300.ms);
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
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.textTertiary),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
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

  // ── Participant limit ───────────────────────────────────────
  Widget _buildParticipantSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Max Participants'),
        SizedBox(height: 4.h),
        Text(
          _maxParticipants == 0 ? 'Unlimited' : '$_maxParticipants spots',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Slider(
          value: _maxParticipants.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          label: _maxParticipants == 0 ? 'Unlimited' : '$_maxParticipants',
          activeColor: _selectedType.color,
          onChanged: (v) => setState(() => _maxParticipants = v.round()),
        ),
      ],
    ).animate().fadeIn(duration: 200.ms, delay: 350.ms);
  }

  // ── Submit Button ───────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: FilledButton.icon(
        onPressed: _isSubmitting ? null : _submit,
        icon: _isSubmitting
            ? SizedBox(
                height: 18.sp,
                width: 18.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(Icons.check_rounded, size: 20.sp),
        label: Text(
          _isSubmitting ? 'Creating...' : 'Create Event',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _selectedType.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms, delay: 400.ms);
  }

  // ── Helpers ─────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14.sp),
      prefixIcon: Icon(icon, size: 20.sp, color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: _selectedType.color, width: 1.5),
      ),
    );
  }

  // ── Pickers ─────────────────────────────────────────────────

  Future<void> _pickLocation() async {
    final result = await MapLocationPicker.show(
      context,
      title: 'Event Location',
    );
    if (result != null && mounted) {
      setState(() {
        _location = LocationPoint(
          latitude: result.location.latitude,
          longitude: result.location.longitude,
          address: result.address,
        );
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart ? _startsAt : (_endsAt ?? _startsAt);

    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: initial.isBefore(now) ? now : initial,
    );
    if (date == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startsAt = DateTime(
          date.year,
          date.month,
          date.day,
          _startsAt.hour,
          _startsAt.minute,
        );
      } else {
        final base = _endsAt ?? _startsAt.add(const Duration(hours: 2));
        _endsAt = DateTime(
          date.year,
          date.month,
          date.day,
          base.hour,
          base.minute,
        );
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? TimeOfDay.fromDateTime(_startsAt)
        : TimeOfDay.fromDateTime(
            _endsAt ?? _startsAt.add(const Duration(hours: 2)),
          );

    final time = await showTimePicker(context: context, initialTime: initial);
    if (time == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startsAt = DateTime(
          _startsAt.year,
          _startsAt.month,
          _startsAt.day,
          time.hour,
          time.minute,
        );
      } else {
        final base = _endsAt ?? _startsAt.add(const Duration(hours: 2));
        _endsAt = DateTime(
          base.year,
          base.month,
          base.day,
          time.hour,
          time.minute,
        );
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a location on the map.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      }
      return;
    }

    final created = await ref
        .read(eventSelectionViewModelProvider.notifier)
        .createEvent(
          creatorId: user.uid,
          title: _titleCtrl.text,
          type: _selectedType,
          location: _location!,
          startsAt: _startsAt,
          endsAt: _endsAt,
          description: _descCtrl.text,
          venueName: _venueCtrl.text,
        );

    if (!mounted) return;

    if (created != null) {
      Navigator.of(context).pop(created);
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to create event. Please try again.'),
        ),
      );
    }
  }
}
