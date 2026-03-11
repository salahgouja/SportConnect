// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatListUiViewModel)
final chatListUiViewModelProvider = ChatListUiViewModelProvider._();

final class ChatListUiViewModelProvider
    extends $NotifierProvider<ChatListUiViewModel, ChatListUiState> {
  ChatListUiViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatListUiViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatListUiViewModelHash();

  @$internal
  @override
  ChatListUiViewModel create() => ChatListUiViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatListUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatListUiState>(value),
    );
  }
}

String _$chatListUiViewModelHash() =>
    r'd2e235248958b60843e945e79818d0b6f35ddff6';

abstract class _$ChatListUiViewModel extends $Notifier<ChatListUiState> {
  ChatListUiState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatListUiState, ChatListUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatListUiState, ChatListUiState>,
              ChatListUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(NewChatSearchViewModel)
final newChatSearchViewModelProvider = NewChatSearchViewModelProvider._();

final class NewChatSearchViewModelProvider
    extends $NotifierProvider<NewChatSearchViewModel, NewChatSearchState> {
  NewChatSearchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'newChatSearchViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$newChatSearchViewModelHash();

  @$internal
  @override
  NewChatSearchViewModel create() => NewChatSearchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NewChatSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NewChatSearchState>(value),
    );
  }
}

String _$newChatSearchViewModelHash() =>
    r'e9126dc74a4bc0cb5e3d1367a0c2d3ab3d9a3340';

abstract class _$NewChatSearchViewModel extends $Notifier<NewChatSearchState> {
  NewChatSearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NewChatSearchState, NewChatSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NewChatSearchState, NewChatSearchState>,
              NewChatSearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
