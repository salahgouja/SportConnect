import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/services/i_firebase_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/firebase_options.dart';
import 'package:sport_connect/core/config/app_config.dart';
import 'package:sport_connect/features/auth/models/models.dart';

part 'firebase_service.g.dart';

/// Injectable Firebase service implementation
class FirebaseService implements IFirebaseService {
  FirebaseService._();

  static FirebaseService? _instance;
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
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
  CollectionReference<UserModel> get usersCollection {
    return firestore
        .collection(AppConstants.usersCollection)
        .withConverter<UserModel>(
          fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
          toFirestore: (user, _) => user.toJson(),
        );
  }

  @override
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // await FirebaseAppCheck.instance.activate(
      //   androidProvider:
      //       kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      //   appleProvider:
      //       kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
      // );
      TalkerService.info('Firebase initialized successfully');
      TalkerService.info('Environment: ${AppConfig.environmentStatus}');

      if (useEmulators) {
        await connectToEmulators();
      }

      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Notification permissions are now requested from the UI layer
      // after showing a rationale dialog (2025 store compliance).
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
}

/// Riverpod provider for Firebase service
@riverpod
IFirebaseService firebaseService(Ref ref) {
  return FirebaseService.instance;
}
