// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Payment Processing View Model

@ProviderFor(PaymentViewModel)
final paymentViewModelProvider = PaymentViewModelProvider._();

/// Payment Processing View Model
final class PaymentViewModelProvider
    extends $AsyncNotifierProvider<PaymentViewModel, void> {
  /// Payment Processing View Model
  PaymentViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentViewModelHash();

  @$internal
  @override
  PaymentViewModel create() => PaymentViewModel();
}

String _$paymentViewModelHash() => r'77f937219221b7e5eeaef26da6cd2683aee2c876';

/// Payment Processing View Model

abstract class _$PaymentViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Rider Payment History Provider

@ProviderFor(riderPaymentHistory)
final riderPaymentHistoryProvider = RiderPaymentHistoryFamily._();

/// Rider Payment History Provider

final class RiderPaymentHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentTransaction>>,
          List<PaymentTransaction>,
          FutureOr<List<PaymentTransaction>>
        >
    with
        $FutureModifier<List<PaymentTransaction>>,
        $FutureProvider<List<PaymentTransaction>> {
  /// Rider Payment History Provider
  RiderPaymentHistoryProvider._({
    required RiderPaymentHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'riderPaymentHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$riderPaymentHistoryHash();

  @override
  String toString() {
    return r'riderPaymentHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PaymentTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentTransaction>> create(Ref ref) {
    final argument = this.argument as String;
    return riderPaymentHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RiderPaymentHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$riderPaymentHistoryHash() =>
    r'fd998f8add167a933b227ec8ad0d4267ac260248';

/// Rider Payment History Provider

final class RiderPaymentHistoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PaymentTransaction>>, String> {
  RiderPaymentHistoryFamily._()
    : super(
        retry: null,
        name: r'riderPaymentHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Rider Payment History Provider

  RiderPaymentHistoryProvider call(String riderId) =>
      RiderPaymentHistoryProvider._(argument: riderId, from: this);

  @override
  String toString() => r'riderPaymentHistoryProvider';
}

/// Rider Payment History Stream Provider

@ProviderFor(riderPaymentHistoryStream)
final riderPaymentHistoryStreamProvider = RiderPaymentHistoryStreamFamily._();

/// Rider Payment History Stream Provider

final class RiderPaymentHistoryStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentTransaction>>,
          List<PaymentTransaction>,
          Stream<List<PaymentTransaction>>
        >
    with
        $FutureModifier<List<PaymentTransaction>>,
        $StreamProvider<List<PaymentTransaction>> {
  /// Rider Payment History Stream Provider
  RiderPaymentHistoryStreamProvider._({
    required RiderPaymentHistoryStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'riderPaymentHistoryStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$riderPaymentHistoryStreamHash();

  @override
  String toString() {
    return r'riderPaymentHistoryStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PaymentTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PaymentTransaction>> create(Ref ref) {
    final argument = this.argument as String;
    return riderPaymentHistoryStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RiderPaymentHistoryStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$riderPaymentHistoryStreamHash() =>
    r'da19f75a68f80a8a3d84775f5323350986f82cbf';

/// Rider Payment History Stream Provider

final class RiderPaymentHistoryStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PaymentTransaction>>, String> {
  RiderPaymentHistoryStreamFamily._()
    : super(
        retry: null,
        name: r'riderPaymentHistoryStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Rider Payment History Stream Provider

  RiderPaymentHistoryStreamProvider call(String riderId) =>
      RiderPaymentHistoryStreamProvider._(argument: riderId, from: this);

  @override
  String toString() => r'riderPaymentHistoryStreamProvider';
}

/// Driver Connected Account View Model

@ProviderFor(DriverConnectedAccountViewModel)
final driverConnectedAccountViewModelProvider =
    DriverConnectedAccountViewModelFamily._();

/// Driver Connected Account View Model
final class DriverConnectedAccountViewModelProvider
    extends
        $AsyncNotifierProvider<
          DriverConnectedAccountViewModel,
          DriverConnectedAccount?
        > {
  /// Driver Connected Account View Model
  DriverConnectedAccountViewModelProvider._({
    required DriverConnectedAccountViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driverConnectedAccountViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverConnectedAccountViewModelHash();

  @override
  String toString() {
    return r'driverConnectedAccountViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DriverConnectedAccountViewModel create() => DriverConnectedAccountViewModel();

  @override
  bool operator ==(Object other) {
    return other is DriverConnectedAccountViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverConnectedAccountViewModelHash() =>
    r'b11ea36b4b453b1210debe974871e8b8b61b6df9';

/// Driver Connected Account View Model

final class DriverConnectedAccountViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          DriverConnectedAccountViewModel,
          AsyncValue<DriverConnectedAccount?>,
          DriverConnectedAccount?,
          FutureOr<DriverConnectedAccount?>,
          String
        > {
  DriverConnectedAccountViewModelFamily._()
    : super(
        retry: null,
        name: r'driverConnectedAccountViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Driver Connected Account View Model

  DriverConnectedAccountViewModelProvider call(String driverId) =>
      DriverConnectedAccountViewModelProvider._(argument: driverId, from: this);

  @override
  String toString() => r'driverConnectedAccountViewModelProvider';
}

/// Driver Connected Account View Model

abstract class _$DriverConnectedAccountViewModel
    extends $AsyncNotifier<DriverConnectedAccount?> {
  late final _$args = ref.$arg as String;
  String get driverId => _$args;

  FutureOr<DriverConnectedAccount?> build(String driverId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<DriverConnectedAccount?>,
              DriverConnectedAccount?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DriverConnectedAccount?>,
                DriverConnectedAccount?
              >,
              AsyncValue<DriverConnectedAccount?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Driver Earnings Summary Provider

@ProviderFor(driverEarningsSummary)
final driverEarningsSummaryProvider = DriverEarningsSummaryFamily._();

/// Driver Earnings Summary Provider

final class DriverEarningsSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<EarningsSummary>,
          EarningsSummary,
          FutureOr<EarningsSummary>
        >
    with $FutureModifier<EarningsSummary>, $FutureProvider<EarningsSummary> {
  /// Driver Earnings Summary Provider
  DriverEarningsSummaryProvider._({
    required DriverEarningsSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driverEarningsSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverEarningsSummaryHash();

  @override
  String toString() {
    return r'driverEarningsSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EarningsSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EarningsSummary> create(Ref ref) {
    final argument = this.argument as String;
    return driverEarningsSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverEarningsSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverEarningsSummaryHash() =>
    r'b114f8219aba3b990907d3f1e72687f5b29bd052';

/// Driver Earnings Summary Provider

final class DriverEarningsSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EarningsSummary>, String> {
  DriverEarningsSummaryFamily._()
    : super(
        retry: null,
        name: r'driverEarningsSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Driver Earnings Summary Provider

  DriverEarningsSummaryProvider call(String driverId) =>
      DriverEarningsSummaryProvider._(argument: driverId, from: this);

  @override
  String toString() => r'driverEarningsSummaryProvider';
}

/// Driver Earnings Transactions Provider

@ProviderFor(driverEarningsTransactions)
final driverEarningsTransactionsProvider = DriverEarningsTransactionsFamily._();

/// Driver Earnings Transactions Provider

final class DriverEarningsTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentTransaction>>,
          List<PaymentTransaction>,
          FutureOr<List<PaymentTransaction>>
        >
    with
        $FutureModifier<List<PaymentTransaction>>,
        $FutureProvider<List<PaymentTransaction>> {
  /// Driver Earnings Transactions Provider
  DriverEarningsTransactionsProvider._({
    required DriverEarningsTransactionsFamily super.from,
    required (String, {DateTime? startDate, DateTime? endDate}) super.argument,
  }) : super(
         retry: null,
         name: r'driverEarningsTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverEarningsTransactionsHash();

  @override
  String toString() {
    return r'driverEarningsTransactionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<PaymentTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentTransaction>> create(Ref ref) {
    final argument =
        this.argument as (String, {DateTime? startDate, DateTime? endDate});
    return driverEarningsTransactions(
      ref,
      argument.$1,
      startDate: argument.startDate,
      endDate: argument.endDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DriverEarningsTransactionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverEarningsTransactionsHash() =>
    r'aafc3a45cf804e67c053e0cdec85c58175968fff';

/// Driver Earnings Transactions Provider

final class DriverEarningsTransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PaymentTransaction>>,
          (String, {DateTime? startDate, DateTime? endDate})
        > {
  DriverEarningsTransactionsFamily._()
    : super(
        retry: null,
        name: r'driverEarningsTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Driver Earnings Transactions Provider

  DriverEarningsTransactionsProvider call(
    String driverId, {
    DateTime? startDate,
    DateTime? endDate,
  }) => DriverEarningsTransactionsProvider._(
    argument: (driverId, startDate: startDate, endDate: endDate),
    from: this,
  );

  @override
  String toString() => r'driverEarningsTransactionsProvider';
}

/// Driver Payouts Provider

@ProviderFor(driverPayouts)
final driverPayoutsProvider = DriverPayoutsFamily._();

/// Driver Payouts Provider

final class DriverPayoutsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DriverPayout>>,
          List<DriverPayout>,
          FutureOr<List<DriverPayout>>
        >
    with
        $FutureModifier<List<DriverPayout>>,
        $FutureProvider<List<DriverPayout>> {
  /// Driver Payouts Provider
  DriverPayoutsProvider._({
    required DriverPayoutsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driverPayoutsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driverPayoutsHash();

  @override
  String toString() {
    return r'driverPayoutsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DriverPayout>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DriverPayout>> create(Ref ref) {
    final argument = this.argument as String;
    return driverPayouts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DriverPayoutsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driverPayoutsHash() => r'd2d2495c556117b32aa19c801fbe9f985370f1f3';

/// Driver Payouts Provider

final class DriverPayoutsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<DriverPayout>>, String> {
  DriverPayoutsFamily._()
    : super(
        retry: null,
        name: r'driverPayoutsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Driver Payouts Provider

  DriverPayoutsProvider call(String driverId) =>
      DriverPayoutsProvider._(argument: driverId, from: this);

  @override
  String toString() => r'driverPayoutsProvider';
}

/// Driver Payout View Model

@ProviderFor(DriverPayoutViewModel)
final driverPayoutViewModelProvider = DriverPayoutViewModelProvider._();

/// Driver Payout View Model
final class DriverPayoutViewModelProvider
    extends $AsyncNotifierProvider<DriverPayoutViewModel, void> {
  /// Driver Payout View Model
  DriverPayoutViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverPayoutViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverPayoutViewModelHash();

  @$internal
  @override
  DriverPayoutViewModel create() => DriverPayoutViewModel();
}

String _$driverPayoutViewModelHash() =>
    r'58df7fe0f7c9ff0a3f7ad92c2ff87f988a35d7b9';

/// Driver Payout View Model

abstract class _$DriverPayoutViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider to get current driver's Stripe status

@ProviderFor(driverStripeStatus)
final driverStripeStatusProvider = DriverStripeStatusProvider._();

/// Provider to get current driver's Stripe status

final class DriverStripeStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<DriverStripeStatus>,
          DriverStripeStatus,
          FutureOr<DriverStripeStatus>
        >
    with
        $FutureModifier<DriverStripeStatus>,
        $FutureProvider<DriverStripeStatus> {
  /// Provider to get current driver's Stripe status
  DriverStripeStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverStripeStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverStripeStatusHash();

  @$internal
  @override
  $FutureProviderElement<DriverStripeStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DriverStripeStatus> create(Ref ref) {
    return driverStripeStatus(ref);
  }
}

String _$driverStripeStatusHash() =>
    r'1122794ebb3cdf0db26a661cf3ece12e5a50311d';
