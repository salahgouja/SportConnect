import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/core/interfaces/repositories/i_auth_repository.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    late IAuthRepository authRepository;

    setUp(() {
      authRepository = AuthRepository();
    });

    test('should implement IAuthRepository interface', () {
      expect(authRepository, isA<IAuthRepository>());
    });

    test('should return false when user is not logged in', () {
      expect(authRepository.isLoggedIn, isFalse);
    });

    test('should have null currentUser when not logged in', () {
      expect(authRepository.currentUser, isNull);
    });

    test('should have null currentUserId when not logged in', () {
      expect(authRepository.currentUserId, isNull);
    });

    // Add more tests as needed:
    // - Test sign in with email
    // - Test register
    // - Test social auth
    // - Test password reset
    // - Test sign out
  });
}
