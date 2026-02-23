/// simple route definition holder
class AppRoute {
  final String path;
  final String name;
  const AppRoute(this.path, this.name);
}

class AppRoutes {
  static const splash = AppRoute('/', 'splash');
  static const onboarding = AppRoute('/onboarding', 'onboarding');
  static const login = AppRoute('/login', 'login');
  static const register = AppRoute('/register', 'register');
  static const signupWizard = AppRoute('/signup', 'signup-wizard');
  static const roleSelection = AppRoute('/role-selection', 'role-selection');
  static const riderOnboarding = AppRoute(
    '/rider/onboarding',
    'rider-onboarding',
  );

  // Driver Routes
  static const driverOnboarding = AppRoute(
    '/driver/onboarding',
    'driver-onboarding',
  );
  static const driverHome = AppRoute('/driver', 'driver-home');
  static const driverRides = AppRoute('/driver/rides', 'driver-rides');
  static const driverEarnings = AppRoute('/driver/earnings', 'driver-earnings');
  static const driverRequests = AppRoute('/driver/requests', 'driver-requests');
  static const driverProfile = AppRoute(
    '/driver/profile/:id',
    'driver-profile',
  );
  static const driverVehicles = AppRoute('/driver/vehicles', 'driver-vehicles');
  static const driverSettings = AppRoute('/driver/settings', 'driver-settings');
  static const driverStripeOnboarding = AppRoute(
    '/driver/stripe-onboarding',
    'driver-stripe-onboarding',
  );
  static const driverActiveRide = AppRoute(
    '/driver/active-ride',
    'driver-active-ride',
  );

  // Rider Routes
  static const riderActiveRide = AppRoute(
    '/rider/active-ride',
    'rider-active-ride',
  );
  static const riderRequestRide = AppRoute(
    '/rider/request',
    'rider-request-ride',
  );
  static const riderViewRide = AppRoute('/rider/ride/:id', 'rider-view-ride');
  static const riderMyRides = AppRoute('/rider/my-rides', 'rider-my-rides');

  // Shared / General
  static const profileSearch = AppRoute('/profile/search', 'profile-search');
  static const home = AppRoute('/home', 'home');
  static const paymentHistory = AppRoute('/payment-history', 'payment-history');
  static const profile = AppRoute('/profile', 'profile');
  static const editProfile = AppRoute('/edit-profile', 'edit-profile');
  static const settings = AppRoute('/settings', 'settings');
  static const achievements = AppRoute('/achievements', 'achievements');
  static const vehicles = AppRoute('/vehicles', 'vehicles');
  static const notifications = AppRoute('/notifications', 'notifications');

  // Chat
  static const chat = AppRoute('/chat', 'chat');
  static const chatDetail = AppRoute('/chat/detail/:id', 'chat-detail');
  static const chatGroup = AppRoute('/chat/group/:id', 'chat-group');
  static const chatRide = AppRoute('/chat/ride/:id', 'chat-ride');

  // Rides
  static const createRide = AppRoute('/ride/create', 'create-ride');
  static const rideDetail = AppRoute('/ride/detail/:id', 'ride-detail');
  static const searchRides = AppRoute('/ride/search', 'search-rides');
  static const driverOfferRide = AppRoute('/driver/offer', 'driver-offer-ride');
  static const driverViewRide = AppRoute(
    '/driver/ride/:id',
    'driver-view-ride',
  );
  static const driverMyRides = AppRoute('/driver/my-rides', 'driver-my-rides');

  // Auth Recovery
  static const forgotPassword = AppRoute('/forgot-password', 'forgot-password');
  static const emailVerification = AppRoute(
    '/email-verification',
    'email-verification',
  );

  // Reviews & Ratings
  static const submitReview = AppRoute('/review/submit', 'submit-review');
  static const reviewsList = AppRoute('/reviews/:userId', 'reviews-list');

  // Ride Lifecycle
  static const rideCompletion = AppRoute(
    '/ride/completion/:id',
    'ride-completion',
  );
  static const rideNavigation = AppRoute(
    '/ride/navigation/:id',
    'ride-navigation',
  );
  static const cancellationReason = AppRoute(
    '/ride/cancel/:id',
    'cancellation-reason',
  );
  static const dispute = AppRoute('/dispute/:id', 'dispute');

  // Support & Legal
  static const helpCenter = AppRoute('/help', 'help-center');
  static const contactSupport = AppRoute('/support', 'contact-support');
  static const reportIssue = AppRoute('/report', 'report-issue');
  static const termsPrivacy = AppRoute('/legal/:type', 'terms-privacy');
  static const terms = AppRoute('/legal/terms', 'terms');
  static const privacy = AppRoute('/legal/privacy', 'privacy');
  static const about = AppRoute('/about', 'about');

  // Payment Details
  static const payoutDetail = AppRoute('/payout/:id', 'payout-detail');
}
