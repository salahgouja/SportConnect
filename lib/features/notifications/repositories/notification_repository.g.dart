// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for streaming user notifications

@ProviderFor(userNotificationsStream)
final userNotificationsStreamProvider = UserNotificationsStreamFamily._();

/// Provider for streaming user notifications

final class UserNotificationsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NotificationModel>>,
          List<NotificationModel>,
          Stream<List<NotificationModel>>
        >
    with
        $FutureModifier<List<NotificationModel>>,
        $StreamProvider<List<NotificationModel>> {
  /// Provider for streaming user notifications
  UserNotificationsStreamProvider._({
    required UserNotificationsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userNotificationsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userNotificationsStreamHash();

  @override
  String toString() {
    return r'userNotificationsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<NotificationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<NotificationModel>> create(Ref ref) {
    final argument = this.argument as String;
    return userNotificationsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserNotificationsStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userNotificationsStreamHash() =>
    r'aa1385dec63a56e1c01aba2daa0796be6271e73d';

/// Provider for streaming user notifications

final class UserNotificationsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<NotificationModel>>, String> {
  UserNotificationsStreamFamily._()
    : super(
        retry: null,
        name: r'userNotificationsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for streaming user notifications

  UserNotificationsStreamProvider call(String userId) =>
      UserNotificationsStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'userNotificationsStreamProvider';
}

/// Provider for streaming unread count

@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = UnreadNotificationCountFamily._();

/// Provider for streaming unread count

final class UnreadNotificationCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Provider for streaming unread count
  UnreadNotificationCountProvider._({
    required UnreadNotificationCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'unreadNotificationCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unreadNotificationCountHash();

  @override
  String toString() {
    return r'unreadNotificationCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as String;
    return unreadNotificationCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadNotificationCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unreadNotificationCountHash() =>
    r'a4a1fcdfdd21d1756e74bd5a4476264d5f8d8bc4';

/// Provider for streaming unread count

final class UnreadNotificationCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  UnreadNotificationCountFamily._()
    : super(
        retry: null,
        name: r'unreadNotificationCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for streaming unread count

  UnreadNotificationCountProvider call(String userId) =>
      UnreadNotificationCountProvider._(argument: userId, from: this);

  @override
  String toString() => r'unreadNotificationCountProvider';
}
