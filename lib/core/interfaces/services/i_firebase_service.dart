import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sport_connect/features/auth/models/models.dart';

/// Firebase service interface for testability
abstract class IFirebaseService {
  // Getters for Firebase instances
  FirebaseAuth get auth;
  FirebaseFirestore get firestore;
  FirebaseStorage get storage;
  FirebaseMessaging get messaging;

  // Lifecycle
  Future<void> initialize();

  // Authentication helpers
  User? get currentUser;
  Stream<User?> get authStateChanges;

  // Firestore helpers
  CollectionReference<UserModel> get usersCollection;

  // Emulator support
  bool get useEmulators;
  Future<void> connectToEmulators();
}
