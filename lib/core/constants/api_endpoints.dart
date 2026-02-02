/// API endpoints (if using custom backend alongside Firebase)
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Update when you have a backend
  static const String baseUrl = 'https://api.sportconnect.com/v1';

  // Auth (if using custom auth)
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';

  // Optional: Routes API for carpooling calculations
  static const String calculateRoute = '/routes/calculate';
  static const String geocode = '/geocode';
}
