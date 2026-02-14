import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/repository_providers.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';
import 'package:sport_connect/features/auth/models/models.dart';

part 'user_providers.g.dart';

/// Auth state changes provider (Firebase User)
@riverpod
Stream<User?> authState(Ref ref) {
  return FirebaseAuth.instance.authStateChanges();
}

/// Current user data provider (Firestore User Model)
@riverpod
Stream<UserModel?> currentUser(Ref ref) {
  final authUser = ref.watch(authStateProvider).value;

  if (authUser == null) {
    return Stream.value(null);
  }

  return AuthRepository().getUserDataStream(authUser.uid);
}
