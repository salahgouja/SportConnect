// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Auth repository provider.
///
/// Returns the interface type so consumers depend on the abstraction,
/// making it easy to swap implementations or provide mocks in tests.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Auth repository provider.
///
/// Returns the interface type so consumers depend on the abstraction,
/// making it easy to swap implementations or provide mocks in tests.

final class AuthRepositoryProvider
    extends
        $FunctionalProvider<IAuthRepository, IAuthRepository, IAuthRepository>
    with $Provider<IAuthRepository> {
  /// Auth repository provider.
  ///
  /// Returns the interface type so consumers depend on the abstraction,
  /// making it easy to swap implementations or provide mocks in tests.
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

String _$authRepositoryHash() => r'd46f69c6c8b1b1a866beb6286d356d5305473d89';

/// Login view model

@ProviderFor(LoginViewModel)
final loginViewModelProvider = LoginViewModelProvider._();

/// Login view model
final class LoginViewModelProvider
    extends $NotifierProvider<LoginViewModel, AsyncValue<void>> {
  /// Login view model
  LoginViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginViewModelHash();

  @$internal
  @override
  LoginViewModel create() => LoginViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$loginViewModelHash() => r'9a748c1ab98fcea2657d996aa96e539f5dd2b79e';

/// Login view model

abstract class _$LoginViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Register view model

@ProviderFor(RegisterViewModel)
final registerViewModelProvider = RegisterViewModelProvider._();

/// Register view model
final class RegisterViewModelProvider
    extends $NotifierProvider<RegisterViewModel, AsyncValue<void>> {
  /// Register view model
  RegisterViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerViewModelHash();

  @$internal
  @override
  RegisterViewModel create() => RegisterViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$registerViewModelHash() => r'63d80e7718f8f43a58482fa93087293783fb40c4';

/// Register view model

abstract class _$RegisterViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provides shared auth actions (sign-out, social sign-in, role management).
///
/// Declaring this as a [Provider] at global scope is intentional: the class
/// is a thin pass-through over [authRepositoryProvider] and carries no local
/// state, so it does not need to be auto-disposed per-widget.

@ProviderFor(authActionsViewModel)
final authActionsViewModelProvider = AuthActionsViewModelProvider._();

/// Provides shared auth actions (sign-out, social sign-in, role management).
///
/// Declaring this as a [Provider] at global scope is intentional: the class
/// is a thin pass-through over [authRepositoryProvider] and carries no local
/// state, so it does not need to be auto-disposed per-widget.

final class AuthActionsViewModelProvider
    extends
        $FunctionalProvider<
          AuthActionsViewModel,
          AuthActionsViewModel,
          AuthActionsViewModel
        >
    with $Provider<AuthActionsViewModel> {
  /// Provides shared auth actions (sign-out, social sign-in, role management).
  ///
  /// Declaring this as a [Provider] at global scope is intentional: the class
  /// is a thin pass-through over [authRepositoryProvider] and carries no local
  /// state, so it does not need to be auto-disposed per-widget.
  AuthActionsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authActionsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authActionsViewModelHash();

  @$internal
  @override
  $ProviderElement<AuthActionsViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthActionsViewModel create(Ref ref) {
    return authActionsViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthActionsViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthActionsViewModel>(value),
    );
  }
}

String _$authActionsViewModelHash() =>
    r'20b4c9a8cf70f3fe672de665a948b3d0a5bd7017';
