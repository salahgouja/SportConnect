import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/interfaces/services/i_firebase_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/firebase_options.dart';
import 'package:sport_connect/core/config/app_config.dart';

part 'firebase_service_impl.g.dart';

/// Injectable Firebase service implementation
class FirebaseServiceImpl implements IFirebaseService {
  FirebaseServiceImpl._();

  static FirebaseServiceImpl? _instance;
  static FirebaseServiceImpl get instance {
    _instance ??= FirebaseServiceImpl._();
    return _instance!;
  }

  @override
  FirebaseAuth get auth => FirebaseAuth.instance;

  @override
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @override
  FirebaseStorage get storage => FirebaseStorage.instance;

  @override
  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  @override
  User? get currentUser => auth.currentUser;

  @override
  Stream<User?> get authStateChanges => auth.authStateChanges();

  @override
  bool get useEmulators => AppConfig.useEmulators;

  @override
  DocumentReference<Map<String, dynamic>> getUserDoc(String uid) {
    return firestore.collection('users').doc(uid);
  }

  @override
  CollectionReference<Map<String, dynamic>> get usersCollection {
    return firestore.collection('users');
  }

  @override
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      TalkerService.info('Firebase initialized successfully');
      TalkerService.info('Environment: ${AppConfig.environmentStatus}');

      if (AppConfig.useEmulators) {
        await connectToEmulators();
      }

      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      await _requestNotificationPermissions();
    } catch (e, stackTrace) {
      TalkerService.error('Firebase initialization failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> connectToEmulators() async {
    final host = AppConfig.emulatorHost;

    try {
      await auth.useAuthEmulator(host, AppConfig.authEmulatorPort);
      TalkerService.info(
        'Connected to Auth emulator at $host:${AppConfig.authEmulatorPort}',
      );

      firestore.useFirestoreEmulator(host, AppConfig.firestoreEmulatorPort);
      TalkerService.info(
        'Connected to Firestore emulator at $host:${AppConfig.firestoreEmulatorPort}',
      );

      await storage.useStorageEmulator(host, AppConfig.storageEmulatorPort);
      TalkerService.info(
        'Connected to Storage emulator at $host:${AppConfig.storageEmulatorPort}',
      );

      TalkerService.info('🔧 All Firebase emulators connected successfully!');
    } catch (e) {
      TalkerService.error('Failed to connect to emulators', e);
      TalkerService.warning('Falling back to production Firebase services');
    }
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      TalkerService.info(
        'Notification permission status: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await messaging.getToken();
        TalkerService.info('FCM Token: $token');
      }
    } catch (e) {
      TalkerService.warning('Failed to request notification permissions $e');
    }
  }
}

/// Riverpod provider for Firebase service
@riverpod
IFirebaseService firebaseService(Ref ref) {
  return FirebaseServiceImpl.instance;
}
