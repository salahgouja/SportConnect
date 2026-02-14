import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

/// Firestore instance provider
///
/// Provides the single source of truth for Firestore instance.
/// This enables easy mocking in tests and switching implementations.
@riverpod
FirebaseFirestore firestoreInstance(Ref ref) {
  return FirebaseFirestore.instance;
}

/// Storage instance provider
///
/// Provides the single source of truth for Firebase Storage instance.
@riverpod
FirebaseStorage storageInstance(Ref ref) {
  return FirebaseStorage.instance;
}
