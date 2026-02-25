// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_auth_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel that manages the phone-OTP verification flow.
///
/// States flow:  idle → sending → codeSent ↔ verifying → verified
///                                    ↘ error ↙

@ProviderFor(PhoneAuthViewModel)
final phoneAuthViewModelProvider = PhoneAuthViewModelProvider._();

/// ViewModel that manages the phone-OTP verification flow.
///
/// States flow:  idle → sending → codeSent ↔ verifying → verified
///                                    ↘ error ↙
final class PhoneAuthViewModelProvider
    extends $NotifierProvider<PhoneAuthViewModel, PhoneAuthState> {
  /// ViewModel that manages the phone-OTP verification flow.
  ///
  /// States flow:  idle → sending → codeSent ↔ verifying → verified
  ///                                    ↘ error ↙
  PhoneAuthViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'phoneAuthViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$phoneAuthViewModelHash();

  @$internal
  @override
  PhoneAuthViewModel create() => PhoneAuthViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhoneAuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhoneAuthState>(value),
    );
  }
}

String _$phoneAuthViewModelHash() =>
    r'904b1cb58c037d2302abf238216899059e94f437';

/// ViewModel that manages the phone-OTP verification flow.
///
/// States flow:  idle → sending → codeSent ↔ verifying → verified
///                                    ↘ error ↙

abstract class _$PhoneAuthViewModel extends $Notifier<PhoneAuthState> {
  PhoneAuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PhoneAuthState, PhoneAuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PhoneAuthState, PhoneAuthState>,
              PhoneAuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
