// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_search_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserSearchUiViewModel)
final userSearchUiViewModelProvider = UserSearchUiViewModelProvider._();

final class UserSearchUiViewModelProvider
    extends $NotifierProvider<UserSearchUiViewModel, UserSearchUiState> {
  UserSearchUiViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSearchUiViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSearchUiViewModelHash();

  @$internal
  @override
  UserSearchUiViewModel create() => UserSearchUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserSearchUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserSearchUiState>(value),
    );
  }
}

String _$userSearchUiViewModelHash() =>
    r'c47114e1d31f6ad46805ec0f01dfaf6c5747ff1f';

abstract class _$UserSearchUiViewModel extends $Notifier<UserSearchUiState> {
  UserSearchUiState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserSearchUiState, UserSearchUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserSearchUiState, UserSearchUiState>,
              UserSearchUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
