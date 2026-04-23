import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sport_connect/features/auth/models/models.dart';

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
    String password, {
    bool rememberMe = false,
  });

  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required UserRole role,
    String? phone,
    File? profileImage,
  });

  // Social Auth
  Future<SocialSignInResult> signInWithGoogle();
  Future<SocialSignInResult> signInWithApple();

  // User Management
  Future<UserModel?> getUserData(String uid);
  Stream<UserModel?> getUserDataStream(String uid);
  Future<void> signOut();
  Future<void> deleteAccount();

  // Password Management
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updatePassword(String newPassword);

  // Re-authentication (for sensitive operations)
  Future<void> reauthenticateWithPassword(String password);
  Future<void> reauthenticateWithGoogle();

  // Email Verification
  Future<void> sendEmailVerification();
  Future<bool> isEmailVerified();
  Future<void> reloadUser();

  // Profile Management
  Future<String?> uploadProfileImage(File image, String uid);
  Future<void> updateUserRole(String uid, UserRole role);
  Future<UserModel> finalizeRoleAs(String uid, UserRole role);

  // User Document Management
  Future<UserModel> createUserDocument(UserModel user);
  Future<void> updateUserStats({
    required String userId,
    int? xpIncrement,
    int? ridesOfferedIncrement,
    int? ridesCompletedIncrement,
  });
}
