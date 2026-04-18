// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_settings_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DriverSettingsViewModel)
final driverSettingsViewModelProvider = DriverSettingsViewModelProvider._();

final class DriverSettingsViewModelProvider
    extends $NotifierProvider<DriverSettingsViewModel, DriverSettingsState> {
  DriverSettingsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverSettingsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverSettingsViewModelHash();

  @$internal
  @override
  DriverSettingsViewModel create() => DriverSettingsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverSettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverSettingsState>(value),
    );
  }
}

String _$driverSettingsViewModelHash() =>
    r'2a3cf8a25adf863a9cb45fb4f2673855a54efa30';

abstract class _$DriverSettingsViewModel
    extends $Notifier<DriverSettingsState> {
  DriverSettingsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DriverSettingsState, DriverSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DriverSettingsState, DriverSettingsState>,
              DriverSettingsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
