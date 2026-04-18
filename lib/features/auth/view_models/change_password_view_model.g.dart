// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChangePasswordViewModel)
final changePasswordViewModelProvider = ChangePasswordViewModelProvider._();

final class ChangePasswordViewModelProvider
    extends $NotifierProvider<ChangePasswordViewModel, ChangePasswordState> {
  ChangePasswordViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordViewModelHash();

  @$internal
  @override
  ChangePasswordViewModel create() => ChangePasswordViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangePasswordState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangePasswordState>(value),
    );
  }
}

String _$changePasswordViewModelHash() =>
    r'4c8df9ca6b06b0e08d87b6b1a2e5cd483f1c2c99';

abstract class _$ChangePasswordViewModel
    extends $Notifier<ChangePasswordState> {
  ChangePasswordState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChangePasswordState, ChangePasswordState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChangePasswordState, ChangePasswordState>,
              ChangePasswordState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
