// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Current User Profile Stream

@ProviderFor(currentUserProfile)
final currentUserProfileProvider = CurrentUserProfileFamily._();

/// Current User Profile Stream

final class CurrentUserProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserModel?>,
          UserModel?,
          Stream<UserModel?>
        >
    with $FutureModifier<UserModel?>, $StreamProvider<UserModel?> {
  /// Current User Profile Stream
  CurrentUserProfileProvider._({
    required CurrentUserProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'currentUserProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentUserProfileHash();

  @override
  String toString() {
    return r'currentUserProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UserModel?> create(Ref ref) {
    final argument = this.argument as String;
    return currentUserProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentUserProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentUserProfileHash() =>
    r'bccf6356486ff978c84aa3dc66f5d3fda4cf05d0';

/// Current User Profile Stream

final class CurrentUserProfileFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UserModel?>, String> {
  CurrentUserProfileFamily._()
    : super(
        retry: null,
        name: r'currentUserProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Current User Profile Stream

  CurrentUserProfileProvider call(String uid) =>
      CurrentUserProfileProvider._(argument: uid, from: this);

  @override
  String toString() => r'currentUserProfileProvider';
}

/// Other User Profile

@ProviderFor(userProfile)
final userProfileProvider = UserProfileFamily._();

/// Other User Profile

final class UserProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserModel?>,
          UserModel?,
          FutureOr<UserModel?>
        >
    with $FutureModifier<UserModel?>, $FutureProvider<UserModel?> {
  /// Other User Profile
  UserProfileProvider._({
    required UserProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @override
  String toString() {
    return r'userProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserModel?> create(Ref ref) {
    final argument = this.argument as String;
    return userProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileHash() => r'39b3de49df4c6bf90a373329a9fbc6021bf565f3';

/// Other User Profile

final class UserProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserModel?>, String> {
  UserProfileFamily._()
    : super(
        retry: null,
        name: r'userProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Other User Profile

  UserProfileProvider call(String uid) =>
      UserProfileProvider._(argument: uid, from: this);

  @override
  String toString() => r'userProfileProvider';
}

/// Profile Edit View Model

@ProviderFor(ProfileEditViewModel)
final profileEditViewModelProvider = ProfileEditViewModelFamily._();

/// Profile Edit View Model
final class ProfileEditViewModelProvider
    extends $NotifierProvider<ProfileEditViewModel, ProfileEditState> {
  /// Profile Edit View Model
  ProfileEditViewModelProvider._({
    required ProfileEditViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileEditViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileEditViewModelHash();

  @override
  String toString() {
    return r'profileEditViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileEditViewModel create() => ProfileEditViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileEditState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileEditState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileEditViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileEditViewModelHash() =>
    r'38af247999e29f743770358e3ee2a75d1d07e44c';

/// Profile Edit View Model

final class ProfileEditViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileEditViewModel,
          ProfileEditState,
          ProfileEditState,
          ProfileEditState,
          String
        > {
  ProfileEditViewModelFamily._()
    : super(
        retry: null,
        name: r'profileEditViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Profile Edit View Model

  ProfileEditViewModelProvider call(String uid) =>
      ProfileEditViewModelProvider._(argument: uid, from: this);

  @override
  String toString() => r'profileEditViewModelProvider';
}

/// Profile Edit View Model

abstract class _$ProfileEditViewModel extends $Notifier<ProfileEditState> {
  late final _$args = ref.$arg as String;
  String get uid => _$args;

  ProfileEditState build(String uid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProfileEditState, ProfileEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProfileEditState, ProfileEditState>,
              ProfileEditState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Social Actions View Model

@ProviderFor(SocialActionsViewModel)
final socialActionsViewModelProvider = SocialActionsViewModelFamily._();

/// Social Actions View Model
final class SocialActionsViewModelProvider
    extends $NotifierProvider<SocialActionsViewModel, SocialState> {
  /// Social Actions View Model
  SocialActionsViewModelProvider._({
    required SocialActionsViewModelFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'socialActionsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$socialActionsViewModelHash();

  @override
  String toString() {
    return r'socialActionsViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SocialActionsViewModel create() => SocialActionsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SocialActionsViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$socialActionsViewModelHash() =>
    r'2c3d8a8e6b467e4045d892947b8849c174d01f60';

/// Social Actions View Model

final class SocialActionsViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          SocialActionsViewModel,
          SocialState,
          SocialState,
          SocialState,
          (String, String)
        > {
  SocialActionsViewModelFamily._()
    : super(
        retry: null,
        name: r'socialActionsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Social Actions View Model

  SocialActionsViewModelProvider call(
    String currentUserId,
    String targetUserId,
  ) => SocialActionsViewModelProvider._(
    argument: (currentUserId, targetUserId),
    from: this,
  );

  @override
  String toString() => r'socialActionsViewModelProvider';
}

/// Social Actions View Model

abstract class _$SocialActionsViewModel extends $Notifier<SocialState> {
  late final _$args = ref.$arg as (String, String);
  String get currentUserId => _$args.$1;
  String get targetUserId => _$args.$2;

  SocialState build(String currentUserId, String targetUserId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SocialState, SocialState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SocialState, SocialState>,
              SocialState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

/// Vehicle Management View Model

@ProviderFor(VehicleViewModel)
final vehicleViewModelProvider = VehicleViewModelFamily._();

/// Vehicle Management View Model
final class VehicleViewModelProvider
    extends $NotifierProvider<VehicleViewModel, VehicleState> {
  /// Vehicle Management View Model
  VehicleViewModelProvider._({
    required VehicleViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vehicleViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vehicleViewModelHash();

  @override
  String toString() {
    return r'vehicleViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VehicleViewModel create() => VehicleViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vehicleViewModelHash() => r'fd8cfaec54af6fd26f104ab4af435e656acf44d2';

/// Vehicle Management View Model

final class VehicleViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          VehicleViewModel,
          VehicleState,
          VehicleState,
          VehicleState,
          String
        > {
  VehicleViewModelFamily._()
    : super(
        retry: null,
        name: r'vehicleViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Vehicle Management View Model

  VehicleViewModelProvider call(String uid) =>
      VehicleViewModelProvider._(argument: uid, from: this);

  @override
  String toString() => r'vehicleViewModelProvider';
}

/// Vehicle Management View Model

abstract class _$VehicleViewModel extends $Notifier<VehicleState> {
  late final _$args = ref.$arg as String;
  String get uid => _$args;

  VehicleState build(String uid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VehicleState, VehicleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VehicleState, VehicleState>,
              VehicleState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Leaderboard Provider

@ProviderFor(leaderboard)
final leaderboardProvider = LeaderboardProvider._();

/// Leaderboard Provider

final class LeaderboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LeaderboardEntry>>,
          List<LeaderboardEntry>,
          FutureOr<List<LeaderboardEntry>>
        >
    with
        $FutureModifier<List<LeaderboardEntry>>,
        $FutureProvider<List<LeaderboardEntry>> {
  /// Leaderboard Provider
  LeaderboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaderboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaderboardHash();

  @$internal
  @override
  $FutureProviderElement<List<LeaderboardEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LeaderboardEntry>> create(Ref ref) {
    return leaderboard(ref);
  }
}

String _$leaderboardHash() => r'20a3641301c872f11ae64811ab68b6c347b4faa6';

/// User Rank Provider

@ProviderFor(userRank)
final userRankProvider = UserRankFamily._();

/// User Rank Provider

final class UserRankProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// User Rank Provider
  UserRankProvider._({
    required UserRankFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userRankProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userRankHash();

  @override
  String toString() {
    return r'userRankProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return userRank(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserRankProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userRankHash() => r'f6d1de4ddd179c0ddb5fcd7e9880c6e070a6313c';

/// User Rank Provider

final class UserRankFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  UserRankFamily._()
    : super(
        retry: null,
        name: r'userRankProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// User Rank Provider

  UserRankProvider call(String uid) =>
      UserRankProvider._(argument: uid, from: this);

  @override
  String toString() => r'userRankProvider';
}

/// Followers List Provider

@ProviderFor(followers)
final followersProvider = FollowersFamily._();

/// Followers List Provider

final class FollowersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserModel>>,
          List<UserModel>,
          FutureOr<List<UserModel>>
        >
    with $FutureModifier<List<UserModel>>, $FutureProvider<List<UserModel>> {
  /// Followers List Provider
  FollowersProvider._({
    required FollowersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followersHash();

  @override
  String toString() {
    return r'followersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<UserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserModel>> create(Ref ref) {
    final argument = this.argument as String;
    return followers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followersHash() => r'7382cb07927dd757125ddd19b200c5fdd0e6041d';

/// Followers List Provider

final class FollowersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UserModel>>, String> {
  FollowersFamily._()
    : super(
        retry: null,
        name: r'followersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Followers List Provider

  FollowersProvider call(String uid) =>
      FollowersProvider._(argument: uid, from: this);

  @override
  String toString() => r'followersProvider';
}

/// Following List Provider

@ProviderFor(following)
final followingProvider = FollowingFamily._();

/// Following List Provider

final class FollowingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserModel>>,
          List<UserModel>,
          FutureOr<List<UserModel>>
        >
    with $FutureModifier<List<UserModel>>, $FutureProvider<List<UserModel>> {
  /// Following List Provider
  FollowingProvider._({
    required FollowingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followingHash();

  @override
  String toString() {
    return r'followingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<UserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserModel>> create(Ref ref) {
    final argument = this.argument as String;
    return following(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followingHash() => r'9bab80f445a0b07abb7d6f87185d4a9ff7938bc4';

/// Following List Provider

final class FollowingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UserModel>>, String> {
  FollowingFamily._()
    : super(
        retry: null,
        name: r'followingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Following List Provider

  FollowingProvider call(String uid) =>
      FollowingProvider._(argument: uid, from: this);

  @override
  String toString() => r'followingProvider';
}
