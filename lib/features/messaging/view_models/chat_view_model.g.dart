// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User Chats Stream Provider

@ProviderFor(userChats)
final userChatsProvider = UserChatsFamily._();

/// User Chats Stream Provider

final class UserChatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChatModel>>,
          List<ChatModel>,
          Stream<List<ChatModel>>
        >
    with $FutureModifier<List<ChatModel>>, $StreamProvider<List<ChatModel>> {
  /// User Chats Stream Provider
  UserChatsProvider._({
    required UserChatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userChatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userChatsHash();

  @override
  String toString() {
    return r'userChatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ChatModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ChatModel>> create(Ref ref) {
    final argument = this.argument as String;
    return userChats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserChatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userChatsHash() => r'f8cd7fee8280fc23f8f921e5810dc51c631bc22b';

/// User Chats Stream Provider

final class UserChatsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ChatModel>>, String> {
  UserChatsFamily._()
    : super(
        retry: null,
        name: r'userChatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// User Chats Stream Provider

  UserChatsProvider call(String userId) =>
      UserChatsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userChatsProvider';
}

/// Chat Detail View Model

@ProviderFor(ChatDetailViewModel)
final chatDetailViewModelProvider = ChatDetailViewModelFamily._();

/// Chat Detail View Model
final class ChatDetailViewModelProvider
    extends $NotifierProvider<ChatDetailViewModel, ChatDetailState> {
  /// Chat Detail View Model
  ChatDetailViewModelProvider._({
    required ChatDetailViewModelFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'chatDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatDetailViewModelHash();

  @override
  String toString() {
    return r'chatDetailViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatDetailViewModel create() => ChatDetailViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatDetailViewModelHash() =>
    r'0f3d82624b4ef4dfbd0e5cafbf7ee3604a8f7723';

/// Chat Detail View Model

final class ChatDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatDetailViewModel,
          ChatDetailState,
          ChatDetailState,
          ChatDetailState,
          (String, String)
        > {
  ChatDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'chatDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Chat Detail View Model

  ChatDetailViewModelProvider call(String chatId, String currentUserId) =>
      ChatDetailViewModelProvider._(
        argument: (chatId, currentUserId),
        from: this,
      );

  @override
  String toString() => r'chatDetailViewModelProvider';
}

/// Chat Detail View Model

abstract class _$ChatDetailViewModel extends $Notifier<ChatDetailState> {
  late final _$args = ref.$arg as (String, String);
  String get chatId => _$args.$1;
  String get currentUserId => _$args.$2;

  ChatDetailState build(String chatId, String currentUserId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatDetailState, ChatDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatDetailState, ChatDetailState>,
              ChatDetailState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

/// Create or get private chat

@ProviderFor(getOrCreateChat)
final getOrCreateChatProvider = GetOrCreateChatFamily._();

/// Create or get private chat

final class GetOrCreateChatProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChatModel>,
          ChatModel,
          FutureOr<ChatModel>
        >
    with $FutureModifier<ChatModel>, $FutureProvider<ChatModel> {
  /// Create or get private chat
  GetOrCreateChatProvider._({
    required GetOrCreateChatFamily super.from,
    required ({
      String userId1,
      String userId2,
      String userName1,
      String userName2,
      String? userPhoto1,
      String? userPhoto2,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'getOrCreateChatProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getOrCreateChatHash();

  @override
  String toString() {
    return r'getOrCreateChatProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ChatModel> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ChatModel> create(Ref ref) {
    final argument =
        this.argument
            as ({
              String userId1,
              String userId2,
              String userName1,
              String userName2,
              String? userPhoto1,
              String? userPhoto2,
            });
    return getOrCreateChat(
      ref,
      userId1: argument.userId1,
      userId2: argument.userId2,
      userName1: argument.userName1,
      userName2: argument.userName2,
      userPhoto1: argument.userPhoto1,
      userPhoto2: argument.userPhoto2,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetOrCreateChatProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getOrCreateChatHash() => r'83317096344dcdda0fd96d1a677fbbd6161642c0';

/// Create or get private chat

final class GetOrCreateChatFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ChatModel>,
          ({
            String userId1,
            String userId2,
            String userName1,
            String userName2,
            String? userPhoto1,
            String? userPhoto2,
          })
        > {
  GetOrCreateChatFamily._()
    : super(
        retry: null,
        name: r'getOrCreateChatProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Create or get private chat

  GetOrCreateChatProvider call({
    required String userId1,
    required String userId2,
    required String userName1,
    required String userName2,
    String? userPhoto1,
    String? userPhoto2,
  }) => GetOrCreateChatProvider._(
    argument: (
      userId1: userId1,
      userId2: userId2,
      userName1: userName1,
      userName2: userName2,
      userPhoto1: userPhoto1,
      userPhoto2: userPhoto2,
    ),
    from: this,
  );

  @override
  String toString() => r'getOrCreateChatProvider';
}
