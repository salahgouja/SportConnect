import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';

/// Authentication repository interface for dependency inversion
abstract class IAuthRepository {
  // Stream and getters
  Stream<User?> get authStateChanges;
  User? get currentUser;
  bool get isLoggedIn;
  String? get currentUserId;

  // Email & Password Auth
  Future<UserModel?> signInWithEmail(
    String email,
    String password,
    bool rememberMe,
  );

  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? phone,
    String? bio,
    List<String> interests = const [],
    File? profileImage,
  });

  // Social Auth
  Future<SocialSignInResult> signInWithGoogle();
  Future<SocialSignInResult> signInWithApple();

  // User Management
  Future<UserModel?> getUserData(String uid);
  Future<void> updateUserData(UserModel user);
  Future<void> signOut();
  Future<void> deleteAccount();

  // Password Management
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updatePassword(String newPassword);

  // Profile Management
  Future<String?> uploadProfileImage(File image, String uid);
  Future<void> updateUserRole(String uid, UserRole role);
  Future<void> clearNeedsRoleSelection(String uid);
}
