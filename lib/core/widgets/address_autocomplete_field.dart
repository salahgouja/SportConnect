import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/services/map_service.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Address/City autocomplete input with Nominatim search + map picker.
///
/// Features:
/// - Real-time address suggestions via Nominatim
/// - Debounced search (500ms) to reduce API calls
/// - Optional map picker button to open full MapLocationPicker
/// - Displays city/country in suggestions
/// - Supports initial value and location
/// - Accessible labels and semantics
/// - Can be used for both city-only and full address inputs
class AddressAutocompleteField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final LatLng? initialLocation;
  final ValueChanged<AddressResult>? onSelected;
  final bool showMapPicker;
  final String? countryCode;
  final Color? accentColor;
  final Color? fillColor;
  final bool enabled;
  final bool cityOnly;
  final String? Function(String?)? validator;

  const AddressAutocompleteField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.initialLocation,
    this.onSelected,
    this.showMapPicker = true,
    this.countryCode,
    this.accentColor,
    this.fillColor,
    this.enabled = true,
    this.cityOnly = false,
    this.validator,
  });

  @override
  State<AddressAutocompleteField> createState() =>
      AddressAutocompleteFieldState();
}

class AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  List<SearchResult> _suggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;
  Timer? _debounce;
  OverlayEntry? _overlayEntry;
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
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
          if (_hasInteracted && widget.validator != null) {
            setState(() => _errorText = widget.validator!(_controller.text));
          }
        }
      });
    }
  }

  void _onSearchChanged(String query) {
    _hasInteracted = true;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.length < 2) {
      _removeOverlay();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(query);
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    final results = await MapService.searchPlaces(
      query,
      countryCode: widget.countryCode,
      limit: 6,
    );
    if (!mounted) return;
    setState(() {
      _suggestions = results;
      _isSearching = false;
      _showSuggestions = results.isNotEmpty;
    });
    if (_showSuggestions) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _selectSuggestion(SearchResult result) {
    final displayText = widget.cityOnly
        ? (result.city ?? result.displayName.split(',').first)
        : result.displayName;
    _controller.text = displayText;
    _selectedLocation = result.location;
    _removeOverlay();
    _focusNode.unfocus();
    widget.onSelected?.call(
      AddressResult(
        address: displayText,
        fullAddress: result.displayName,
        location: result.location,
        city: result.city,
        country: result.country,
      ),
    );
    if (widget.validator != null) {
      setState(() => _errorText = widget.validator!(_controller.text));
    }
  }

  Future<void> _openMapPicker() async {
    _removeOverlay();
    _focusNode.unfocus();
    final result = await MapLocationPicker.show(
      context,
      title: widget.label ?? 'Select Location',
      initialLocation: _selectedLocation,
      countryCode: widget.countryCode,
    );
    if (result != null && mounted) {
      _controller.text = widget.cityOnly
          ? result.address.split(',').first
          : result.address;
      _selectedLocation = result.location;
      widget.onSelected?.call(
        AddressResult(
          address: _controller.text,
          fullAddress: result.address,
          location: result.location,
        ),
      );
      if (widget.validator != null) {
        setState(() => _errorText = widget.validator!(_controller.text));
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _showSuggestions = false;
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4.h),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(14.r),
            color: AppColors.surface,
            shadowColor: Colors.black26,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 250.h),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final result = _suggestions[index];
                  return _SuggestionTile(
                    result: result,
                    cityOnly: widget.cityOnly,
                    accentColor: widget.accentColor ?? AppColors.primary,
                    onTap: () => _selectSuggestion(result),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.primary;
    final fill = widget.fillColor ?? accent.withValues(alpha: 0.06);
    final hasError = _errorText != null;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: hasError
                    ? AppColors.error
                    : accent.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 8.h),
          ],
          Container(
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
                    widget.cityOnly
                        ? Icons.location_city_rounded
                        : Icons.location_on_outlined,
                    color: accent.withValues(alpha: 0.6),
                    size: 20.sp,
                  ),
                ),
                Expanded(
                  child: Semantics(
                    label: widget.label ?? 'Address',
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: widget.enabled,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            widget.hint ??
                            (widget.cityOnly
                                ? 'Search city...'
                                : 'Search address...'),
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
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),
                if (_isSearching)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accent,
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
          if (hasError)
            Padding(
              padding: EdgeInsets.only(top: 6.h, left: 12.w),
              child: Text(
                _errorText!,
                style: TextStyle(fontSize: 12.sp, color: AppColors.error),
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.3),
        ],
      ),
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _SuggestionTile extends StatelessWidget {
  final SearchResult result;
  final bool cityOnly;
  final Color accentColor;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.result,
    required this.cityOnly,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = cityOnly
        ? (result.city ?? result.displayName.split(',').first)
        : result.displayName.split(',').first;
    final secondary = result.displayName.split(',').skip(1).join(',').trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
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
                cityOnly ? Icons.location_city : Icons.place_rounded,
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
      ),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────

/// Result from address autocomplete selection.
class AddressResult {
  final String address;
  final String fullAddress;
  final LatLng location;
  final String? city;
  final String? country;

  const AddressResult({
    required this.address,
    required this.fullAddress,
    required this.location,
    this.city,
    this.country,
  });
}
