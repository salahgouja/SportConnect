// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the single source of truth for the Firestore instance.
/// Enables easy mocking in tests by overriding this provider.

@ProviderFor(firestoreInstance)
final firestoreInstanceProvider = FirestoreInstanceProvider._();

/// Provides the single source of truth for the Firestore instance.
/// Enables easy mocking in tests by overriding this provider.

final class FirestoreInstanceProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  /// Provides the single source of truth for the Firestore instance.
  /// Enables easy mocking in tests by overriding this provider.
  FirestoreInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreInstanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreInstanceHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firestoreInstance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firestoreInstanceHash() => r'8f725e5183ee91c5ee36ce18ed53be1d7252c608';

/// Provides the single source of truth for the Firebase Storage instance.
/// Enables easy mocking in tests by overriding this provider.

@ProviderFor(storageInstance)
final storageInstanceProvider = StorageInstanceProvider._();

/// Provides the single source of truth for the Firebase Storage instance.
/// Enables easy mocking in tests by overriding this provider.

final class StorageInstanceProvider
    extends
        $FunctionalProvider<FirebaseStorage, FirebaseStorage, FirebaseStorage>
    with $Provider<FirebaseStorage> {
  /// Provides the single source of truth for the Firebase Storage instance.
  /// Enables easy mocking in tests by overriding this provider.
  StorageInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageInstanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageInstanceHash();

  @$internal
  @override
  $ProviderElement<FirebaseStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseStorage create(Ref ref) {
    return storageInstance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseStorage>(value),
    );
  }
}

String _$storageInstanceHash() => r'7d251ba752a3143eca777e6e8e5ee88ec7cea868';

/// Provides the single source of truth for the FirebaseAuth instance.
/// Enables easy mocking in tests by overriding this provider.

@ProviderFor(authInstance)
final authInstanceProvider = AuthInstanceProvider._();

/// Provides the single source of truth for the FirebaseAuth instance.
/// Enables easy mocking in tests by overriding this provider.

final class AuthInstanceProvider
    extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  /// Provides the single source of truth for the FirebaseAuth instance.
  /// Enables easy mocking in tests by overriding this provider.
  AuthInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authInstanceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authInstanceHash();

  @$internal
  @override
  $ProviderElement<FirebaseAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseAuth create(Ref ref) {
    return authInstance(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAuth>(value),
    );
  }
}

String _$authInstanceHash() => r'af1038d1e284332b5c6c20ddd8ccaed7305c7dcf';
