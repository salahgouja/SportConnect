// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the single source of truth for the Firestore instance.
///
/// Kept alive for the entire app lifetime — Firestore is a singleton and
/// every repository provider depends on it; auto-disposing would force all
/// dependent keepAlive providers to also dispose unnecessarily.

@ProviderFor(firestoreInstance)
final firestoreInstanceProvider = FirestoreInstanceProvider._();

/// Provides the single source of truth for the Firestore instance.
///
/// Kept alive for the entire app lifetime — Firestore is a singleton and
/// every repository provider depends on it; auto-disposing would force all
/// dependent keepAlive providers to also dispose unnecessarily.

final class FirestoreInstanceProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  /// Provides the single source of truth for the Firestore instance.
  ///
  /// Kept alive for the entire app lifetime — Firestore is a singleton and
  /// every repository provider depends on it; auto-disposing would force all
  /// dependent keepAlive providers to also dispose unnecessarily.
  FirestoreInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreInstanceProvider',
        isAutoDispose: false,
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

String _$firestoreInstanceHash() => r'db8a0da0c46218cf47e3245f277e13416149f9d7';

/// Provides the single source of truth for the Firebase Storage instance.
///
/// Kept alive for the entire app lifetime alongside [firestoreInstance].

@ProviderFor(storageInstance)
final storageInstanceProvider = StorageInstanceProvider._();

/// Provides the single source of truth for the Firebase Storage instance.
///
/// Kept alive for the entire app lifetime alongside [firestoreInstance].

final class StorageInstanceProvider
    extends
        $FunctionalProvider<FirebaseStorage, FirebaseStorage, FirebaseStorage>
    with $Provider<FirebaseStorage> {
  /// Provides the single source of truth for the Firebase Storage instance.
  ///
  /// Kept alive for the entire app lifetime alongside [firestoreInstance].
  StorageInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageInstanceProvider',
        isAutoDispose: false,
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

String _$storageInstanceHash() => r'aa3d0924c806a995c233fc6ebb8b9503b77a1416';

/// Provides the single source of truth for the FirebaseAuth instance.
///
/// Kept alive for the entire app lifetime alongside [firestoreInstance].

@ProviderFor(authInstance)
final authInstanceProvider = AuthInstanceProvider._();

/// Provides the single source of truth for the FirebaseAuth instance.
///
/// Kept alive for the entire app lifetime alongside [firestoreInstance].

final class AuthInstanceProvider
    extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  /// Provides the single source of truth for the FirebaseAuth instance.
  ///
  /// Kept alive for the entire app lifetime alongside [firestoreInstance].
  AuthInstanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authInstanceProvider',
        isAutoDispose: false,
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

String _$authInstanceHash() => r'5fdf186f4bee506aa38512ea941b7e54392a9e0e';
