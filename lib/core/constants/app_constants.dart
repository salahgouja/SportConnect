/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'SportConnect';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String ridesCollection = 'rides';
  static const String eventsCollection = 'events';
  static const String messagesCollection = 'messages';
  static const String conversationsCollection = 'conversations';
  static const String chatsCollection = 'chats';
  static const String notificationsCollection = 'notifications';
  static const String vehiclesCollection = 'vehicles';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String chatImagesPath = 'chat_images';
  static const String vehicleImagesPath = 'vehicle_images';

  // Pagination
  static const int pageSize = 20;
  static const int maxSearchRadius = 50; // km

  // Map Settings
  static const double defaultZoom = 13.0;
  static const double minZoom = 3.0;
  static const double maxZoom = 18.0;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration locationTimeout = Duration(seconds: 10);
}
