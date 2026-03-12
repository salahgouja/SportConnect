import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_connect/core/interfaces/repositories/i_auth_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_booking_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_chat_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_dispute_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_driver_stats_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_event_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_home_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_notification_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_payment_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_review_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_ride_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_support_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_user_repository.dart';
import 'package:sport_connect/core/interfaces/repositories/i_vehicle_repository.dart';
import 'package:sport_connect/core/providers/firebase_providers.dart';
import 'package:sport_connect/core/repositories/settings_repository.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';
import 'package:sport_connect/features/events/repositories/event_repository.dart';
import 'package:sport_connect/features/home/repositories/home_repository.dart';
import 'package:sport_connect/features/messaging/repositories/chat_repository.dart';
import 'package:sport_connect/features/notifications/repositories/notification_repository.dart';
import 'package:sport_connect/features/onboarding/repositories/onboarding_repository.dart';
import 'package:sport_connect/features/payments/repositories/payment_repository.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/features/profile/repositories/support_repository.dart';
import 'package:sport_connect/features/reviews/repositories/review_repository.dart';
import 'package:sport_connect/features/rides/repositories/booking_repository.dart';
import 'package:sport_connect/features/rides/repositories/dispute_repository.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';
import 'package:sport_connect/features/vehicles/repositories/vehicle_repository.dart';

part 'repository_providers.g.dart';

// =============================================================================
// 📦 REPOSITORY PROVIDERS (Interface-Based for DIP Compliance)
// =============================================================================
//
// keepAlive: true  → repositories used app-wide or holding persistent
//                    real-time Firebase listeners (expensive to recreate).
// keepAlive: false → feature-scoped repositories or one-shot async use cases
//                    (auto-dispose, default Riverpod behaviour).
//
// Override pattern for tests:
//   final container = ProviderContainer(
//     overrides: [
//       authRepositoryProvider.overrideWithValue(MockAuthRepository()),
//     ],
//   );
// =============================================================================

// ---------------------------------------------------------------------------
// 🔑  Auth  —  keepAlive: true
// Used globally for authentication state, user data streams, and sign-in
// flows across every feature.
// ---------------------------------------------------------------------------

/// Auth repository provider (interface-based).
///
/// Returns [IAuthRepository] for dependency inversion, enabling mocking in
/// tests. All Firebase instances are injected via [firebase_providers.dart].
@Riverpod(keepAlive: true)
IAuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(authInstanceProvider),
    ref.watch(storageInstanceProvider),
    ref.watch(firestoreInstanceProvider),
  );
}

// ---------------------------------------------------------------------------
// 💬  Chat  —  keepAlive: true
// Holds real-time Firestore listeners for the inbox; navigating between
// screens should not tear down and recreate active chat streams.
// ---------------------------------------------------------------------------

/// Chat repository provider (interface-based).
@Riverpod(keepAlive: true)
IChatRepository chatRepository(Ref ref) {
  return ChatRepository(
    ref.watch(firestoreInstanceProvider),
    ref.watch(storageInstanceProvider),
  );
}

// ---------------------------------------------------------------------------
// 🔔  Notifications  —  keepAlive: true
// Real-time unread-count badge and notification stream are watched from
// multiple widgets; keeping alive avoids repeated Firestore subscriptions.
// ---------------------------------------------------------------------------

/// Notification repository provider (interface-based).
@Riverpod(keepAlive: true)
INotificationRepository notificationRepository(Ref ref) {
  return NotificationRepository(ref.watch(firestoreInstanceProvider));
}

// ---------------------------------------------------------------------------
// 👤  Profile  —  keepAlive: true
// Current-user stream is observed throughout the app (app bar, settings,
// profile screens). Disposing this would cancel the Firestore listener on
// every screen transition.
// ---------------------------------------------------------------------------

/// User/profile repository provider (interface-based).
@Riverpod(keepAlive: true)
IUserRepository profileRepository(Ref ref) {
  return ProfileRepository(
    ref.watch(firestoreInstanceProvider),
    ref.watch(storageInstanceProvider),
  );
}

// ---------------------------------------------------------------------------
// 🚗  Ride  —  keepAlive: true
// Core business entity; used across multiple view-models, services, and
// background listeners for the active-ride tracking flow.
// ---------------------------------------------------------------------------

/// Ride repository provider (interface-based).
@Riverpod(keepAlive: true)
IRideRepository rideRepository(Ref ref) {
  return RideRepository(ref.watch(firestoreInstanceProvider));
}

// ---------------------------------------------------------------------------
// 📋  Booking  —  keepAlive: true
// Bookings are read alongside rides in the same flow; keeping alive avoids
// double round-trips when the ride detail screen is re-entered.
// ---------------------------------------------------------------------------

/// Booking repository provider (interface-based).
@Riverpod(keepAlive: true)
IBookingRepository bookingRepository(Ref ref) {
  return BookingRepository(ref.watch(firestoreInstanceProvider));
}

// ---------------------------------------------------------------------------
// 💳  Payment  —  keepAlive: true
// Stripe payment sheet and payout flows require the repository to remain
// alive during multi-step checkout; also depends on a keepAlive
// StripeService singleton.
// ---------------------------------------------------------------------------

/// Payment repository provider (interface-based).
@Riverpod(keepAlive: true)
IPaymentRepository paymentRepository(Ref ref) {
  return PaymentRepository(
    ref.watch(firestoreInstanceProvider),
    ref.read(stripeServiceProvider),
  );
}

// ---------------------------------------------------------------------------
// 📊  Driver Stats  —  keepAlive: true
// Streams earnings, pending requests, and upcoming rides continuously while
// the driver is logged in; tearing down these listeners on each navigation
// event would cause noticeable data flicker.
// ---------------------------------------------------------------------------

/// Driver stats repository provider (interface-based).
@Riverpod(keepAlive: true)
IDriverStatsRepository driverStatsRepository(Ref ref) {
  return DriverStatsRepository(ref.watch(firestoreInstanceProvider));
}

// ---------------------------------------------------------------------------
// ⚙️  Settings  —  keepAlive: true
// App-wide locale and theme preferences are read by the MaterialApp root
// widget; disposing this would cause theme flicker on navigation.
// ---------------------------------------------------------------------------

/// SharedPreferences instance provider.
///
/// Kept alive so that settings and onboarding providers share the same
/// already-initialised instance throughout the app lifetime.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

/// Settings repository provider.
@Riverpod(keepAlive: true)
Future<SettingsRepository> settingsRepository(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SettingsRepository(prefs);
}

// ---------------------------------------------------------------------------
// 🎉  Events  —  keepAlive: false (auto-dispose)
// The EventSelectionViewModel is keepAlive (maintains selection across navigation),
// so the event repository it depends on must also be keepAlive.
// ---------------------------------------------------------------------------

/// Event repository provider (interface-based).
@Riverpod(keepAlive: true)
IEventRepository eventRepository(Ref ref) {
  return EventRepository(
    ref.watch(firestoreInstanceProvider),
    ref.watch(storageInstanceProvider),
  );
}

// ---------------------------------------------------------------------------
// 🏠  Home  —  keepAlive: false (auto-dispose)
// Nearby-rides and hotspot streams are only needed while the home tab is
// visible; auto-dispose is appropriate.
// ---------------------------------------------------------------------------

/// Home repository provider (interface-based).
@riverpod
IHomeRepository homeRepository(Ref ref) {
  return HomeRepository(ref.watch(firestoreInstanceProvider));
}

// ---------------------------------------------------------------------------
// 🚨  Dispute  —  keepAlive: false (auto-dispose)
// One-shot submission flow; the repository is only needed during the dispute
// form screen lifecycle.
// ---------------------------------------------------------------------------

/// Dispute repository provider (interface-based).
@riverpod
IDisputeRepository disputeRepository(Ref ref) {
  return DisputeRepository(
    ref.watch(firestoreInstanceProvider),
    ref.watch(storageInstanceProvider),
  );
}

// ---------------------------------------------------------------------------
// ⭐  Review  —  keepAlive: false (auto-dispose)
// Used only inside ride-completion and profile review screens.
// ---------------------------------------------------------------------------

/// Review repository provider (interface-based).
@riverpod
IReviewRepository reviewRepository(Ref ref) {
  return ReviewRepository(ref.watch(firestoreInstanceProvider));
}

// ---------------------------------------------------------------------------
// 🆘  Support  —  keepAlive: false (auto-dispose)
// One-shot report/ticket submission; auto-dispose is appropriate.
// ---------------------------------------------------------------------------

/// Support repository provider (interface-based).
@riverpod
ISupportRepository supportRepository(Ref ref) {
  return SupportRepository(
    ref.watch(firestoreInstanceProvider),
    ref.watch(storageInstanceProvider),
  );
}

// ---------------------------------------------------------------------------
// 🚘  Vehicle  —  keepAlive: true
// Also consumed by DriverOfferRideViewModel (keepAlive) during ride creation
// to resolve vehicle info for denormalization.
// ---------------------------------------------------------------------------

/// Vehicle repository provider (interface-based).
@Riverpod(keepAlive: true)
IVehicleRepository vehicleRepository(Ref ref) {
  return VehicleRepository(
    ref.watch(firestoreInstanceProvider),
    ref.watch(storageInstanceProvider),
  );
}

// ---------------------------------------------------------------------------
// 🎓  Onboarding  —  keepAlive: false (auto-dispose)
// Only needed during the onboarding flow at first launch; discarded after.
// ---------------------------------------------------------------------------

/// Onboarding repository provider (async, SharedPreferences-backed).
@riverpod
Future<OnboardingRepository> onboardingRepository(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return OnboardingRepository(prefs);
}
