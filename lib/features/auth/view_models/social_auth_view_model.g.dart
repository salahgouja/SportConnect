// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SocialAuthViewModel)
final socialAuthViewModelProvider = SocialAuthViewModelProvider._();

final class SocialAuthViewModelProvider
    extends $NotifierProvider<SocialAuthViewModel, SocialAuthState> {
  SocialAuthViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialAuthViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialAuthViewModelHash();

  @$internal
  @override
  SocialAuthViewModel create() => SocialAuthViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialAuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialAuthState>(value),
    );
  }
}

String _$socialAuthViewModelHash() =>
    r'080b8aaa13e10eaeb7be5745ce4898708d4ab982';

abstract class _$SocialAuthViewModel extends $Notifier<SocialAuthState> {
  SocialAuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SocialAuthState, SocialAuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SocialAuthState, SocialAuthState>,
              SocialAuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
