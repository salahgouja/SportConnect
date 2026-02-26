// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'ed8a9d9d4cb14ad223998b3ebf860ddc876eb490';

/// Stream provider for current user

@ProviderFor(currentUserStream)
final currentUserStreamProvider = CurrentUserStreamProvider._();

/// Stream provider for current user

final class CurrentUserStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserModel?>,
          UserModel?,
          Stream<UserModel?>
        >
    with $FutureModifier<UserModel?>, $StreamProvider<UserModel?> {
  /// Stream provider for current user
  CurrentUserStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserStreamHash();

  @$internal
  @override
  $StreamProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UserModel?> create(Ref ref) {
    return currentUserStream(ref);
  }
}

String _$currentUserStreamHash() => r'1c75c9aaf796c347453dc56ef9b0ff17469624d4';

/// Stream provider for a user by ID

@ProviderFor(userStream)
final userStreamProvider = UserStreamFamily._();

/// Stream provider for a user by ID

final class UserStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserModel?>,
          UserModel?,
          Stream<UserModel?>
        >
    with $FutureModifier<UserModel?>, $StreamProvider<UserModel?> {
  /// Stream provider for a user by ID
  UserStreamProvider._({
    required UserStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userStreamHash();

  @override
  String toString() {
    return r'userStreamProvider'
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
    return userStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userStreamHash() => r'1029bdf87b6c778cace2e8a22f3dbf17f1b4f738';

/// Stream provider for a user by ID

final class UserStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UserModel?>, String> {
  UserStreamFamily._()
    : super(
        retry: null,
        name: r'userStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for a user by ID

  UserStreamProvider call(String userId) =>
      UserStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'userStreamProvider';
}

/// Provider to load VehicleModel objects for a driver

@ProviderFor(driverVehicles)
final driverVehiclesProvider = DriverVehiclesFamily._();

/// Provider to load VehicleModel objects for a driver

final class DriverVehiclesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VehicleModel>>,
          List<VehicleModel>,
          FutureOr<List<VehicleModel>>
        >
    with
        $FutureModifier<List<VehicleModel>>,
        $FutureProvider<List<VehicleModel>> {
  /// Provider to load VehicleModel objects for a driver
  DriverVehiclesProvider._({
    required DriverVehiclesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driverVehiclesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverVehiclesHash();

  @override
  String toString() {
    return r'driverVehiclesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<VehicleModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VehicleModel>> create(Ref ref) {
    final argument = this.argument as String;
    return driverVehicles(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverVehiclesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverVehiclesHash() => r'fc8fc17dd9127f0379ff035ca6b8ce35f1adcd79';

/// Provider to load VehicleModel objects for a driver

final class DriverVehiclesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<VehicleModel>>, String> {
  DriverVehiclesFamily._()
    : super(
        retry: null,
        name: r'driverVehiclesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to load VehicleModel objects for a driver

  DriverVehiclesProvider call(String uid) =>
      DriverVehiclesProvider._(argument: uid, from: this);

  @override
  String toString() => r'driverVehiclesProvider';
}
