import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

/// Provides the single source of truth for the Firestore instance.
///
/// Kept alive for the entire app lifetime — Firestore is a singleton and
/// every repository provider depends on it; auto-disposing would force all
/// dependent keepAlive providers to also dispose unnecessarily.
@Riverpod(keepAlive: true)
FirebaseFirestore firestoreInstance(Ref ref) => FirebaseFirestore.instance;

/// Provides the single source of truth for the Firebase Storage instance.
///
/// Kept alive for the entire app lifetime alongside [firestoreInstance].
@Riverpod(keepAlive: true)
FirebaseStorage storageInstance(Ref ref) => FirebaseStorage.instance;

/// Provides the single source of truth for the FirebaseAuth instance.
///
/// Kept alive for the entire app lifetime alongside [firestoreInstance].
@Riverpod(keepAlive: true)
FirebaseAuth authInstance(Ref ref) => FirebaseAuth.instance;
