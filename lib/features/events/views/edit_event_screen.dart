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
import 'package:sport_connect/core/widgets/map_location_picker.dart';
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
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _venueCtrl;

  late EventType _type;
  late DateTime _startsAt;
  DateTime? _endsAt;
  LocationPoint? _location;
  late int _maxParticipants;
  File? _imageFile;
  bool _submitting = false;

  final _dateFmt = DateFormat('EEE, MMM d, yyyy');
  final _timeFmt = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtrl = TextEditingController(text: e.title);
    _descCtrl = TextEditingController(text: e.description ?? '');
    _venueCtrl = TextEditingController(text: e.venueName ?? '');
    _type = e.type;
    _startsAt = e.startsAt;
    _endsAt = e.endsAt;
    _location = e.location;
    _maxParticipants = e.maxParticipants;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════
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
          'Edit Event',
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
            _buildImagePicker(),
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

  // ── Sport type ─────────────────────────────────────────────
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

  // ── Fields ─────────────────────────────────────────────────
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

  // ── Cover Image ──────────────────────────────────────────────
  Widget _buildImagePicker() {
    final existingUrl = widget.event.imageUrl;
    final hasImage =
        _imageFile != null || (existingUrl != null && existingUrl.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Cover Image (optional)'),
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
              image: _imageFile != null
                  ? DecorationImage(
                      image: FileImage(_imageFile!),
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
                          onPressed: () => setState(() => _imageFile = null),
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
                        'Tap to add a cover photo',
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
      setState(() => _imageFile = File(image.path));
    }
  }

  // ── Location ───────────────────────────────────────────────
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

  // ── When ───────────────────────────────────────────────────
  Widget _buildWhenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('When'),
        SizedBox(height: 8.h),
        // Start date + time
        Row(
          children: [
            Expanded(
              child: _DateTimeChip(
                icon: Icons.calendar_today_rounded,
                label: _dateFmt.format(_startsAt),
                onTap: () => _pickDate(isStart: true),
              ),
            ),
            SizedBox(width: 8.w),
            _DateTimeChip(
              icon: Icons.access_time_rounded,
              label: _timeFmt.format(_startsAt),
              onTap: () => _pickTime(isStart: true),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        // End time (optional)
        Row(
          children: [
            Text(
              'End',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _endsAt != null
                  ? GestureDetector(
                      onTap: () => _pickTime(isStart: false),
                      child: Row(
                        children: [
                          _DateTimeChip(
                            icon: Icons.access_time_rounded,
                            label: _timeFmt.format(_endsAt!),
                            onTap: () => _pickTime(isStart: false),
                          ),
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () => setState(() => _endsAt = null),
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
                        '+ Add end time',
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
            _label('Max Participants'),
            const Spacer(),
            Text(
              _maxParticipants == 0 ? 'Unlimited' : '$_maxParticipants',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: _maxParticipants.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          label: _maxParticipants == 0 ? 'Unlimited' : '$_maxParticipants',
          onChanged: (v) => setState(() => _maxParticipants = v.round()),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 260.ms);
  }

  // ── Submit ─────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return PremiumButton(
      text: 'Save Changes',
      icon: Icons.check_rounded,
      fullWidth: true,
      isLoading: _submitting,
      onPressed: _submit,
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location.')),
      );
      return;
    }
    if (_startsAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start time must be in the future.')),
      );
      return;
    }
    if (_endsAt != null && _endsAt!.isBefore(_startsAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }

    setState(() => _submitting = true);

    final vmNotifier = ref.read(
      eventDetailViewModelProvider(widget.event.id).notifier,
    );

    // Upload new cover image if one was picked.
    String? imageUrl = widget.event.imageUrl;
    if (_imageFile != null) {
      final url = await vmNotifier.uploadImage(_imageFile!);
      if (url != null) imageUrl = url;
    }

    final updated = widget.event.copyWith(
      title: _titleCtrl.text.trim(),
      type: _type,
      location: _location!,
      startsAt: _startsAt,
      endsAt: _endsAt,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      venueName: _venueCtrl.text.trim().isEmpty ? null : _venueCtrl.text.trim(),
      imageUrl: imageUrl,
      maxParticipants: _maxParticipants,
      updatedAt: DateTime.now(),
    );

    final success = await vmNotifier.updateEvent(updated);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      context.pop(updated);
    }
  }

  // ════════════════════════════════════════════════════════════
  // HELPER PICKERS
  // ════════════════════════════════════════════════════════════
  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final raw = isStart ? _startsAt : (_endsAt ?? _startsAt);
    final initial = raw.isBefore(today) ? today : raw;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startsAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startsAt.hour,
          _startsAt.minute,
        );
      } else {
        final base = _endsAt ?? _startsAt;
        _endsAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          base.hour,
          base.minute,
        );
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? TimeOfDay.fromDateTime(_startsAt)
        : TimeOfDay.fromDateTime(_endsAt ?? _startsAt);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startsAt = DateTime(
          _startsAt.year,
          _startsAt.month,
          _startsAt.day,
          picked.hour,
          picked.minute,
        );
      } else {
        final base = _endsAt ?? _startsAt;
        _endsAt = DateTime(
          base.year,
          base.month,
          base.day,
          picked.hour,
          picked.minute,
        );
      }
    });
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
