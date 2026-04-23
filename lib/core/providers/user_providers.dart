import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart'
    show AuthRepository;

part 'user_providers.g.dart';

/// Auth state changes provider (Firebase User)
@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
  return FirebaseAuth.instance.userChanges();
}

/// Current user data provider (Firestore User Model)
///
/// Uses [authRepositoryProvider] (via DI) so that only one [AuthRepository]
/// instance is shared and its Firestore listener is properly cancelled when
/// the provider is disposed. Creating a bare [AuthRepository()] here on every
/// rebuild would accumulate orphaned snapshot listeners.
@Riverpod(keepAlive: true)
Stream<UserModel?> currentUser(Ref ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  final authUser = await ref.watch(authStateProvider.future);

  if (authUser == null) {
    yield null;
    return;
  }

  yield* repository.getUserDataStream(authUser.uid);
}

/// Pending user's selected role intent during onboarding setup.
///
/// This is stored on the user document as `selectedRoleIntent` so refresh/restart
/// can resume onboarding on the correct screen before role finalization.
@riverpod
Stream<UserRole?> selectedRoleIntent(Ref ref) async* {
  final authUser = await ref.watch(authStateProvider.future);

  if (authUser == null) {
    yield null;
    return;
  }

  yield* FirebaseFirestore.instance
      .collection(AppConstants.usersCollection)
      .doc(authUser.uid)
      .snapshots()
      .map((doc) {
        final raw = doc.data()?['selectedRoleIntent'];
        if (raw is! String) return null;

        return switch (raw) {
          'rider' => UserRole.rider,
          'driver' => UserRole.driver,
          _ => null,
        };
      });
}
