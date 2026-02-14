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

/// Result of a social sign-in operation
class SocialSignInResult {
  final UserModel? user;
  final bool isNewUser;

  SocialSignInResult({this.user, this.isNewUser = false});
}

/// Repository for authentication operations - Firebase only
class AuthRepository implements IAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Sign in with email and password
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
          userModel = DriverModel(
            uid: uid,
            email: email.trim(),
            displayName: displayName.trim(),
            phoneNumber: phone?.trim(),
            bio: bio?.trim(),
            interests: interests,
            photoUrl: photoUrl,
            rating: const RatingBreakdown(),
            gamification: const DriverGamificationStats(),
            preferences: const UserPreferences(),
            createdAt: DateTime.now(),
            lastSeenAt: DateTime.now(),
          );
        } else {
          userModel = RiderModel(
            uid: uid,
            email: email.trim(),
            displayName: displayName.trim(),
            phoneNumber: phone?.trim(),
            bio: bio?.trim(),
            interests: interests,
            photoUrl: photoUrl,
            rating: const RatingBreakdown(),
            gamification: const RiderGamificationStats(),
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
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await _auth.signOut();
      TalkerService.info('User signed out');
    } catch (e) {
      TalkerService.error('Sign out error', e);
      rethrow;
    }
  }

  /// Delete user account and all associated data
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final uid = user.uid;
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(
        _firestore.collection(AppConstants.usersCollection).doc(uid),
      );

      // Delete user's rides
      final ridesQuery = await _firestore
          .collection('rides')
          .where('driverId', isEqualTo: uid)
          .get();
      for (var doc in ridesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's bookings
      final bookingsQuery = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: uid)
          .get();
      for (var doc in bookingsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's messages
      final messagesQuery = await _firestore
          .collection('messages')
          .where('senderId', isEqualTo: uid)
          .get();
      for (var doc in messagesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user's chats
      final chatsQuery = await _firestore
          .collection('chats')
          .where('participants', arrayContains: uid)
          .get();
      for (var doc in chatsQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      await GoogleSignIn.instance.signOut();
      await user.delete();

      TalkerService.info('User account and data deleted: $uid');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Delete account error: ${e.message}');
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'Please log out and log in again before deleting your account',
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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
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
          final newUser = RiderModel(
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
          final newUser = RiderModel(
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
      throw e.message;
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

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      TalkerService.info('Password reset email sent');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Reset password error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      TalkerService.error('Reset password error', e);
      rethrow;
    }
  }

  /// Create or update user document in Firestore
  /// Useful for syncing Firebase Auth user with Firestore document
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

  /// Update user gamification stats (XP, rides, etc.)
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

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return e.message ?? 'An error occurred';
    }
  }
}
