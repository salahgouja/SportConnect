import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/route_guard_service.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/payments/models/payment_model.dart';

void main() {
  const pendingUser = UserModel.pending(
    uid: 'pending-user',
    email: 'pending@example.com',
    username: 'Pending User',
  );
  const incompleteDriver = UserModel.driver(
    uid: 'driver-user',
    email: 'driver@example.com',
    username: 'Driver User',
    phoneNumber: '555-0100',
  );
  const riderUser = UserModel.rider(
    uid: 'rider-user',
    email: 'rider@example.com',
    username: 'Rider User',
    isEmailVerified: true,
  );
  const onboardedDriver = UserModel.driver(
    uid: 'driver-user',
    email: 'driver@example.com',
    username: 'Driver User',
    phoneNumber: '555-0100',
    vehicleIds: ['vehicle-1'],
    isEmailVerified: true,
  );
  const connectedAccount = DriverConnectedAccount(
    id: 'acct-doc',
    driverId: 'driver-user',
    stripeAccountId: 'acct_123',
    email: 'driver@example.com',
    country: 'US',
    defaultCurrency: 'usd',
    chargesEnabled: true,
    payoutsEnabled: true,
    detailsSubmitted: true,
    capabilities: StripeCapabilities(
      transfers: StripeCapabilityStatus.active,
    ),
  );

  RouteGuardService buildGuard({UserRole? selectedRoleIntent}) {
    return RouteGuardService(
      isLoading: false,
      user: pendingUser,
      needsRoleSelection: true,
      selectedRoleIntent: selectedRoleIntent,
    );
  }

  group('RouteGuardService role intent redirects', () {
    test('keeps pending users on role selection until intent is saved', () {
      final guard = buildGuard();

      expect(
        guard.getRedirect(Uri.parse(AppRoutes.roleSelection.path)),
        isNull,
      );
    });

    test('redirects pending users from role selection to saved intent', () {
      final guard = buildGuard(selectedRoleIntent: UserRole.driver);

      expect(
        guard.getRedirect(Uri.parse(AppRoutes.roleSelection.path)),
        AppRoutes.driverOnboarding.path,
      );
    });

    test('resumes onboarding from splash using saved role intent', () {
      final guard = buildGuard(selectedRoleIntent: UserRole.rider);

      expect(
        guard.getRedirect(Uri.parse(AppRoutes.splash.path)),
        AppRoutes.riderOnboarding.path,
      );
    });
  });

  group('RouteGuardService email verification redirects', () {
    RouteGuardService buildDriverGuard({required bool isEmailVerified}) {
      return RouteGuardService(
        isLoading: false,
        user: incompleteDriver,
        hasCompletedOnboarding: true,
        isEmailVerified: isEmailVerified,
        hasVerifiableEmail: true,
      );
    }

    test(
      'sends verified incomplete drivers from email verification to setup',
      () {
        final guard = buildDriverGuard(isEmailVerified: true);

        expect(
          guard.getRedirect(Uri.parse(AppRoutes.emailVerification.path)),
          '${AppRoutes.driverOnboarding.path}?skipProfile=true',
        );
      },
    );

    test(
      'does not bounce incomplete drivers from setup back to verification',
      () {
        final guard = buildDriverGuard(isEmailVerified: false);

        expect(
          guard.getRedirect(
            Uri.parse('${AppRoutes.driverOnboarding.path}?skipProfile=true'),
          ),
          isNull,
        );
      },
    );

    test('still sends other unverified driver routes to verification', () {
      final guard = buildDriverGuard(isEmailVerified: false);

      expect(
        guard.getRedirect(Uri.parse(AppRoutes.driverHome.path)),
        AppRoutes.emailVerification.path,
      );
    });
  });

  group('RouteGuardService main journeys', () {
    test('allows signed-out users to open signup after app onboarding', () {
      const guard = RouteGuardService(
        isLoading: false,
        user: null,
        hasCompletedOnboarding: true,
      );

      expect(guard.getRedirect(Uri.parse(AppRoutes.signupWizard.path)), isNull);
    });

    test('protects rider booking entry while signed out', () {
      const guard = RouteGuardService(
        isLoading: false,
        user: null,
        hasCompletedOnboarding: true,
      );

      expect(
        guard.getRedirect(Uri.parse('/ride/booking-pending/ride-1')),
        '${AppRoutes.login.path}?redirect=%2Fride%2Fbooking-pending%2Fride-1',
      );
    });

    test('allows rider active ride notification entry', () {
      const guard = RouteGuardService(
        isLoading: false,
        user: riderUser,
        hasCompletedOnboarding: true,
        isEmailVerified: true,
        hasVerifiableEmail: true,
      );

      expect(
        guard.getRedirect(
          Uri.parse('${AppRoutes.riderActiveRide.path}?rideId=ride-1'),
        ),
        isNull,
      );
    });

    test('sends incomplete drivers to vehicle onboarding from splash', () {
      const guard = RouteGuardService(
        isLoading: false,
        user: incompleteDriver,
        hasCompletedOnboarding: true,
        isEmailVerified: true,
        hasVerifiableEmail: true,
      );

      expect(
        guard.getRedirect(Uri.parse(AppRoutes.splash.path)),
        '${AppRoutes.driverOnboarding.path}?skipProfile=true',
      );
    });

    test(
      'sends onboarded drivers without Stripe setup to Stripe onboarding',
      () {
        const guard = RouteGuardService(
          isLoading: false,
          user: onboardedDriver,
          hasCompletedOnboarding: true,
          isEmailVerified: true,
          hasVerifiableEmail: true,
        );

        expect(
          guard.getRedirect(Uri.parse(AppRoutes.driverHome.path)),
          AppRoutes.driverStripeOnboarding.path,
        );
      },
    );

    test('sends fully onboarded drivers from Stripe return to dashboard', () {
      const guard = RouteGuardService(
        isLoading: false,
        user: onboardedDriver,
        hasCompletedOnboarding: true,
        isEmailVerified: true,
        hasVerifiableEmail: true,
        currentDriverConnectedAccount: connectedAccount,
      );

      expect(
        guard.getRedirect(Uri.parse(AppRoutes.driverStripeOnboarding.path)),
        AppRoutes.driverHome.path,
      );
    });
  });
}
