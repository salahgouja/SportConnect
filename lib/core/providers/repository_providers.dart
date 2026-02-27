import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/interfaces/repositories/i_auth_repository.dart';
import 'package:sport_connect/core/providers/firebase_providers.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';

part 'repository_providers.g.dart';

// =============================================================================
// 📦 REPOSITORY PROVIDERS (Interface-Based for DIP Compliance)
// =============================================================================

/// Auth repository provider (interface-based).
///
/// Returns [IAuthRepository] for dependency inversion, enabling mocking in
/// tests. All Firebase instances are injected via [firebase_providers.dart].
///
/// ```dart
/// // Test override example:
/// final container = ProviderContainer(
///   overrides: [
///     authRepositoryProvider.overrideWithValue(MockAuthRepository()),
///   ],
/// );
/// ```
@riverpod
IAuthRepository authRepository(Ref ref) {
  final auth = ref.watch(authInstanceProvider);
  final storage = ref.watch(storageInstanceProvider);
  final firestore = ref.watch(firestoreInstanceProvider);
  return AuthRepository(auth, storage, firestore);
}
