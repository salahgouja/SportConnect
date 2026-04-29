// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Auth state changes provider (Firebase User)

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Auth state changes provider (Firebase User)

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// Auth state changes provider (Firebase User)
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'169a42479efd2b01fd3524bbea2d445a2dde7019';

/// Current user data provider (Firestore User Model)
///
/// Uses [authRepositoryProvider] (via DI) so that only one [AuthRepository]
/// instance is shared and its Firestore listener is properly cancelled when
/// the provider is disposed. Creating a bare [AuthRepository()] here on every
/// rebuild would accumulate orphaned snapshot listeners.

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

/// Current user data provider (Firestore User Model)
///
/// Uses [authRepositoryProvider] (via DI) so that only one [AuthRepository]
/// instance is shared and its Firestore listener is properly cancelled when
/// the provider is disposed. Creating a bare [AuthRepository()] here on every
/// rebuild would accumulate orphaned snapshot listeners.

final class CurrentUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserModel?>,
          UserModel?,
          Stream<UserModel?>
        >
    with $FutureModifier<UserModel?>, $StreamProvider<UserModel?> {
  /// Current user data provider (Firestore User Model)
  ///
  /// Uses [authRepositoryProvider] (via DI) so that only one [AuthRepository]
  /// instance is shared and its Firestore listener is properly cancelled when
  /// the provider is disposed. Creating a bare [AuthRepository()] here on every
  /// rebuild would accumulate orphaned snapshot listeners.
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $StreamProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UserModel?> create(Ref ref) {
    return currentUser(ref);
  }
}

String _$currentUserHash() => r'c506edc63c12df0dd555224781026d46219f2817';

@ProviderFor(premiumMetadata)
final premiumMetadataProvider = PremiumMetadataProvider._();

final class PremiumMetadataProvider
    extends
        $FunctionalProvider<
          AsyncValue<PremiumMetadata>,
          PremiumMetadata,
          Stream<PremiumMetadata>
        >
    with $FutureModifier<PremiumMetadata>, $StreamProvider<PremiumMetadata> {
  PremiumMetadataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'premiumMetadataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$premiumMetadataHash();

  @$internal
  @override
  $StreamProviderElement<PremiumMetadata> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PremiumMetadata> create(Ref ref) {
    return premiumMetadata(ref);
  }
}

String _$premiumMetadataHash() => r'cc1aab8848022e5923c8a5521516122ed356f81a';

/// Pending user's selected role intent during onboarding setup.
///
/// This is stored on the user document as `selectedRoleIntent` so refresh/restart
/// can resume onboarding on the correct screen before role finalization.

@ProviderFor(selectedRoleIntent)
final selectedRoleIntentProvider = SelectedRoleIntentProvider._();

/// Pending user's selected role intent during onboarding setup.
///
/// This is stored on the user document as `selectedRoleIntent` so refresh/restart
/// can resume onboarding on the correct screen before role finalization.

final class SelectedRoleIntentProvider
    extends
        $FunctionalProvider<AsyncValue<UserRole?>, UserRole?, Stream<UserRole?>>
    with $FutureModifier<UserRole?>, $StreamProvider<UserRole?> {
  /// Pending user's selected role intent during onboarding setup.
  ///
  /// This is stored on the user document as `selectedRoleIntent` so refresh/restart
  /// can resume onboarding on the correct screen before role finalization.
  SelectedRoleIntentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedRoleIntentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedRoleIntentHash();

  @$internal
  @override
  $StreamProviderElement<UserRole?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UserRole?> create(Ref ref) {
    return selectedRoleIntent(ref);
  }
}

String _$selectedRoleIntentHash() =>
    r'099fc48bc57c3f498f56ed840eef1bb583aa9b99';
