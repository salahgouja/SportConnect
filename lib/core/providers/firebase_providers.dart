import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

/// Provides the single source of truth for the Firestore instance.
/// Enables easy mocking in tests by overriding this provider.
@riverpod
FirebaseFirestore firestoreInstance(Ref ref) => FirebaseFirestore.instance;

/// Provides the single source of truth for the Firebase Storage instance.
/// Enables easy mocking in tests by overriding this provider.
@riverpod
FirebaseStorage storageInstance(Ref ref) => FirebaseStorage.instance;

/// Provides the single source of truth for the FirebaseAuth instance.
/// Enables easy mocking in tests by overriding this provider.
@riverpod
FirebaseAuth authInstance(Ref ref) => FirebaseAuth.instance;
