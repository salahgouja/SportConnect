import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/models/user/user_model.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';

part 'pending_booking_view_model.g.dart';

enum PendingBookingEffectType { navigateCountdown, navigateMyRides, snackbar }

@immutable
class PendingBookingEffect {
  const PendingBookingEffect._({
    required this.type,
    this.bookingId,
    this.message,
  });

  const PendingBookingEffect.navigateCountdown(String bookingId)
    : this._(
        type: PendingBookingEffectType.navigateCountdown,
        bookingId: bookingId,
      );

  const PendingBookingEffect.navigateMyRides({String? message})
    : this._(type: PendingBookingEffectType.navigateMyRides, message: message);

  const PendingBookingEffect.snackbar(String message)
    : this._(type: PendingBookingEffectType.snackbar, message: message);

  final PendingBookingEffectType type;
  final String? bookingId;
  final String? message;
}

@immutable
class PendingBookingState {
  const PendingBookingState({
    required this.rideId,
    this.currentUserId,
    this.rideAsync = const AsyncValue.loading(),
    this.bookingData,
    this.expiresAt,
    this.timeRemaining = Duration.zero,
    this.isProcessingPayment = false,
    this.isCancelling = false,
    this.paymentFailed = false,
    this.lastError,
    this.osrmRoutePoints,
    this.loadedRouteKey,
    this.loadingRouteKey,
    this.isLoadingOsrmRoute = false,
  });

  static const _unset = Object();

  final String rideId;
  final String? currentUserId;
  final AsyncValue<RideModel?> rideAsync;
  final RideBooking? bookingData;
  final DateTime? expiresAt;
  final Duration timeRemaining;
  final bool isProcessingPayment;
  final bool isCancelling;
  final bool paymentFailed;
  final String? lastError;
  final List<LatLng>? osrmRoutePoints;
  final String? loadedRouteKey;
  final String? loadingRouteKey;
  final bool isLoadingOsrmRoute;

  RideModel? get ride => rideAsync.value;
  RideBooking? get booking => bookingData;

  bool get isAcceptedNeedsPayment =>
      booking?.status == BookingStatus.accepted &&
      ride?.acceptsOnlinePayment == true &&
      booking?.paymentIntentId == null;

  bool get isPending => booking?.status == BookingStatus.pending;

  bool get hasResolvableError =>
      paymentFailed || lastError != null || rideAsync.hasError;

  PendingBookingState copyWith({
    String? currentUserId,
    AsyncValue<RideModel?>? rideAsync,
    Object? bookingData = _unset,
    Object? expiresAt = _unset,
    Duration? timeRemaining,
    bool? isProcessingPayment,
    bool? isCancelling,
    bool? paymentFailed,
    Object? lastError = _unset,
    Object? osrmRoutePoints = _unset,
    Object? loadedRouteKey = _unset,
    Object? loadingRouteKey = _unset,
    bool? isLoadingOsrmRoute,
  }) {
    return PendingBookingState(
      rideId: rideId,
      currentUserId: currentUserId ?? this.currentUserId,
      rideAsync: rideAsync ?? this.rideAsync,
      bookingData: bookingData == _unset
          ? this.bookingData
          : bookingData as RideBooking?,
      expiresAt: expiresAt == _unset ? this.expiresAt : expiresAt as DateTime?,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
      isCancelling: isCancelling ?? this.isCancelling,
      paymentFailed: paymentFailed ?? this.paymentFailed,
      lastError: lastError == _unset ? this.lastError : lastError as String?,
      osrmRoutePoints: osrmRoutePoints == _unset
          ? this.osrmRoutePoints
          : osrmRoutePoints as List<LatLng>?,
      loadedRouteKey: loadedRouteKey == _unset
          ? this.loadedRouteKey
          : loadedRouteKey as String?,
      loadingRouteKey: loadingRouteKey == _unset
          ? this.loadingRouteKey
          : loadingRouteKey as String?,
      isLoadingOsrmRoute: isLoadingOsrmRoute ?? this.isLoadingOsrmRoute,
    );
  }
}

@riverpod
class PendingBookingViewModel extends _$PendingBookingViewModel {
  final Queue<PendingBookingEffect> _effects = Queue<PendingBookingEffect>();
  Timer? _countdownTimer;
  String? _lastLifecycleEffectKey;

  @override
  PendingBookingState build(String rideId) {
    final currentUserId = ref.watch(
      currentUserProvider.select((value) => value.value?.uid),
    );

    ref.onDispose(() {
      _countdownTimer?.cancel();
    });

    ref.listen<RideDetailState>(
      rideDetailViewModelProvider(rideId),
      (_, next) => syncRideState(next),
    );

    if (currentUserId == null) {
      // Schedule sync after build completes
      Future.microtask(
        () => syncPassengerBookings(
          const AsyncValue<List<RideBooking>>.data(<RideBooking>[]),
        ),
      );
    } else {
      ref.listen<AsyncValue<List<RideBooking>>>(
        bookingsByPassengerProvider(currentUserId),
        (_, next) => syncPassengerBookings(next),
      );
    }

    return PendingBookingState(rideId: rideId, currentUserId: currentUserId);
  }

  bool get hasPendingEffects => _effects.isNotEmpty;

  PendingBookingEffect? takeEffect() {
    if (_effects.isEmpty) return null;
    return _effects.removeFirst();
  }

  void syncRideState(RideDetailState rideState) {
    state = state.copyWith(
      rideAsync: rideState.ride,
      lastError: rideState.ride.hasError
          ? rideState.ride.error.toString()
          : state.lastError,
    );

    final ride = rideState.ride.value;
    if (ride != null) {
      unawaited(ensureOsrmRouteLoaded(ride));
    }
    _emitLifecycleEffects();
  }

  void syncPassengerBookings(AsyncValue<List<RideBooking>> bookingsAsync) {
    RideBooking? matchingBooking;
    final bookings = bookingsAsync.value;
    if (bookings != null) {
      for (final booking in bookings) {
        if (booking.rideId == state.rideId) {
          matchingBooking = booking;
          break;
        }
      }
    }

    final previousCreatedAt = state.booking?.createdAt;
    state = state.copyWith(
      bookingData: matchingBooking,
      lastError: bookingsAsync.hasError
          ? bookingsAsync.error.toString()
          : state.lastError,
    );

    if (matchingBooking?.createdAt != previousCreatedAt) {
      _syncCountdown(matchingBooking?.createdAt);
    } else if (matchingBooking == null) {
      _stopCountdown();
    }

    _emitLifecycleEffects();
  }

  Future<void> ensureOsrmRouteLoaded(RideModel ride) async {
    final routeKey = _routeKeyFor(ride);
    final alreadyLoaded =
        state.loadedRouteKey == routeKey && state.osrmRoutePoints != null;
    final isLoadingSameRoute =
        state.isLoadingOsrmRoute && state.loadingRouteKey == routeKey;
    if (alreadyLoaded || isLoadingSameRoute) {
      return;
    }

    state = state.copyWith(
      isLoadingOsrmRoute: true,
      loadingRouteKey: routeKey,
      osrmRoutePoints: state.loadedRouteKey == routeKey
          ? state.osrmRoutePoints
          : null,
      loadedRouteKey: state.loadedRouteKey == routeKey
          ? state.loadedRouteKey
          : null,
    );

    try {
      final waypoints = ride.route.waypoints
          .map(
            (waypoint) =>
                LatLng(waypoint.location.latitude, waypoint.location.longitude),
          )
          .toList(growable: false);

      final routeInfo = await RoutingService.getRoute(
        origin: LatLng(ride.origin.latitude, ride.origin.longitude),
        destination: LatLng(
          ride.destination.latitude,
          ride.destination.longitude,
        ),
        waypoints: waypoints.isEmpty ? null : waypoints,
      );

      if (state.loadingRouteKey != routeKey) {
        return;
      }

      state = state.copyWith(
        osrmRoutePoints: routeInfo?.coordinates,
        loadedRouteKey: routeKey,
        loadingRouteKey: null,
        isLoadingOsrmRoute: false,
      );
    } catch (error, stackTrace) {
      TalkerService.error(
        'Error loading pending booking OSRM route',
        error,
        stackTrace,
      );
      if (state.loadingRouteKey != routeKey) {
        return;
      }

      state = state.copyWith(
        loadedRouteKey: routeKey,
        loadingRouteKey: null,
        isLoadingOsrmRoute: false,
      );
    }
  }

  Future<void> processPayment() async {
    if (state.isProcessingPayment || !state.isAcceptedNeedsPayment) {
      return;
    }

    final ride = state.ride;
    final booking = state.booking;
    if (ride == null || booking == null) {
      return;
    }

    state = state.copyWith(
      isProcessingPayment: true,
      paymentFailed: false,
      lastError: null,
    );

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        throw Exception('User not found');
      }

      final paymentViewModel = ref.read(paymentViewModelProvider.notifier);
      final driverProfile = await ref.read(
        userProfileProvider(ride.driverId).future,
      );
      if (driverProfile == null) {
        throw Exception('Driver profile not found');
      }

      final driverModel = driverProfile.asDriver;
      if (driverModel == null) {
        throw Exception('Driver profile is not a driver account');
      }

      final driverStripeAccountId = driverModel.stripeAccountId;
      if (driverStripeAccountId == null || driverStripeAccountId.isEmpty) {
        throw StripePaymentException(
          'Driver has not set up payment processing yet.',
        );
      }

      final customerId = await paymentViewModel.getOrCreateCustomer(
        userId: user.uid,
        email: user.email,
        name: user.displayName,
        phone: user.phoneNumber,
      );

      final totalAmount = ride.pricePerSeat * booking.seatsBooked;
      final stripeService = ref.read(stripeServiceProvider);
      final paymentData = await stripeService.createPaymentIntent(
        rideId: ride.id,
        riderId: user.uid,
        riderName: user.displayName,
        driverId: ride.driverId,
        driverName: driverProfile.displayName,
        amount: totalAmount,
        currency: _currencyIsoCode(ride.currency ?? 'eur'),
        customerId: customerId,
        driverStripeAccountId: driverStripeAccountId,
        description: '${ride.origin.address} → ${ride.destination.address}',
      );

      final paymentSuccess = await stripeService.processPaymentWithSheet(
        paymentIntentClientSecret: paymentData['clientSecret'] as String,
        customerId: customerId,
        ephemeralKeySecret: paymentData['ephemeralKey'] as String?,
      );

      if (!paymentSuccess) {
        state = state.copyWith(
          isProcessingPayment: false,
          paymentFailed: true,
          lastError: 'Payment cancelled.',
        );
        _enqueueEffect(
          const PendingBookingEffect.snackbar(
            'Payment cancelled. Tap "Complete Payment" to retry.',
          ),
        );
        return;
      }

      final paymentIntentId = paymentData['paymentIntentId'] as String;
      try {
        await ref
            .read(rideActionsViewModelProvider)
            .markBookingPaid(
              bookingId: booking.id,
              paymentIntentId: paymentIntentId,
            );
      } catch (_) {
        // Best effort only.
      }

      final updatedBooking = booking.copyWith(
        paymentIntentId: paymentIntentId,
        paidAt: DateTime.now(),
      );
      _lastLifecycleEffectKey =
          '${booking.id}|${BookingStatus.accepted.name}|$paymentIntentId';
      state = state.copyWith(
        bookingData: updatedBooking,
        isProcessingPayment: false,
        paymentFailed: false,
        lastError: null,
      );
      _enqueueEffect(PendingBookingEffect.navigateCountdown(booking.id));
    } on StripePaymentException catch (error) {
      state = state.copyWith(
        isProcessingPayment: false,
        paymentFailed: true,
        lastError: error.message,
      );
      _enqueueEffect(
        PendingBookingEffect.snackbar('Payment failed: ${error.message}'),
      );
    } catch (error, stackTrace) {
      TalkerService.error('Pending booking payment failed', error, stackTrace);
      state = state.copyWith(
        isProcessingPayment: false,
        paymentFailed: true,
        lastError: error.toString(),
      );
      _enqueueEffect(PendingBookingEffect.snackbar('Payment error: $error'));
    }
  }

  Future<void> cancelBooking() async {
    if (state.isCancelling || !state.isPending) {
      return;
    }

    final booking = state.booking;
    if (booking == null) {
      return;
    }

    state = state.copyWith(isCancelling: true, lastError: null);

    try {
      await ref
          .read(rideActionsViewModelProvider)
          .cancelBooking(rideId: state.rideId, bookingId: booking.id);

      _lastLifecycleEffectKey =
          '${booking.id}|${BookingStatus.cancelled.name}|${booking.paymentIntentId ?? ''}';
      state = state.copyWith(
        bookingData: booking.copyWith(status: BookingStatus.cancelled),
        isCancelling: false,
      );
      _enqueueEffect(const PendingBookingEffect.navigateMyRides());
    } catch (error, stackTrace) {
      TalkerService.error(
        'Pending booking cancellation failed',
        error,
        stackTrace,
      );
      state = state.copyWith(isCancelling: false, lastError: error.toString());
      _enqueueEffect(
        const PendingBookingEffect.snackbar(
          'Failed to cancel. Please try again.',
        ),
      );
    }
  }

  void _emitLifecycleEffects() {
    final booking = state.booking;
    if (booking == null || state.isProcessingPayment) {
      return;
    }

    final effectKey =
        '${booking.id}|${booking.status.name}|${booking.paymentIntentId ?? ''}';
    if (_lastLifecycleEffectKey == effectKey) {
      return;
    }

    switch (booking.status) {
      case BookingStatus.accepted:
        if (state.isAcceptedNeedsPayment) {
          return;
        }
        _lastLifecycleEffectKey = effectKey;
        _enqueueEffect(PendingBookingEffect.navigateCountdown(booking.id));
        return;
      case BookingStatus.rejected:
        _lastLifecycleEffectKey = effectKey;
        _enqueueEffect(
          const PendingBookingEffect.snackbar(
            'Your booking was declined by the driver.',
          ),
        );
        _enqueueEffect(const PendingBookingEffect.navigateMyRides());
        return;
      case BookingStatus.cancelled:
        _lastLifecycleEffectKey = effectKey;
        _enqueueEffect(
          const PendingBookingEffect.snackbar('Booking has been cancelled.'),
        );
        _enqueueEffect(const PendingBookingEffect.navigateMyRides());
        return;
      case BookingStatus.pending:
      case BookingStatus.completed:
        return;
    }
  }

  void _syncCountdown(DateTime? createdAt) {
    _countdownTimer?.cancel();

    if (createdAt == null) {
      state = state.copyWith(expiresAt: null, timeRemaining: Duration.zero);
      return;
    }

    final expiresAt = createdAt.add(const Duration(hours: 24));
    state = state.copyWith(expiresAt: expiresAt);
    _tickCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickCountdown();
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    state = state.copyWith(expiresAt: null, timeRemaining: Duration.zero);
  }

  void _tickCountdown() {
    final expiresAt = state.expiresAt;
    if (expiresAt == null) {
      return;
    }

    final remaining = expiresAt.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _countdownTimer?.cancel();
      state = state.copyWith(timeRemaining: Duration.zero);
      return;
    }

    state = state.copyWith(timeRemaining: remaining);
  }

  void _enqueueEffect(PendingBookingEffect effect) {
    _effects.add(effect);
    // Trigger a state update to notify listeners
    state = state.copyWith();
  }

  String _routeKeyFor(RideModel ride) {
    final buffer = StringBuffer()
      ..write(ride.id)
      ..write('|')
      ..write(ride.origin.latitude.toStringAsFixed(6))
      ..write(',')
      ..write(ride.origin.longitude.toStringAsFixed(6))
      ..write('|')
      ..write(ride.destination.latitude.toStringAsFixed(6))
      ..write(',')
      ..write(ride.destination.longitude.toStringAsFixed(6));

    for (final waypoint in ride.route.waypoints) {
      buffer
        ..write('|')
        ..write(waypoint.location.latitude.toStringAsFixed(6))
        ..write(',')
        ..write(waypoint.location.longitude.toStringAsFixed(6));
    }

    return buffer.toString();
  }

  String _currencyIsoCode(String currency) {
    const currencyMap = <String, String>{
      '€': 'eur',
      r'$': 'usd',
      '£': 'gbp',
      '¥': 'jpy',
      '₹': 'inr',
      'CHF': 'chf',
      r'A$': 'aud',
      r'C$': 'cad',
      'kr': 'sek',
      '₽': 'rub',
      '₩': 'krw',
      '฿': 'thb',
      '₪': 'ils',
      'R': 'zar',
      '₱': 'php',
      'RM': 'myr',
      'Rp': 'idr',
      '₫': 'vnd',
      '₺': 'try',
      'zł': 'pln',
      'Kč': 'czk',
      'Ft': 'huf',
      'lei': 'ron',
      'лв': 'bgn',
      'din': 'rsd',
      'DKK': 'dkk',
      'NOK': 'nok',
      r'NZ$': 'nzd',
      r'S$': 'sgd',
      r'HK$': 'hkd',
    };

    final normalized = currency.toLowerCase();
    if (normalized.length == 3 && RegExp(r'^[a-z]{3}$').hasMatch(normalized)) {
      return normalized;
    }
    return currencyMap[currency] ?? 'eur';
  }
}
