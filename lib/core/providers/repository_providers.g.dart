// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Firestore instance provider
///
/// Provides the single source of truth for Firestore instance.
/// This enables easy mocking in tests and switching implementations.

@ProviderFor(firestoreInstance)
final firestoreInstanceProvider = FirestoreInstanceProvider._();

/// Firestore instance provider
///
/// Provides the single source of truth for Firestore instance.
/// This enables easy mocking in tests and switching implementations.

final class FirestoreInstanceProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  /// Firestore instance provider
  ///
  /// Provides the single source of truth for Firestore instance.
  /// This enables easy mocking in tests and switching implementations.
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

String _$firestoreInstanceHash() => r'0f2e17bd314d9ddd815f276c6b7b295c892bca8a';

/// Storage instance provider
///
/// Provides the single source of truth for Firebase Storage instance.

@ProviderFor(storageInstance)
final storageInstanceProvider = StorageInstanceProvider._();

/// Storage instance provider
///
/// Provides the single source of truth for Firebase Storage instance.

final class StorageInstanceProvider
    extends
        $FunctionalProvider<FirebaseStorage, FirebaseStorage, FirebaseStorage>
    with $Provider<FirebaseStorage> {
  /// Storage instance provider
  ///
  /// Provides the single source of truth for Firebase Storage instance.
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

String _$storageInstanceHash() => r'a3f65dcd998c34f5f0b3b3068eba7ce2aa4c7555';

/// Auth instance provider
///
/// Provides the single source of truth for Firebase Auth instance.

@ProviderFor(authInstance)
final authInstanceProvider = AuthInstanceProvider._();

/// Auth instance provider
///
/// Provides the single source of truth for Firebase Auth instance.

final class AuthInstanceProvider
    extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  /// Auth instance provider
  ///
  /// Provides the single source of truth for Firebase Auth instance.
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

String _$authInstanceHash() => r'09c828f78a501498e71df97e7ac68fb749bffb5f';

/// Auth repository provider (interface-based)
///
/// Returns IAuthRepository interface for dependency inversion.
/// This allows for easy mocking in tests and swapping implementations.
///
/// Usage in tests:
/// ```dart
/// final container = ProviderContainer(
///   overrides: [
///     authRepositoryProvider.overrideWithValue(MockAuthRepository()),
///   ],
/// );
/// ```

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Auth repository provider (interface-based)
///
/// Returns IAuthRepository interface for dependency inversion.
/// This allows for easy mocking in tests and swapping implementations.
///
/// Usage in tests:
/// ```dart
/// final container = ProviderContainer(
///   overrides: [
///     authRepositoryProvider.overrideWithValue(MockAuthRepository()),
///   ],
/// );
/// ```

final class AuthRepositoryProvider
    extends
        $FunctionalProvider<IAuthRepository, IAuthRepository, IAuthRepository>
    with $Provider<IAuthRepository> {
  /// Auth repository provider (interface-based)
  ///
  /// Returns IAuthRepository interface for dependency inversion.
  /// This allows for easy mocking in tests and swapping implementations.
  ///
  /// Usage in tests:
  /// ```dart
  /// final container = ProviderContainer(
  ///   overrides: [
  ///     authRepositoryProvider.overrideWithValue(MockAuthRepository()),
  ///   ],
  /// );
  /// ```
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<IAuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IAuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IAuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'124e3e585454aec1a08bf857e5666522048a3829';

/// User repository provider (interface-based)
///
/// Returns IUserRepository interface for user data operations.
/// Injects dependencies from other providers for proper DIP compliance.

@ProviderFor(userRepository)
final userRepositoryProvider = UserRepositoryProvider._();

/// User repository provider (interface-based)
///
/// Returns IUserRepository interface for user data operations.
/// Injects dependencies from other providers for proper DIP compliance.

final class UserRepositoryProvider
    extends
        $FunctionalProvider<IUserRepository, IUserRepository, IUserRepository>
    with $Provider<IUserRepository> {
  /// User repository provider (interface-based)
  ///
  /// Returns IUserRepository interface for user data operations.
  /// Injects dependencies from other providers for proper DIP compliance.
  UserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRepositoryHash();

  @$internal
  @override
  $ProviderElement<IUserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IUserRepository create(Ref ref) {
    return userRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IUserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IUserRepository>(value),
    );
  }
}

String _$userRepositoryHash() => r'9ac488c5bff8a8742234c080d4afcf02b0f7958c';

/// Ride repository provider (interface-based)
///
/// Returns IRideRepository interface for ride operations.
/// Injects Firestore dependency from provider.

@ProviderFor(rideRepository)
final rideRepositoryProvider = RideRepositoryProvider._();

/// Ride repository provider (interface-based)
///
/// Returns IRideRepository interface for ride operations.
/// Injects Firestore dependency from provider.

final class RideRepositoryProvider
    extends
        $FunctionalProvider<IRideRepository, IRideRepository, IRideRepository>
    with $Provider<IRideRepository> {
  /// Ride repository provider (interface-based)
  ///
  /// Returns IRideRepository interface for ride operations.
  /// Injects Firestore dependency from provider.
  RideRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideRepositoryHash();

  @$internal
  @override
  $ProviderElement<IRideRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IRideRepository create(Ref ref) {
    return rideRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IRideRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IRideRepository>(value),
    );
  }
}

String _$rideRepositoryHash() => r'5eb90b5aae768c1e11380f4d31f1ef852861b6eb';

/// Chat repository provider (interface-based)
///
/// Returns IChatRepository interface for chat/messaging operations.
/// Injects both Firestore and Storage dependencies from providers.

@ProviderFor(chatRepository)
final chatRepositoryProvider = ChatRepositoryProvider._();

/// Chat repository provider (interface-based)
///
/// Returns IChatRepository interface for chat/messaging operations.
/// Injects both Firestore and Storage dependencies from providers.

final class ChatRepositoryProvider
    extends
        $FunctionalProvider<IChatRepository, IChatRepository, IChatRepository>
    with $Provider<IChatRepository> {
  /// Chat repository provider (interface-based)
  ///
  /// Returns IChatRepository interface for chat/messaging operations.
  /// Injects both Firestore and Storage dependencies from providers.
  ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $ProviderElement<IChatRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IChatRepository create(Ref ref) {
    return chatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IChatRepository>(value),
    );
  }
}

String _$chatRepositoryHash() => r'cc36250530acb581ddf98a0d38ab058dbea4d9ce';

/// Review repository provider (interface-based)
///
/// Returns IReviewRepository interface for review operations.
/// Injects Firestore dependency from provider.

@ProviderFor(reviewRepository)
final reviewRepositoryProvider = ReviewRepositoryProvider._();

/// Review repository provider (interface-based)
///
/// Returns IReviewRepository interface for review operations.
/// Injects Firestore dependency from provider.

final class ReviewRepositoryProvider
    extends
        $FunctionalProvider<
          IReviewRepository,
          IReviewRepository,
          IReviewRepository
        >
    with $Provider<IReviewRepository> {
  /// Review repository provider (interface-based)
  ///
  /// Returns IReviewRepository interface for review operations.
  /// Injects Firestore dependency from provider.
  ReviewRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewRepositoryHash();

  @$internal
  @override
  $ProviderElement<IReviewRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IReviewRepository create(Ref ref) {
    return reviewRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IReviewRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IReviewRepository>(value),
    );
  }
}

String _$reviewRepositoryHash() => r'388239ad794f234ce79eb179d4b242638c265df0';
