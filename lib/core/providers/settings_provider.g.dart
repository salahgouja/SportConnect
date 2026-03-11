// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for app theme mode (light, dark, system)

@ProviderFor(ThemeModeProvider)
final themeModeProviderProvider = ThemeModeProviderProvider._();

/// Provider for app theme mode (light, dark, system)
final class ThemeModeProviderProvider
    extends $AsyncNotifierProvider<ThemeModeProvider, ThemeMode> {
  /// Provider for app theme mode (light, dark, system)
  ThemeModeProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeProviderHash();

  @$internal
  @override
  ThemeModeProvider create() => ThemeModeProvider();
}

String _$themeModeProviderHash() => r'f6e0a6e14f7d3aeb608c51aef14607c53ec3d48c';

/// Provider for app theme mode (light, dark, system)

abstract class _$ThemeModeProvider extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
              AsyncValue<ThemeMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for map style preference

@ProviderFor(MapStyleProvider)
final mapStyleProviderProvider = MapStyleProviderProvider._();

/// Provider for map style preference
final class MapStyleProviderProvider
    extends $AsyncNotifierProvider<MapStyleProvider, String> {
  /// Provider for map style preference
  MapStyleProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapStyleProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapStyleProviderHash();

  @$internal
  @override
  MapStyleProvider create() => MapStyleProvider();
}

String _$mapStyleProviderHash() => r'ead5635ac5018d0d7060a602c8aa7ab73401acc4';

/// Provider for map style preference

abstract class _$MapStyleProvider extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for current app locale
///
/// Reads from SettingsRepository and provides reactive locale state.
/// Returns null if user hasn't set a preference (app will use system locale).

@ProviderFor(LocaleProvider)
final localeProviderProvider = LocaleProviderProvider._();

/// Provider for current app locale
///
/// Reads from SettingsRepository and provides reactive locale state.
/// Returns null if user hasn't set a preference (app will use system locale).
final class LocaleProviderProvider
    extends $AsyncNotifierProvider<LocaleProvider, Locale?> {
  /// Provider for current app locale
  ///
  /// Reads from SettingsRepository and provides reactive locale state.
  /// Returns null if user hasn't set a preference (app will use system locale).
  LocaleProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeProviderHash();

  @$internal
  @override
  LocaleProvider create() => LocaleProvider();
}

String _$localeProviderHash() => r'2c7b18254967a245c9d0583e15d80d7e59e61400';

/// Provider for current app locale
///
/// Reads from SettingsRepository and provides reactive locale state.
/// Returns null if user hasn't set a preference (app will use system locale).

abstract class _$LocaleProvider extends $AsyncNotifier<Locale?> {
  FutureOr<Locale?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Locale?>, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Locale?>, Locale?>,
              AsyncValue<Locale?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for push notifications setting

@ProviderFor(NotificationsEnabledProvider)
final notificationsEnabledProviderProvider =
    NotificationsEnabledProviderProvider._();

/// Provider for push notifications setting
final class NotificationsEnabledProviderProvider
    extends $AsyncNotifierProvider<NotificationsEnabledProvider, bool> {
  /// Provider for push notifications setting
  NotificationsEnabledProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsEnabledProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsEnabledProviderHash();

  @$internal
  @override
  NotificationsEnabledProvider create() => NotificationsEnabledProvider();
}

String _$notificationsEnabledProviderHash() =>
    r'fce9fd842ab7eec7ac5edd04b4e9b02267ac24a8';

/// Provider for push notifications setting

abstract class _$NotificationsEnabledProvider extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for ride reminders setting

@ProviderFor(RideRemindersProvider)
final rideRemindersProviderProvider = RideRemindersProviderProvider._();

/// Provider for ride reminders setting
final class RideRemindersProviderProvider
    extends $AsyncNotifierProvider<RideRemindersProvider, bool> {
  /// Provider for ride reminders setting
  RideRemindersProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideRemindersProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideRemindersProviderHash();

  @$internal
  @override
  RideRemindersProvider create() => RideRemindersProvider();
}

String _$rideRemindersProviderHash() =>
    r'106049e6daa4d920cc125a6f5a6b9ec8124aa6d3';

/// Provider for ride reminders setting

abstract class _$RideRemindersProvider extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for chat notifications setting

@ProviderFor(ChatNotificationsProvider)
final chatNotificationsProviderProvider = ChatNotificationsProviderProvider._();

/// Provider for chat notifications setting
final class ChatNotificationsProviderProvider
    extends $AsyncNotifierProvider<ChatNotificationsProvider, bool> {
  /// Provider for chat notifications setting
  ChatNotificationsProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatNotificationsProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatNotificationsProviderHash();

  @$internal
  @override
  ChatNotificationsProvider create() => ChatNotificationsProvider();
}

String _$chatNotificationsProviderHash() =>
    r'b0a6cfa2fa28a101f7265aed2bfaab05caf0d6ee';

/// Provider for chat notifications setting

abstract class _$ChatNotificationsProvider extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for marketing emails setting

@ProviderFor(MarketingEmailsProvider)
final marketingEmailsProviderProvider = MarketingEmailsProviderProvider._();

/// Provider for marketing emails setting
final class MarketingEmailsProviderProvider
    extends $AsyncNotifierProvider<MarketingEmailsProvider, bool> {
  /// Provider for marketing emails setting
  MarketingEmailsProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketingEmailsProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketingEmailsProviderHash();

  @$internal
  @override
  MarketingEmailsProvider create() => MarketingEmailsProvider();
}

String _$marketingEmailsProviderHash() =>
    r'baa2a74593c77b5c889d2fda2ece7193aea38683';

/// Provider for marketing emails setting

abstract class _$MarketingEmailsProvider extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for auto-accept rides setting

@ProviderFor(AutoAcceptRidesProvider)
final autoAcceptRidesProviderProvider = AutoAcceptRidesProviderProvider._();

/// Provider for auto-accept rides setting
final class AutoAcceptRidesProviderProvider
    extends $AsyncNotifierProvider<AutoAcceptRidesProvider, bool> {
  /// Provider for auto-accept rides setting
  AutoAcceptRidesProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoAcceptRidesProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoAcceptRidesProviderHash();

  @$internal
  @override
  AutoAcceptRidesProvider create() => AutoAcceptRidesProvider();
}

String _$autoAcceptRidesProviderHash() =>
    r'c96fa0a0a38be6fbaecdc112f70458935a70b793';

/// Provider for auto-accept rides setting

abstract class _$AutoAcceptRidesProvider extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for show location setting

@ProviderFor(ShowLocationProvider)
final showLocationProviderProvider = ShowLocationProviderProvider._();

/// Provider for show location setting
final class ShowLocationProviderProvider
    extends $AsyncNotifierProvider<ShowLocationProvider, bool> {
  /// Provider for show location setting
  ShowLocationProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showLocationProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showLocationProviderHash();

  @$internal
  @override
  ShowLocationProvider create() => ShowLocationProvider();
}

String _$showLocationProviderHash() =>
    r'1f3b8b63f3992561d75e88c5669637d8c1453073';

/// Provider for show location setting

abstract class _$ShowLocationProvider extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for public profile setting

@ProviderFor(PublicProfileProvider)
final publicProfileProviderProvider = PublicProfileProviderProvider._();

/// Provider for public profile setting
final class PublicProfileProviderProvider
    extends $AsyncNotifierProvider<PublicProfileProvider, bool> {
  /// Provider for public profile setting
  PublicProfileProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publicProfileProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publicProfileProviderHash();

  @$internal
  @override
  PublicProfileProvider create() => PublicProfileProvider();
}

String _$publicProfileProviderHash() =>
    r'93cdeac3d7b31d0b046de23cfccdb15ee090cdc7';

/// Provider for public profile setting

abstract class _$PublicProfileProvider extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for distance unit setting ('km' or 'miles')

@ProviderFor(DistanceUnitProvider)
final distanceUnitProviderProvider = DistanceUnitProviderProvider._();

/// Provider for distance unit setting ('km' or 'miles')
final class DistanceUnitProviderProvider
    extends $AsyncNotifierProvider<DistanceUnitProvider, String> {
  /// Provider for distance unit setting ('km' or 'miles')
  DistanceUnitProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'distanceUnitProviderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$distanceUnitProviderHash();

  @$internal
  @override
  DistanceUnitProvider create() => DistanceUnitProvider();
}

String _$distanceUnitProviderHash() =>
    r'62bbd9d8167909a6d96995ed5cead2cdc5684e24';

/// Provider for distance unit setting ('km' or 'miles')

abstract class _$DistanceUnitProvider extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SavedCredentialsNotifier)
final savedCredentialsProvider = SavedCredentialsNotifierProvider._();

final class SavedCredentialsNotifierProvider
    extends $AsyncNotifierProvider<SavedCredentialsNotifier, SavedCredentials> {
  SavedCredentialsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedCredentialsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedCredentialsNotifierHash();

  @$internal
  @override
  SavedCredentialsNotifier create() => SavedCredentialsNotifier();
}

String _$savedCredentialsNotifierHash() =>
    r'58099867c8ec174117079b3d05c5039687aadfa6';

abstract class _$SavedCredentialsNotifier
    extends $AsyncNotifier<SavedCredentials> {
  FutureOr<SavedCredentials> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SavedCredentials>, SavedCredentials>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SavedCredentials>, SavedCredentials>,
              AsyncValue<SavedCredentials>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
