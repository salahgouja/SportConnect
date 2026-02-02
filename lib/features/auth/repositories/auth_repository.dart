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
import 'package:sport_connect/features/auth/models/user_model.dart';

/// Result of a social sign-in operation
class SocialSignInResult {
  final UserModel? user;
  final bool isNewUser;

  SocialSignInResult({this.user, this.isNewUser = false});
}

/// Repository for authentication operations - Firebase only
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  Future<SocialSignInResult?> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();
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
          // New users default to riders
          final newUser = RiderModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            displayName: userCredential.user!.displayName ?? 'User',
            photoUrl: userCredential.user!.photoURL,
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
    } on GoogleSignInException catch (e) {
      TalkerService.error('Google sign in error: ${e.code}');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Google sign in error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      TalkerService.error('Google sign in error', e);
      rethrow;
    }
    return null;
  }

  /// Sign in with Apple
  Future<SocialSignInResult?> signInWithApple() async {
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

          // New users default to riders
          final newUser = RiderModel(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? appleCredential.email ?? '',
            displayName: displayName,
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
    return null;
  }

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
