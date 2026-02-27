// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Auth repository provider (interface-based).
///
/// Returns [IAuthRepository] for dependency inversion, enabling mocking in
/// tests. All Firebase instances are injected via [firebase_providers.dart].
///
/// ```dart
/// // Test override example:
/// final container = ProviderContainer(
///   overrides: [
///     authRepositoryProvider.overrideWithValue(MockAuthRepository()),
///   ],
/// );
/// ```

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Auth repository provider (interface-based).
///
/// Returns [IAuthRepository] for dependency inversion, enabling mocking in
/// tests. All Firebase instances are injected via [firebase_providers.dart].
///
/// ```dart
/// // Test override example:
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
  /// Auth repository provider (interface-based).
  ///
  /// Returns [IAuthRepository] for dependency inversion, enabling mocking in
  /// tests. All Firebase instances are injected via [firebase_providers.dart].
  ///
  /// ```dart
  /// // Test override example:
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

String _$authRepositoryHash() => r'c8c06d55ee9e50d4cd16b138ec21cbaaa8e97eb2';
