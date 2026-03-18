import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// ─── Data Models ──────────────────────────────────────────────────────────────

/// Represents a parsed international phone number.
class PhoneNumber {
  final String countryCode;
  final String dialCode;
  final String number;

  const PhoneNumber({
    required this.countryCode,
    required this.dialCode,
    required this.number,
  });

  String get fullNumber => '+$dialCode$number';

  bool get isValid => number.length >= 6 && number.length <= 15;

  @override
  String toString() => fullNumber;
}

/// Represents a country with dial code and formatting info.
class Country {
  final String code;
  final String name;
  final String dialCode;
  final String flag;
  final String example;
  final int minLength;
  final int maxLength;

  const Country({
    required this.code,
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.example,
    this.minLength = 6,
    this.maxLength = 15,
  });
}

// ─── Main Widget ──────────────────────────────────────────────────────────────

/// International Phone Input with country code picker, flag emojis,
/// formatting and validation.
///
/// Features:
/// - 50+ countries with flag emoji + dial code
/// - Searchable country picker bottom sheet
/// - Phone number formatting hints per country
/// - Real-time validation with visual feedback
/// - Accessible labels and semantics
class IntlPhoneInput extends StatefulWidget {
  final String? initialValue;
  final String initialCountryCode;
  final String? label;
  final String? hint;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<PhoneNumber>? onChanged;
  final String? Function(PhoneNumber?)? validator;
  final Color? accentColor;
  final Color? fillColor;

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

  @override
  State<IntlPhoneInput> createState() => IntlPhoneInputState();
}

class IntlPhoneInputState extends State<IntlPhoneInput> {
  late Country _selectedCountry;
  late final TextEditingController _controller;
  String? _errorText;
  bool _hasInteracted = false;

  Country get selectedCountry => _selectedCountry;

  PhoneNumber get phoneNumber => PhoneNumber(
    countryCode: _selectedCountry.code,
    dialCode: _selectedCountry.dialCode,
    number: _controller.text.replaceAll(RegExp(r'[^\d]'), ''),
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
    _selectedCountry = countries.firstWhere(
      (c) => c.code == widget.initialCountryCode,
      orElse: () => countries.first,
    );
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
    }
  }

  void _setCountry(Country country) {
    setState(() => _selectedCountry = country);
    _onPhoneChanged('');
  }

  void _showCountryPicker() {
    final accent = widget.accentColor ?? AppColors.primary;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CountryPickerSheet(
        accent: accent,
        selectedCode: _selectedCountry.code,
        onSelected: (country) {
          _setCountry(country);
          Navigator.pop(ctx);
        },
      ),
    );
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
        Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: hasError ? AppColors.error : accent.withValues(alpha: 0.2),
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Country picker button
              _CountryPickerButton(
                country: _selectedCountry,
                accent: accent,
                enabled: widget.enabled,
                onTap: _showCountryPicker,
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
                      LengthLimitingTextInputFormatter(15),
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
    );
  }
}

// ─── Country Picker Button ────────────────────────────────────────────────────

class _CountryPickerButton extends StatelessWidget {
  final Country country;
  final Color accent;
  final bool enabled;
  final VoidCallback onTap;

  const _CountryPickerButton({
    required this.country,
    required this.accent,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(14.r)),
        child: Padding(
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
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18.sp,
                color: accent.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Country Picker Sheet ─────────────────────────────────────────────────────

class _CountryPickerSheet extends StatefulWidget {
  final Color accent;
  final String selectedCode;
  final ValueChanged<Country> onSelected;

  const _CountryPickerSheet({
    required this.accent,
    required this.selectedCode,
    required this.onSelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _search = '';

  List<Country> get _filtered {
    if (_search.isEmpty) return countries;
    final q = _search.toLowerCase();
    return countries
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.dialCode.contains(q) ||
              c.code.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Text(
                      'Select Country',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextField(
                        autofocus: true,
                        onChanged: (v) => setState(() => _search = v),
                        style: TextStyle(fontSize: 15.sp),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(
                            context,
                          ).searchCountryOrCode,
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textTertiary,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final country = _filtered[index];
                    final isSelected = country.code == widget.selectedCode;
                    return ListTile(
                      leading: Text(
                        country.flag,
                        style: TextStyle(fontSize: 26.sp),
                      ),
                      title: Text(
                        country.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? widget.accent
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: Text(
                        '+${country.dialCode}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: widget.accent.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      onTap: () => widget.onSelected(country),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Country Data ─────────────────────────────────────────────────────────────

/// All supported countries with dial codes and flag emojis.
const List<Country> countries = [
  Country(
    code: 'FR',
    name: 'France',
    dialCode: '33',
    flag: '🇫🇷',
    example: '6 12 34 56 78',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'US',
    name: 'United States',
    dialCode: '1',
    flag: '🇺🇸',
    example: '(201) 555-0123',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'GB',
    name: 'United Kingdom',
    dialCode: '44',
    flag: '🇬🇧',
    example: '7911 123456',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'DE',
    name: 'Germany',
    dialCode: '49',
    flag: '🇩🇪',
    example: '170 1234567',
    minLength: 10,
    maxLength: 11,
  ),
  Country(
    code: 'ES',
    name: 'Spain',
    dialCode: '34',
    flag: '🇪🇸',
    example: '612 345 678',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'IT',
    name: 'Italy',
    dialCode: '39',
    flag: '🇮🇹',
    example: '312 345 6789',
    minLength: 9,
    maxLength: 10,
  ),
  Country(
    code: 'PT',
    name: 'Portugal',
    dialCode: '351',
    flag: '🇵🇹',
    example: '912 345 678',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'NL',
    name: 'Netherlands',
    dialCode: '31',
    flag: '🇳🇱',
    example: '6 12345678',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'BE',
    name: 'Belgium',
    dialCode: '32',
    flag: '🇧🇪',
    example: '470 12 34 56',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'CH',
    name: 'Switzerland',
    dialCode: '41',
    flag: '🇨🇭',
    example: '78 123 45 67',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'AT',
    name: 'Austria',
    dialCode: '43',
    flag: '🇦🇹',
    example: '664 1234567',
    minLength: 10,
    maxLength: 11,
  ),
  Country(
    code: 'SE',
    name: 'Sweden',
    dialCode: '46',
    flag: '🇸🇪',
    example: '70 123 45 67',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'NO',
    name: 'Norway',
    dialCode: '47',
    flag: '🇳🇴',
    example: '412 34 567',
    minLength: 8,
    maxLength: 8,
  ),
  Country(
    code: 'DK',
    name: 'Denmark',
    dialCode: '45',
    flag: '🇩🇰',
    example: '32 12 34 56',
    minLength: 8,
    maxLength: 8,
  ),
  Country(
    code: 'FI',
    name: 'Finland',
    dialCode: '358',
    flag: '🇫🇮',
    example: '41 2345678',
    minLength: 9,
    maxLength: 10,
  ),
  Country(
    code: 'IE',
    name: 'Ireland',
    dialCode: '353',
    flag: '🇮🇪',
    example: '85 012 3456',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'PL',
    name: 'Poland',
    dialCode: '48',
    flag: '🇵🇱',
    example: '512 345 678',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'CZ',
    name: 'Czech Republic',
    dialCode: '420',
    flag: '🇨🇿',
    example: '601 123 456',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'RO',
    name: 'Romania',
    dialCode: '40',
    flag: '🇷🇴',
    example: '712 345 678',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'GR',
    name: 'Greece',
    dialCode: '30',
    flag: '🇬🇷',
    example: '691 234 5678',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'HU',
    name: 'Hungary',
    dialCode: '36',
    flag: '🇭🇺',
    example: '20 123 4567',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'BG',
    name: 'Bulgaria',
    dialCode: '359',
    flag: '🇧🇬',
    example: '87 123 4567',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'HR',
    name: 'Croatia',
    dialCode: '385',
    flag: '🇭🇷',
    example: '91 234 5678',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'SK',
    name: 'Slovakia',
    dialCode: '421',
    flag: '🇸🇰',
    example: '912 123 456',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'LU',
    name: 'Luxembourg',
    dialCode: '352',
    flag: '🇱🇺',
    example: '628 123 456',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'CA',
    name: 'Canada',
    dialCode: '1',
    flag: '🇨🇦',
    example: '(506) 234-5678',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'AU',
    name: 'Australia',
    dialCode: '61',
    flag: '🇦🇺',
    example: '412 345 678',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'NZ',
    name: 'New Zealand',
    dialCode: '64',
    flag: '🇳🇿',
    example: '21 123 4567',
    minLength: 9,
    maxLength: 10,
  ),
  Country(
    code: 'JP',
    name: 'Japan',
    dialCode: '81',
    flag: '🇯🇵',
    example: '90 1234 5678',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'KR',
    name: 'South Korea',
    dialCode: '82',
    flag: '🇰🇷',
    example: '10 1234 5678',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'CN',
    name: 'China',
    dialCode: '86',
    flag: '🇨🇳',
    example: '131 2345 6789',
    minLength: 11,
    maxLength: 11,
  ),
  Country(
    code: 'IN',
    name: 'India',
    dialCode: '91',
    flag: '🇮🇳',
    example: '81234 56789',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'BR',
    name: 'Brazil',
    dialCode: '55',
    flag: '🇧🇷',
    example: '11 91234 5678',
    minLength: 10,
    maxLength: 11,
  ),
  Country(
    code: 'MX',
    name: 'Mexico',
    dialCode: '52',
    flag: '🇲🇽',
    example: '1 234 567 8901',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'AR',
    name: 'Argentina',
    dialCode: '54',
    flag: '🇦🇷',
    example: '11 1234-5678',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'ZA',
    name: 'South Africa',
    dialCode: '27',
    flag: '🇿🇦',
    example: '71 123 4567',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'MA',
    name: 'Morocco',
    dialCode: '212',
    flag: '🇲🇦',
    example: '612-345678',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'TN',
    name: 'Tunisia',
    dialCode: '216',
    flag: '🇹🇳',
    example: '20 123 456',
    minLength: 8,
    maxLength: 8,
  ),
  Country(
    code: 'DZ',
    name: 'Algeria',
    dialCode: '213',
    flag: '🇩🇿',
    example: '551 23 45 67',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'EG',
    name: 'Egypt',
    dialCode: '20',
    flag: '🇪🇬',
    example: '100 123 4567',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'SA',
    name: 'Saudi Arabia',
    dialCode: '966',
    flag: '🇸🇦',
    example: '51 234 5678',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'AE',
    name: 'UAE',
    dialCode: '971',
    flag: '🇦🇪',
    example: '50 123 4567',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'TR',
    name: 'Turkey',
    dialCode: '90',
    flag: '🇹🇷',
    example: '501 234 56 78',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'RU',
    name: 'Russia',
    dialCode: '7',
    flag: '🇷🇺',
    example: '912 345-67-89',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'UA',
    name: 'Ukraine',
    dialCode: '380',
    flag: '🇺🇦',
    example: '50 123 4567',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'SG',
    name: 'Singapore',
    dialCode: '65',
    flag: '🇸🇬',
    example: '8123 4567',
    minLength: 8,
    maxLength: 8,
  ),
  Country(
    code: 'MY',
    name: 'Malaysia',
    dialCode: '60',
    flag: '🇲🇾',
    example: '12 345 6789',
    minLength: 9,
    maxLength: 10,
  ),
  Country(
    code: 'TH',
    name: 'Thailand',
    dialCode: '66',
    flag: '🇹🇭',
    example: '81 234 5678',
    minLength: 9,
    maxLength: 9,
  ),
  Country(
    code: 'PH',
    name: 'Philippines',
    dialCode: '63',
    flag: '🇵🇭',
    example: '905 123 4567',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'NG',
    name: 'Nigeria',
    dialCode: '234',
    flag: '🇳🇬',
    example: '802 123 4567',
    minLength: 10,
    maxLength: 10,
  ),
  Country(
    code: 'KE',
    name: 'Kenya',
    dialCode: '254',
    flag: '🇰🇪',
    example: '712 123456',
    minLength: 9,
    maxLength: 9,
  ),
];
