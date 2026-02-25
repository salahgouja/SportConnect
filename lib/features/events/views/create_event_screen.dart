import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
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
class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();

  EventType _type = EventType.football;
  DateTime _startsAt = DateTime.now().add(const Duration(hours: 2));
  DateTime? _endsAt;
  LocationPoint? _location;
  int _maxParticipants = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
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
          'Create Event',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
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
            _buildLocationPicker(),
            SizedBox(height: 20.h),
            _buildWhenSection(),
            SizedBox(height: 20.h),
            _buildParticipantSlider(),
            SizedBox(height: 32.h),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // ── Sport type ───────────────────────────────────────────────
  Widget _buildSportTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Sport Type'),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: EventType.values.map((type) {
            final active = _type == type;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _type = type);
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
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleCtrl,
      textCapitalization: TextCapitalization.words,
      decoration: _deco('Event Title *', Icons.title_rounded),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Title is required' : null,
    ).animate().fadeIn(duration: 250.ms, delay: 60.ms);
  }

  Widget _buildVenueField() {
    return TextFormField(
      controller: _venueCtrl,
      textCapitalization: TextCapitalization.words,
      decoration: _deco('Venue Name (optional)', Icons.stadium_rounded),
    ).animate().fadeIn(duration: 250.ms, delay: 100.ms);
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descCtrl,
      maxLines: 3,
      minLines: 2,
      textCapitalization: TextCapitalization.sentences,
      decoration: _deco('Description (optional)', Icons.notes_rounded),
    ).animate().fadeIn(duration: 250.ms, delay: 140.ms);
  }

  // ── Location ─────────────────────────────────────────────────
  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Location *'),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _pickLocation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: _location != null ? AppColors.success : AppColors.border,
              ),
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
    ).animate().fadeIn(duration: 250.ms, delay: 180.ms);
  }

  // ── When ─────────────────────────────────────────────────────
  Widget _buildWhenSection() {
    final df = DateFormat('EEE, MMM d');
    final tf = DateFormat('h:mm a');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('When *'),
        SizedBox(height: 8.h),
        // Start row
        Row(
          children: [
            Expanded(
              child: _dateTile(
                icon: Icons.calendar_today_rounded,
                label: 'Start date',
                value: df.format(_startsAt),
                onTap: () => _pickDate(isStart: true),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _dateTile(
                icon: Icons.access_time_rounded,
                label: 'Start time',
                value: tf.format(_startsAt),
                onTap: () => _pickTime(isStart: true),
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
                label: 'End date',
                value: _endsAt != null ? df.format(_endsAt!) : 'Optional',
                onTap: () => _pickDate(isStart: false),
                muted: _endsAt == null,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _dateTile(
                icon: Icons.access_time_rounded,
                label: 'End time',
                value: _endsAt != null ? tf.format(_endsAt!) : 'Optional',
                onTap: () => _pickTime(isStart: false),
                muted: _endsAt == null,
              ),
            ),
          ],
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
  Widget _buildParticipantSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _label('Max Participants'),
            const Spacer(),
            Text(
              _maxParticipants == 0 ? 'Unlimited' : '$_maxParticipants spots',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _type.color,
              ),
            ),
          ],
        ),
        Slider(
          value: _maxParticipants.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          activeColor: _type.color,
          onChanged: (v) => setState(() => _maxParticipants = v.round()),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 260.ms);
  }

  // ── Submit ────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return PremiumButton(
      text: _submitting ? 'Creating…' : 'Create Event',
      onPressed: _submitting ? null : _submit,
      isLoading: _submitting,
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
      borderSide: BorderSide(color: _type.color, width: 1.5),
    ),
  );

  // ── Pickers ──────────────────────────────────────────────────
  Future<void> _pickLocation() async {
    final result = await MapLocationPicker.show(
      context,
      title: 'Event Location',
    );
    if (result != null && mounted) {
      setState(
        () => _location = LocationPoint(
          latitude: result.location.latitude,
          longitude: result.location.longitude,
          address: result.address,
        ),
      );
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please pick a location.')));
      return;
    }

    setState(() => _submitting = true);

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      setState(() => _submitting = false);
      return;
    }

    final created = await ref
        .read(eventSelectionViewModelProvider.notifier)
        .createEvent(
          creatorId: user.uid,
          title: _titleCtrl.text.trim(),
          type: _type,
          location: _location!,
          startsAt: _startsAt,
          endsAt: _endsAt,
          description: _descCtrl.text.trim(),
          venueName: _venueCtrl.text.trim(),
          maxParticipants: _maxParticipants,
        );

    if (!mounted) return;

    if (created != null) {
      // GoRouter pops back to caller with result — clean, no navigator bugs
      context.pop(created);
    } else {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to create event.')));
    }
  }
}
