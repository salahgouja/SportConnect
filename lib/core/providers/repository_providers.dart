import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/interfaces/repositories/i_auth_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_user_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_ride_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_chat_repository.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';
import 'package:sport_connect/features/messaging/repositories/chat_repository.dart';

part 'repository_providers.g.dart';

// =============================================================================
// 🔧 FIREBASE INSTANCE PROVIDERS (Dependency Injection Foundation)
// =============================================================================

/// Firestore instance provider
///
/// Provides the single source of truth for Firestore instance.
/// This enables easy mocking in tests and switching implementations.
@riverpod
FirebaseFirestore firestoreInstance(Ref ref) {
  return FirebaseFirestore.instance;
}

/// Storage instance provider
///
/// Provides the single source of truth for Firebase Storage instance.
@riverpod
FirebaseStorage storageInstance(Ref ref) {
  return FirebaseStorage.instance;
}

// =============================================================================
// 📦 REPOSITORY PROVIDERS (Interface-Based for DIP Compliance)
// =============================================================================

/// Auth repository provider (interface-based)
///
/// Returns IAuthRepository interface for dependency inversion.
/// This allows for easy mocking in tests and swapping implementations.
///
/// Usage in tests:
/// ```dart
/// final container = ProviderContainer(
///   overrides: [
///     authRepositoryProvider.overrideWithValue(MockAuthRepository()),
///   ],
/// );
/// ```
@riverpod
IAuthRepository authRepository(Ref ref) {
  return AuthRepository();
}

/// User repository provider (interface-based)
///
/// Returns IUserRepository interface for user data operations.
/// Injects dependencies from other providers for proper DIP compliance.
@riverpod
IUserRepository userRepository(Ref ref) {
  final firestore = ref.watch(firestoreInstanceProvider);
  final storage = ref.watch(storageInstanceProvider);
  return ProfileRepository(firestore, storage);
}

/// Ride repository provider (interface-based)
///
/// Returns IRideRepository interface for ride operations.
/// Injects Firestore dependency from provider.
@riverpod
IRideRepository rideRepository(Ref ref) {
  final firestore = ref.watch(firestoreInstanceProvider);
  return RideRepository(firestore);
}

/// Chat repository provider (interface-based)
///
/// Returns IChatRepository interface for chat/messaging operations.
/// Injects both Firestore and Storage dependencies from providers.
@riverpod
IChatRepository chatRepository(Ref ref) {
  final firestore = ref.watch(firestoreInstanceProvider);
  final storage = ref.watch(storageInstanceProvider);
  return ChatRepository(firestore, storage);
}
