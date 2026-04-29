import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';

// ─── Data Models ──────────────────────────────────────────────────────────────

/// French phone input with +33 prefix, formatting, and validation.
///
/// Features:
/// - France-only phone number input
/// - 9-digit French national number validation
/// - Real-time validation with visual feedback
/// - Trailing checkmark when valid; red border when invalid
/// - Accessible labels and semantics
class PhoneNumber {
  const PhoneNumber({
    required this.countryCode,
    required this.dialCode,
    required this.number,
    required this.isValid,
  });

  final String countryCode;
  final String dialCode;
  final String number;

  /// Whether the number satisfies the selected country's length constraints.
  /// Set by [IntlPhoneInputState], not self-computed.
  final bool isValid;

  String get fullNumber => '+$dialCode$number';

  @override
  String toString() => fullNumber;
}

/// Represents a country with dial code and formatting info.
class Country {
  const Country({
    required this.code,
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.example,
    this.minLength = 6,
    this.maxLength = 15,
  });

  final String code;
  final String name;
  final String dialCode;
  final String flag;
  final String example;
  final int minLength;
  final int maxLength;
}

// ─── Main Widget ──────────────────────────────────────────────────────────────

/// International Phone Input with country code picker, flag emojis,
/// formatting and validation.
///
/// Features:
/// - 50+ countries with flag emoji + dial code
/// - Searchable country picker bottom sheet with empty state
/// - Per-country min/max digit length validation
/// - Real-time validation with visual feedback (error, valid, neutral)
/// - Trailing checkmark when valid; red border when invalid
/// - Auto-detects country from device locale
/// - Accessible labels and semantics
class IntlPhoneInput extends StatefulWidget {
  const IntlPhoneInput({
    super.key,
    this.initialValue,
    this.initialCountryCode = 'FR',
    this.label,
    this.hint,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
    this.validator,
    this.accentColor,
    this.fillColor,
  });

  final String? initialValue;

  /// ISO country code to pre-select. Defaults to France.
  final String initialCountryCode;
  final String? label;
  final String? hint;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<PhoneNumber>? onChanged;
  final String? Function(PhoneNumber?)? validator;
  final Color? accentColor;
  final Color? fillColor;

  @override
  State<IntlPhoneInput> createState() => IntlPhoneInputState();
}

class IntlPhoneInputState extends State<IntlPhoneInput> {
  late Country _selectedCountry;
  late final TextEditingController _controller;
  String? _errorText;
  bool _hasInteracted = false;

  Country get selectedCountry => _selectedCountry;

  /// Whether the current digits satisfy the selected country's length rules.
  bool get _isPhoneValid {
    final digits = _controller.text.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= _selectedCountry.minLength &&
        digits.length <= _selectedCountry.maxLength;
  }

  PhoneNumber get phoneNumber => PhoneNumber(
    countryCode: _selectedCountry.code,
    dialCode: _selectedCountry.dialCode,
    number: _controller.text.replaceAll(RegExp(r'[^\d]'), ''),
    isValid: _isPhoneValid,
  );

  String get fullNumber => phoneNumber.fullNumber;

  /// Externally validate and return error text (or null).
  String? validate() {
    _hasInteracted = true;
    final error = widget.validator?.call(phoneNumber);
    setState(() => _errorText = error);
    return error;
  }

  @override
  void initState() {
    super.initState();

    // Auto-detect country from device locale; fall back to TN.
    _selectedCountry = france;

    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String _) {
    final pn = phoneNumber;
    widget.onChanged?.call(pn);
    if (_hasInteracted && widget.validator != null) {
      setState(() => _errorText = widget.validator!(pn));
    } else {
      // Rebuild to update valid/invalid visual state.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.primary;
    final fill = widget.fillColor ?? accent.withValues(alpha: 0.06);
    final hasError = _errorText != null;
    final isValid =
        _isPhoneValid &&
        _controller.text.replaceAll(RegExp(r'[^\d]'), '').isNotEmpty;

    // Border color priority: error > valid > neutral
    final borderColor = hasError
        ? AppColors.error
        : isValid
        ? Colors.green.withValues(alpha: 0.65)
        : accent.withValues(alpha: 0.2);
    final borderWidth = (hasError || isValid) ? 1.5 : 1.0;

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
              color: hasError
                  ? AppColors.error
                  : isValid
                  ? Colors.green
                  : accent.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              // Country picker button
              _CountryPrefix(
                country: _selectedCountry,
                accent: accent,
              ),
              Container(
                width: 1,
                height: 30.h,
                color: accent.withValues(alpha: 0.15),
              ),
              // Phone number text field
              Expanded(
                child: Semantics(
                  label: widget.label ?? 'Phone number',
                  child: TextField(
                    controller: _controller,
                    enabled: widget.enabled,
                    autofocus: widget.autofocus,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-()]')),
                      LengthLimitingTextInputFormatter(
                        _selectedCountry.maxLength + 2,
                      ),
                    ],
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hint ?? _selectedCountry.example,
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
                    onChanged: _onPhoneChanged,
                  ),
                ),
              ),
              // Trailing valid checkmark
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isValid
                    ? Padding(
                        key: const ValueKey('phone-valid'),
                        padding: EdgeInsets.only(right: 12.w),
                        child:
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 18.sp,
                            ).animate().scale(
                              duration: 200.ms,
                              curve: Curves.easeOutBack,
                            ),
                      )
                    : SizedBox(key: const ValueKey('phone-neutral'), width: 0),
              ),
            ],
          ),
        ),
        // Error text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: hasError
              ? Padding(
                  key: const ValueKey('phone-error'),
                  padding: EdgeInsets.only(top: 6.h, left: 12.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 13.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _errorText!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.3)
              : const SizedBox.shrink(key: ValueKey('phone-no-error')),
        ),
      ],
    );
  }
}

// ─── Country Picker Button ────────────────────────────────────────────────────
class _CountryPrefix extends StatelessWidget {
  const _CountryPrefix({
    required this.country,
    required this.accent,
  });

  final Country country;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(country.flag, style: TextStyle(fontSize: 22.sp)),
          SizedBox(width: 6.w),
          Text(
            '+${country.dialCode}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

const Country france = Country(
  code: 'FR',
  name: 'France',
  dialCode: '33',
  flag: '🇫🇷',
  example: '6 12 34 56 78',
  minLength: 9,
  maxLength: 9,
);
