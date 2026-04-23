import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/services/route_guard_service.dart';
import 'package:sport_connect/features/auth/models/models.dart';

void main() {
  const pendingUser = UserModel.pending(
    uid: 'pending-user',
    email: 'pending@example.com',
    username: 'Pending User',
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
}
