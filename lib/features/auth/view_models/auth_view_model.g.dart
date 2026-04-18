// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoginUiViewModel)
final loginUiViewModelProvider = LoginUiViewModelProvider._();

final class LoginUiViewModelProvider
    extends $NotifierProvider<LoginUiViewModel, LoginUiState> {
  LoginUiViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginUiViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginUiViewModelHash();

  @$internal
  @override
  LoginUiViewModel create() => LoginUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginUiState>(value),
    );
  }
}

String _$loginUiViewModelHash() => r'89cad85fa9df2e67088bd14049ab2e41aa1602e1';

abstract class _$LoginUiViewModel extends $Notifier<LoginUiState> {
  LoginUiState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LoginUiState, LoginUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginUiState, LoginUiState>,
              LoginUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SignupWizardUiViewModel)
final signupWizardUiViewModelProvider = SignupWizardUiViewModelProvider._();

final class SignupWizardUiViewModelProvider
    extends $NotifierProvider<SignupWizardUiViewModel, SignupWizardUiState> {
  SignupWizardUiViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signupWizardUiViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signupWizardUiViewModelHash();

  @$internal
  @override
  SignupWizardUiViewModel create() => SignupWizardUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignupWizardUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignupWizardUiState>(value),
    );
  }
}

String _$signupWizardUiViewModelHash() =>
    r'9d3423d32cbad60d3b623110982b2d4e99f96cd5';

abstract class _$SignupWizardUiViewModel
    extends $Notifier<SignupWizardUiState> {
  SignupWizardUiState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SignupWizardUiState, SignupWizardUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SignupWizardUiState, SignupWizardUiState>,
              SignupWizardUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

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

String _$loginViewModelHash() => r'565febae949499834216691a217b441d9a2f92fd';

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

String _$registerViewModelHash() => r'10049fb4aeb3fa085e070b1b5ebef6c236e831a5';

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
