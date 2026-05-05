import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';

part 'user_providers.g.dart';

/// Auth state changes provider (Firebase User)
@Riverpod(keepAlive: true)
Stream<User?> authState(Ref ref) {
  return ref.watch(firebaseServiceProvider).auth.userChanges();
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
  final uid = await ref.watch(currentAuthUidProvider.future);

  if (uid == null) {
    yield null;
    return;
  }

  yield* repository.getUserDataStream(uid);
}

@Riverpod(keepAlive: true)
Future<String?> currentAuthUid(Ref ref) {
  return ref.watch(
    authStateProvider.selectAsync((user) => user?.uid),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium metadata (plan + date — not in freezed model)
// ─────────────────────────────────────────────────────────────────────────────

class PremiumMetadata {
  const PremiumMetadata({
    required this.isPremium,
    this.plan,
    this.updatedAt,
  });
  final bool isPremium;
  final String? plan; // 'monthly' | 'yearly'
  final DateTime? updatedAt;
}

@riverpod
Stream<PremiumMetadata> premiumMetadata(Ref ref) async* {
  final uid = await ref.watch(currentAuthUidProvider.future);
  if (uid == null) {
    yield const PremiumMetadata(isPremium: false);
    return;
  }

  yield* ref
      .read(firebaseServiceProvider)
      .firestore
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .snapshots()
      .map((doc) {
        final data = doc.data();
        if (data == null) return const PremiumMetadata(isPremium: false);

        final isPremium = data['isPremium'] as bool? ?? false;
        final plan = data['premiumPlan'] as String?;
        final rawDate = data['premiumUpdatedAt'];
        DateTime? updatedAt;
        if (rawDate is Timestamp) updatedAt = rawDate.toDate();

        return PremiumMetadata(isPremium: isPremium, plan: plan, updatedAt: updatedAt);
      });
}

/// Pending user's selected role intent during onboarding setup.
///
/// Derived from [currentUserProvider] — no extra Firestore listener.
@Riverpod(keepAlive: true)
UserRole? selectedRoleIntent(Ref ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user is! PendingUserModel) return null;
  return switch (user.selectedRoleIntent) {
    'rider' => UserRole.rider,
    'driver' => UserRole.driver,
    _ => null,
  };
}
