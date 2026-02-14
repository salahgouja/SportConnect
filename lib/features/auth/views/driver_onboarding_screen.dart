import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/premium_text_field.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Driver Onboarding Screen - Multi-step wizard for new drivers
/// Step 1: Add vehicle information
/// Step 2: Setup Stripe for payouts
class DriverOnboardingScreen extends ConsumerStatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  ConsumerState<DriverOnboardingScreen> createState() =>
      _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState
    extends ConsumerState<DriverOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Vehicle form controllers
  final _vehicleFormKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _seatsController = TextEditingController(text: '4');
  FuelType _selectedFuelType = FuelType.gasoline;

  final List<FuelType> _fuelTypes = [
    FuelType.gasoline,
    FuelType.diesel,
    FuelType.electric,
    FuelType.hybrid,
    FuelType.hydrogen,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _licensePlateController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_vehicleFormKey.currentState!.validate()) return;
    }

    if (_currentStep < 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _saveVehicleAndContinue() async {
    if (!_vehicleFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentUserProvider).value;

      if (currentUser != null) {
        final driver = currentUser.asDriver!;

        // Create vehicle object
        final vehicle = VehicleModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          ownerId: driver.uid,
          ownerName: driver.displayName,
          ownerPhotoUrl: driver.photoUrl,
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text.trim()),
          color: _colorController.text.trim(),
          licensePlate: _licensePlateController.text.trim().toUpperCase(),
          capacity: int.parse(_seatsController.text.trim()),
          fuelType: _selectedFuelType,
          isActive: true,
          verificationStatus: VehicleVerificationStatus.pending,
        );

        // Add vehicle to user's profile
        final vehicleViewModel = ref.read(
          vehicleViewModelProvider(currentUser.uid).notifier,
        );
        await vehicleViewModel.addVehicle(vehicle);

        _nextStep();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).errorSavingVehicleValue(e.toString()),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setupStripe() async {
    // Clear the needsRoleSelection flag — driver setup is complete
    final authActions = ref.read(authActionsViewModelProvider);
    final uid = authActions.currentUser?.uid;
    if (uid != null) {
      await authActions.clearNeedsRoleSelection(uid);
    }
    if (mounted) context.go(AppRoutes.driverStripeOnboarding.path);
  }

  Future<void> _skipStripeForNow() async {
    // Clear the needsRoleSelection flag — driver setup is complete
    final authActions = ref.read(authActionsViewModelProvider);
    final uid = authActions.currentUser?.uid;
    if (uid != null) {
      await authActions.clearNeedsRoleSelection(uid);
    }
    if (mounted) context.go(AppRoutes.driverHome.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                onPressed: _previousStep,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              )
            : IconButton(
                onPressed: () => context.go(AppRoutes.roleSelection.path),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
        title: Text(
          AppLocalizations.of(context).driverSetup,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildVehicleStep(), _buildStripeStep()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: [
          _buildStepIndicator(
            0,
            AppLocalizations.of(context).vehicle,
            Icons.directions_car_outlined,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: _currentStep >= 1 ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          _buildStepIndicator(
            1,
            AppLocalizations.of(context).payouts,
            Icons.account_balance_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surfaceVariant,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AppColors.primaryLight, width: 2)
                : null,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : AppColors.textTertiary,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _vehicleFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildStepHeader(
              icon: Icons.directions_car_rounded,
              title: AppLocalizations.of(context).addYourVehicle,
              subtitle: 'Tell us about your car so riders know what to expect.',
            ).animate().fadeIn(duration: 400.ms),

            SizedBox(height: 24.h),

            // Vehicle Make
            PremiumTextField(
              controller: _makeController,
              label: 'Make',
              hint: 'e.g., Toyota, Honda, BMW',
              prefixIcon: Icons.business_rounded,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle make';
                }
                return null;
              },
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            SizedBox(height: 16.h),

            // Vehicle Model
            PremiumTextField(
              controller: _modelController,
              label: 'Model',
              hint: 'e.g., Corolla, Civic, 3 Series',
              prefixIcon: Icons.directions_car_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vehicle model';
                }
                return null;
              },
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

            SizedBox(height: 16.h),

            // Year and Color row
            Row(
              children: [
                Expanded(
                  child: PremiumTextField(
                    controller: _yearController,
                    label: 'Year',
                    hint: 'e.g., 2020',
                    prefixIcon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final year = int.tryParse(value);
                      if (year == null ||
                          year < 1990 ||
                          year > DateTime.now().year + 1) {
                        return 'Invalid year';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PremiumTextField(
                    controller: _colorController,
                    label: 'Color',
                    hint: 'e.g., White',
                    prefixIcon: Icons.palette_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            SizedBox(height: 16.h),

            // License Plate
            PremiumTextField(
              controller: _licensePlateController,
              label: 'License Plate',
              hint: 'e.g., ABC 123',
              prefixIcon: Icons.credit_card_rounded,
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter license plate';
                }
                return null;
              },
            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

            SizedBox(height: 16.h),

            // Seats
            PremiumTextField(
              controller: _seatsController,
              label: 'Available Seats',
              hint: '4',
              prefixIcon: Icons.event_seat_rounded,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of seats';
                }
                final seats = int.tryParse(value);
                if (seats == null || seats < 1 || seats > 8) {
                  return 'Enter 1-8 seats';
                }
                return null;
              },
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            SizedBox(height: 16.h),

            // Fuel Type dropdown
            Text(
              AppLocalizations.of(context).fuelType,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<FuelType>(
                  value: _selectedFuelType,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                  items: _fuelTypes.map((fuel) {
                    return DropdownMenuItem(
                      value: fuel,
                      child: Text(
                        fuel.displayName,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedFuelType = value!);
                  },
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

            SizedBox(height: 32.h),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: PremiumButton(
                text: 'Save & Continue',
                onPressed: _isLoading ? null : _saveVehicleAndContinue,
                isLoading: _isLoading,
                style: PremiumButtonStyle.primary,
                size: PremiumButtonSize.large,
                trailingIcon: Icons.arrow_forward_rounded,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStripeStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildStepHeader(
            icon: Icons.account_balance_rounded,
            title: AppLocalizations.of(context).setupPayouts,
            subtitle:
                'Connect your bank account to receive payments from your rides.',
          ).animate().fadeIn(duration: 400.ms),

          SizedBox(height: 32.h),

          // Stripe benefits card
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(15),
                  AppColors.secondary.withAlpha(10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary.withAlpha(30)),
            ),
            child: Column(
              children: [
                _buildBenefitItem(
                  icon: Icons.security_rounded,
                  title: AppLocalizations.of(context).securePayments,
                  description: 'Powered by Stripe, trusted by millions',
                ),
                SizedBox(height: 16.h),
                _buildBenefitItem(
                  icon: Icons.flash_on_rounded,
                  title: AppLocalizations.of(context).fastTransfers,
                  description: 'Get paid within 2-3 business days',
                ),
                SizedBox(height: 16.h),
                _buildBenefitItem(
                  icon: Icons.receipt_long_rounded,
                  title: AppLocalizations.of(context).easyTracking,
                  description: 'View all your earnings in one place',
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          SizedBox(height: 32.h),

          // Setup Stripe button
          SizedBox(
            width: double.infinity,
            child: PremiumButton(
              text: 'Connect with Stripe',
              onPressed: _setupStripe,
              style: PremiumButtonStyle.primary,
              size: PremiumButtonSize.large,
              icon: Icons.link_rounded,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

          SizedBox(height: 16.h),

          // Skip button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _skipStripeForNow,
              child: Text(
                AppLocalizations.of(context).skipForNowILl,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

          SizedBox(height: 16.h),

          // Info note
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.info.withAlpha(30)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.info,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).youCanStillOfferRides,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildStepHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 32.sp),
        ),
        SizedBox(height: 16.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.sp),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
