import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  DocumentReference<Map<String, dynamic>> getUserDoc(String uid);
  CollectionReference<Map<String, dynamic>> get usersCollection;

  // Emulator support
  bool get useEmulators;
  Future<void> connectToEmulators();
}
