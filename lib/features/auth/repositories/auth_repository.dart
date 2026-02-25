import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_auth_repository.dart';
import 'package:sport_connect/features/auth/models/models.dart';

/// Repository for authentication operations - Firebase only
class AuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  /// Creates an [AuthRepository] with optional dependency injection.
  ///
  /// Defaults to production Firebase instances when no arguments are provided.
  /// Pass custom instances in tests to enable mocking.
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  /// Get current user stream
  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  @override
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  @override
  bool get isLoggedIn => _auth.currentUser != null;

  /// Get current user ID
  @override
  String? get currentUserId => _auth.currentUser?.uid;

  /// Sign in with email and password
  @override
  Future<UserModel?> signInWithEmail(
    String email,
    String password,
    bool rememberMe,
  ) async {
    try {
      if (kIsWeb) {
        await _auth.setPersistence(
          rememberMe ? Persistence.LOCAL : Persistence.SESSION,
        );
      }
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        return await getUserData(credential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Sign in error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      TalkerService.error('Sign in error', e);
      rethrow;
    }
    return null;
  }

  /// Register with email and password
  @override
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? phone,
    String? bio,
    List<String> interests = const [],
    File? profileImage,
  }) async {
    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        String? photoUrl;
        final uid = credential.user!.uid;

        // 2. 📸 Upload Image to Storage (if one was selected)
        if (profileImage != null) {
          photoUrl = await _uploadProfileImage(profileImage, uid);
        }

        // 3. Create User Model with the new Photo URL
        final UserModel userModel;
        if (role == UserRole.driver) {
          userModel = UserModel.driver(
            uid: uid,
            email: email.trim(),
            displayName: displayName.trim(),
            phoneNumber: phone?.trim(),
            bio: bio?.trim(),
            interests: interests,
            photoUrl: photoUrl,
            rating: const RatingBreakdown(),
            gamification: const GamificationStats.driver(),
            preferences: const UserPreferences(),
            createdAt: DateTime.now(),
            lastSeenAt: DateTime.now(),
          );
        } else {
          userModel = UserModel.rider(
            uid: uid,
            email: email.trim(),
            displayName: displayName.trim(),
            phoneNumber: phone?.trim(),
            bio: bio?.trim(),
            interests: interests,
            photoUrl: photoUrl,
            rating: const RatingBreakdown(),
            gamification: const GamificationStats.rider(),
            preferences: const UserPreferences(),
            createdAt: DateTime.now(),
            lastSeenAt: DateTime.now(),
          );
        }

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .set(userModel.toJson());
        await credential.user!.updateDisplayName(displayName);

        if (photoUrl != null) {
          await credential.user!.updatePhotoURL(photoUrl);
        }

        // Auto-send email verification after registration
        if (!(credential.user!.emailVerified)) {
          await credential.user!.sendEmailVerification();
        }

        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Register error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      if (credential?.user != null) {
        TalkerService.warning('Rolling back user creation due to error');
        await credential!.user!.delete();
      }
      TalkerService.error('Register error', e);
      rethrow;
    }
    return null;
  }

  Future<String?> _uploadProfileImage(File image, String uid) async {
    try {
      // Create a reference: users/{uid}/profile_pic.jpg
      final ref = _storage
          .ref()
          .child('users') // Hardcode 'users' to match rules exactly
          .child(uid)
          .child('profile') // <--- Added this folder to match rules
          .child('profile.jpg');

      // Upload the file
      final uploadTask = await ref.putFile(image);

      // Get the download URL
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      TalkerService.error('Image upload failed', e);
      // We return null so the registration doesn't fail completely
      // just because the image failed.
      return null;
    }
  }

  /// Get user data from Firestore
  @override
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (e) {
      TalkerService.error('Get user data error', e);
    }
    return null;
  }

  @override
  Stream<UserModel?> getUserDataStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return UserModel.fromJson(doc.data()!);
          }
          return null;
        });
  }

  /// Sign out
  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      TalkerService.info('User signed out');
    } catch (e) {
      TalkerService.error('Sign out error', e);
      rethrow;
    }
  }

  /// Delete user account and all associated data
  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final uid = user.uid;

      // Collect all document references to delete
      final refs = <DocumentReference>[
        _firestore.collection(AppConstants.usersCollection).doc(uid),
      ];

      // User's rides
      final ridesQuery = await _firestore
          .collection('rides')
          .where('driverId', isEqualTo: uid)
          .get();
      refs.addAll(ridesQuery.docs.map((d) => d.reference));

      // User's bookings
      final bookingsQuery = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: uid)
          .get();
      refs.addAll(bookingsQuery.docs.map((d) => d.reference));

      // User's messages
      final messagesQuery = await _firestore
          .collection('messages')
          .where('senderId', isEqualTo: uid)
          .get();
      refs.addAll(messagesQuery.docs.map((d) => d.reference));

      // User's chats
      final chatsQuery = await _firestore
          .collection('chats')
          .where('participants', arrayContains: uid)
          .get();
      refs.addAll(chatsQuery.docs.map((d) => d.reference));

      // Commit in chunks of 499 to stay within Firestore batch limit (500)
      const batchLimit = 499;
      for (var i = 0; i < refs.length; i += batchLimit) {
        final chunk = refs.sublist(
          i,
          i + batchLimit > refs.length ? refs.length : i + batchLimit,
        );
        final batch = _firestore.batch();
        for (final ref in chunk) {
          batch.delete(ref);
        }
        await batch.commit();
      }

      // Clean up storage (profile images)
      try {
        await _storage.ref().child('users').child(uid).listAll().then((
          result,
        ) async {
          for (final ref in result.items) {
            await ref.delete();
          }
          for (final prefix in result.prefixes) {
            final subItems = await prefix.listAll();
            for (final item in subItems.items) {
              await item.delete();
            }
          }
        });
      } on FirebaseException catch (e) {
        TalkerService.warning(
          'Storage cleanup failed (best-effort): ${e.message}',
        );
      }

      await _googleSignIn.signOut();
      await user.delete();

      TalkerService.info('User account and data deleted: $uid');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Delete account error: ${e.message}');
      if (e.code == 'requires-recent-login') {
        throw AuthException(
          code: e.code,
          message: 'Please re-authenticate before deleting your account',
        );
      }
      throw _handleAuthException(e);
    } catch (e) {
      TalkerService.error('Delete account error', e);
      rethrow;
    }
  }

  /// Sign in with Google
  @override
  Future<SocialSignInResult> signInWithGoogle() async {
    try {
      // Initialize GoogleSignIn if needed (required in v7.x+)
      await _googleSignIn.initialize();

      // Use authenticate() instead of signIn() in v7.x+
      // authenticate() returns non-nullable account, throws on cancellation
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        UserModel? existingUser = await getUserData(userCredential.user!.uid);

        if (existingUser != null) {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .update({'lastSeenAt': FieldValue.serverTimestamp()});
          return SocialSignInResult(user: existingUser, isNewUser: false);
        } else {
          // New users default to riders with pending role selection
          final newUser = UserModel.rider(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            displayName: userCredential.user!.displayName ?? 'User',
            photoUrl: userCredential.user!.photoURL,
            needsRoleSelection: true,
            createdAt: DateTime.now(),
            lastSeenAt: DateTime.now(),
          );

          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .set(newUser.toJson());

          TalkerService.info('New user created via Google sign in');
          return SocialSignInResult(user: newUser, isNewUser: true);
        }
      }

      throw Exception('Google sign-in failed: no user returned');
    } on GoogleSignInException catch (e) {
      // GoogleSignIn v7.x throws GoogleSignInException instead of returning null
      TalkerService.error(
        'Google sign in cancelled or failed: ${e.description}',
      );
      throw Exception('Google sign-in cancelled by user: ${e.description}');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Google sign in error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      TalkerService.error('Google sign in error', e);
      rethrow;
    }
  }

  /// Sign in with Apple
  @override
  Future<SocialSignInResult> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      if (userCredential.user != null) {
        UserModel? existingUser = await getUserData(userCredential.user!.uid);

        if (existingUser != null) {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .update({'lastSeenAt': FieldValue.serverTimestamp()});
          return SocialSignInResult(user: existingUser, isNewUser: false);
        } else {
          String displayName = 'User';
          if (appleCredential.givenName != null) {
            displayName =
                '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
                    .trim();
          } else if (userCredential.user!.displayName != null) {
            displayName = userCredential.user!.displayName!;
          }

          // New users default to riders with pending role selection
          final newUser = UserModel.rider(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? appleCredential.email ?? '',
            displayName: displayName,
            needsRoleSelection: true,
            createdAt: DateTime.now(),
            lastSeenAt: DateTime.now(),
          );

          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .set(newUser.toJson());

          TalkerService.info('New user created via Apple sign in');
          return SocialSignInResult(user: newUser, isNewUser: true);
        }
      }

      throw Exception('Apple sign-in failed: no user returned');
    } on SignInWithAppleAuthorizationException catch (e) {
      TalkerService.error('Apple sign in error: ${e.message}');
      throw Exception('Apple sign-in failed: ${e.message}');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Apple sign in Firebase error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      TalkerService.error('Apple sign in error', e);
      rethrow;
    }
  }

  /// Helpers
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Create or update user document in Firestore.
  ///
  /// Useful for syncing Firebase Auth user with Firestore document.
  @override
  Future<UserModel> createUserDocument(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toJson(), SetOptions(merge: true));
      TalkerService.info('User document created/updated for ${user.uid}');
      return user;
    } catch (e) {
      TalkerService.error('Create user document error', e);
      rethrow;
    }
  }

  /// Update user gamification stats (XP, rides, etc.).
  @override
  Future<void> updateUserStats({
    required String userId,
    int? xpIncrement,
    int? ridesOfferedIncrement,
    int? ridesCompletedIncrement,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (xpIncrement != null) {
        updates['xp'] = FieldValue.increment(xpIncrement);
      }
      if (ridesOfferedIncrement != null) {
        updates['ridesOffered'] = FieldValue.increment(ridesOfferedIncrement);
      }
      if (ridesCompletedIncrement != null) {
        updates['ridesCompleted'] = FieldValue.increment(
          ridesCompletedIncrement,
        );
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);
      TalkerService.info('User stats updated for $userId');
    } catch (e) {
      TalkerService.error('Update user stats error', e);
      rethrow;
    }
  }

  /// Update user role (rider/driver)
  @override
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
            'role': role.name,
            'isDriver': role == UserRole.driver,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      TalkerService.info('User role updated to ${role.name} for $userId');
    } catch (e) {
      TalkerService.error('Update user role error', e);
      rethrow;
    }
  }

  /// Clear the needsRoleSelection flag after onboarding is complete
  @override
  Future<void> clearNeedsRoleSelection(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
            'needsRoleSelection': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      TalkerService.info('Cleared needsRoleSelection for $userId');
    } catch (e) {
      TalkerService.error('Clear needsRoleSelection error', e);
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      TalkerService.info('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Password reset error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      TalkerService.error('Password reset error', e);
      rethrow;
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      await user.updatePassword(newPassword);
      TalkerService.info('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Update password error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      TalkerService.error('Update password error', e);
      rethrow;
    }
  }

  @override
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
            ...user.toJson(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      TalkerService.info('User data updated for ${user.uid}');
    } catch (e) {
      TalkerService.error('Update user data error', e);
      rethrow;
    }
  }

  @override
  Future<String?> uploadProfileImage(File image, String uid) async {
    return await _uploadProfileImage(image, uid);
  }

  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException(
          code: e.code,
          message: 'No user found with this email',
        );
      case 'wrong-password':
        return AuthException(code: e.code, message: 'Wrong password');
      case 'email-already-in-use':
        return AuthException(code: e.code, message: 'Email already in use');
      case 'invalid-email':
        return AuthException(code: e.code, message: 'Invalid email address');
      case 'weak-password':
        return AuthException(code: e.code, message: 'Password is too weak');
      case 'too-many-requests':
        return AuthException(
          code: e.code,
          message: 'Too many attempts. Please try again later',
        );
      case 'requires-recent-login':
        return AuthException(
          code: e.code,
          message: 'Please re-authenticate to continue',
        );
      case 'account-exists-with-different-credential':
        return AuthException(
          code: e.code,
          message:
              'An account already exists with a different sign-in method. '
              'Try signing in with email/password or the original provider.',
        );
      default:
        return AuthException(
          code: e.code,
          message: e.message ?? 'An error occurred',
        );
    }
  }

  /// Re-authenticate user with email/password for sensitive operations.
  ///
  /// Required before [deleteAccount] or [updatePassword] when the session
  /// is too old (Firebase throws `requires-recent-login`).
  @override
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user is currently signed in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      TalkerService.info('User re-authenticated successfully');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Re-authentication error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      TalkerService.error('Re-authentication error', e);
      rethrow;
    }
  }

  /// Re-authenticate user with Google credential for sensitive operations.
  @override
  Future<void> reauthenticateWithGoogle() async {
    try {
      await _googleSignIn.initialize();
      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      await user.reauthenticateWithCredential(credential);
      TalkerService.info('User re-authenticated with Google');
    } catch (e) {
      TalkerService.error('Google re-authentication error', e);
      rethrow;
    }
  }

  // =========================================================================
  // Email Verification
  // =========================================================================

  /// Send a verification email to the current user.
  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      await user.sendEmailVerification();
      TalkerService.info('Verification email sent to ${user.email}');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Send verification email error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      TalkerService.error('Send verification email error', e);
      rethrow;
    }
  }

  /// Check whether the current user's email is verified.
  ///
  /// Reloads the user first to get the latest status from Firebase.
  @override
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Reload the current Firebase Auth user to refresh cached properties
  /// such as [User.emailVerified].
  @override
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // =========================================================================
  // Phone Auth / OTP
  // =========================================================================

  /// Start phone number verification — Firebase sends an SMS OTP.
  ///
  /// The caller provides callbacks for each phase of the verification:
  /// - [onCodeSent]: SMS sent; use the verificationId to create credential.
  /// - [onVerificationCompleted]: Auto-verified (Android auto-retrieval).
  /// - [onVerificationFailed]: Error (invalid number, quota exceeded, etc).
  /// - [onAutoRetrievalTimeout]: Auto-retrieval timed out; user must enter OTP manually.
  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String verificationId) onAutoRetrievalTimeout,
    required void Function(FirebaseAuthException error) onVerificationFailed,
    required void Function(PhoneAuthCredential credential)
    onVerificationCompleted,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onAutoRetrievalTimeout,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Sign in (or link) with a phone credential built from verificationId + smsCode.
  @override
  Future<UserCredential> signInWithPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _auth.signInWithCredential(credential);
      TalkerService.info('Phone OTP sign-in successful');
      return result;
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Phone OTP error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      TalkerService.error('Phone OTP error', e);
      rethrow;
    }
  }

  /// Signs in with a pre-built [PhoneAuthCredential] from auto-verification.
  @override
  Future<UserCredential> signInWithPhoneAutoCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      final result = await _auth.signInWithCredential(credential);
      TalkerService.info('Phone auto-verification sign-in successful');
      return result;
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Phone auto-verification error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      TalkerService.error('Phone auto-verification error', e);
      rethrow;
    }
  }
}
