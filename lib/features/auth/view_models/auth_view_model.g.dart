// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

String _$loginViewModelHash() => r'e004d1a70a69dcf46ac1e7f50aa9864926e67e25';

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

String _$registerViewModelHash() => r'f2b68665f05b03b5ba2ab0989ddb0bfbca567ec2';

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
        isAutoDispose: false,
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
    r'0fec17f7c30c895f7fffe72139d248e9aa1f2ee3';
