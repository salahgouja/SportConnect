import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/services/map_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Address autocomplete input with Nominatim search + map picker.
///
/// Features:
/// - Real-time address suggestions via Nominatim
/// - Debounced search (500ms) to reduce API calls
/// - Optional map picker button to open full MapLocationPicker
/// - Supports initial value and location
/// - Accessible labels and semantics
class AddressAutocompleteField extends ConsumerStatefulWidget {
  const AddressAutocompleteField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.initialLocation,
    this.onSelected,
    this.showMapPicker = true,
    this.accentColor,
    this.fillColor,
    this.enabled = true,
    this.validator,
  });

  final String? label;
  final String? hint;
  final String? initialValue;
  final LatLng? initialLocation;
  final ValueChanged<AddressResult>? onSelected;
  final bool showMapPicker;
  final Color? accentColor;
  final Color? fillColor;
  final bool enabled;
  final String? Function(String?)? validator;

  @override
  ConsumerState<AddressAutocompleteField> createState() =>
      AddressAutocompleteFieldState();
}

class AddressAutocompleteFieldState
    extends ConsumerState<AddressAutocompleteField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  bool _isSearching = false;
  String? _errorText;
  bool _hasInteracted = false;
  LatLng? _selectedLocation;

  String get text => _controller.text;
  LatLng? get location => _selectedLocation;

  String? validate() {
    if (!mounted) return null;
    _hasInteracted = true;
    final error = widget.validator?.call(_controller.text);
    setState(() => _errorText = error);
    return error;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _selectedLocation = widget.initialLocation;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          if (_hasInteracted && widget.validator != null) {
            setState(() => _errorText = widget.validator!(_controller.text));
          }
        }
      });
    }
  }

  void _onTextChanged(String query) {
    _hasInteracted = true;
    if (_selectedLocation != null) _selectedLocation = null;
    if (widget.validator != null && _errorText != null) {
      setState(() => _errorText = widget.validator!(_controller.text));
    }
  }

  Future<List<SearchResult>> _suggestionsFor(String query) async {
    if (query.length < 2 || !widget.enabled) return const [];

    if (mounted) setState(() => _isSearching = true);
    try {
      return ref.read(mapServiceProvider).searchPlaces(query, limit: 6);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSuggestion(SearchResult result) {
    final displayText = result.displayName;

    _controller.text = displayText;
    _selectedLocation = result.location;
    _focusNode.unfocus();

    widget.onSelected?.call(
      AddressResult(
        address: displayText,
        fullAddress: result.displayName,
        location: result.location,
      ),
    );

    if (widget.validator != null) {
      setState(() => _errorText = widget.validator!(_controller.text));
    }
  }

  Future<void> _openMapPicker() async {
    _focusNode.unfocus();

    final result = await MapLocationPicker.show(
      context,
      title: widget.label ?? 'Select Location',
      initialLocation: _selectedLocation,
    );

    if (result != null && mounted) {
      _controller.text = result.address;
      _selectedLocation = result.location;

      widget.onSelected?.call(
        AddressResult(
          address: result.address,
          fullAddress: result.address,
          location: result.location,
        ),
      );

      if (widget.validator != null) {
        setState(() => _errorText = widget.validator!(_controller.text));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.primary;
    final fill = widget.fillColor ?? accent.withValues(alpha: 0.06);
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: hasError ? AppColors.error : accent.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TypeAheadField<SearchResult>(
          controller: _controller,
          focusNode: _focusNode,
          debounceDuration: const Duration(milliseconds: 500),
          hideOnEmpty: true,
          hideOnError: true,
          hideOnLoading: false,
          retainOnLoading: true,
          suggestionsCallback: _suggestionsFor,
          onSelected: _selectSuggestion,
          itemBuilder: (context, result) => _SuggestionTile(
            result: result,
            accentColor: accent,
          ),
          loadingBuilder: (context) => Padding(
            padding: EdgeInsets.all(16.w),
            child: Center(
              child: SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
            ),
          ),
          emptyBuilder: (context) => const SizedBox.shrink(),
          decorationBuilder: (context, child) => Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(14.r),
            color: AppColors.surface,
            shadowColor: Colors.black26,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 250.h),
              child: child,
            ),
          ),
          builder: (context, controller, focusNode) => Container(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: hasError
                    ? AppColors.error
                    : accent.withValues(alpha: 0.2),
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: accent.withValues(alpha: 0.6),
                    size: 20.sp,
                  ),
                ),
                Expanded(
                  child: Semantics(
                    label: widget.label ?? 'Address',
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      enabled: widget.enabled,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hint ?? 'Search address...',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 14.h,
                        ),
                      ),
                      onChanged: _onTextChanged,
                    ),
                  ),
                ),
                if (_isSearching)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                  ),
                if (widget.showMapPicker && !_isSearching)
                  IconButton(
                    icon: Icon(Icons.map_rounded, color: accent, size: 22.sp),
                    tooltip: AppLocalizations.of(context).pickOnMap,
                    onPressed: widget.enabled ? _openMapPicker : null,
                    constraints: BoxConstraints(
                      minWidth: 44.w,
                      minHeight: 44.h,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 12.w),
            child: Text(
              _errorText!,
              style: TextStyle(fontSize: 12.sp, color: AppColors.error),
            ),
          ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.3),
      ],
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.result,
    required this.accentColor,
  });

  final SearchResult result;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final parts = result.displayName
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    final primary = parts.isEmpty ? result.displayName.trim() : parts.first;
    final secondary = parts.skip(1).join(', ').trim();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.place_rounded,
              color: accentColor,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primary,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (secondary.isNotEmpty)
                  Text(
                    secondary,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} // ─── Data Model ───────────────────────────────────────────────────────────────

/// Result from address autocomplete selection.
class AddressResult {
  const AddressResult({
    required this.address,
    required this.fullAddress,
    required this.location,
  });

  final String address;
  final String fullAddress;
  final LatLng location;
}
