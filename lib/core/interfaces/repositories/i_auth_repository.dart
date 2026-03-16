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
    String password,
    bool rememberMe,
  );

  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
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
  Future<void> updateUserData(UserModel user);
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

  // Phone Auth / OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String verificationId) onAutoRetrievalTimeout,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    required void Function(PhoneAuthCredential credential)
    onVerificationCompleted,
    int? forceResendingToken,
  });
  Future<UserCredential> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  });

  /// Sign in with a [PhoneAuthCredential] obtained from auto-verification
  /// (Android auto-retrieval). Allows DI-aware sign-in without needing
  /// a raw verificationId/smsCode pair.
  Future<UserCredential> signInWithPhoneAutoCredential(
    PhoneAuthCredential credential,
  );

  // Profile Management
  Future<String?> uploadProfileImage(File image, String uid);
  Future<void> updateUserRole(String uid, UserRole role);
  Future<void> clearNeedsRoleSelection(String uid);

  // User Document Management
  Future<UserModel> createUserDocument(UserModel user);
  Future<void> updateUserStats({
    required String userId,
    int? xpIncrement,
    int? ridesOfferedIncrement,
    int? ridesCompletedIncrement,
  });
}
