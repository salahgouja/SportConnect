import 'package:flutter_test/flutter_test.dart';
import 'package:sport_connect/core/interfaces/services/i_firebase_service.dart';
import 'package:sport_connect/core/services/firebase_service_impl.dart';

void main() {
  group('FirebaseServiceImpl', () {
    late IFirebaseService firebaseService;

    setUp(() {
      firebaseService = FirebaseServiceImpl.instance;
    });

    group('Singleton Pattern', () {
      test('should return same instance on multiple calls', () {
        final instance1 = FirebaseServiceImpl.instance;
        final instance2 = FirebaseServiceImpl.instance;
        final instance3 = FirebaseServiceImpl.instance;

        expect(instance1, equals(instance2));
        expect(instance2, equals(instance3));
        expect(instance1, same(instance2));
      });

      test('should maintain state across instance calls', () {
        final instance1 = FirebaseServiceImpl.instance;
        final useEmulators1 = instance1.useEmulators;

        final instance2 = FirebaseServiceImpl.instance;
        final useEmulators2 = instance2.useEmulators;

        expect(useEmulators1, equals(useEmulators2));
      });
    });

    group('Interface Implementation', () {
      test('should implement IFirebaseService interface', () {
        expect(firebaseService, isA<IFirebaseService>());
      });

      test('should expose all required interface properties', () {
        expect(() => firebaseService.auth, returnsNormally);
        expect(() => firebaseService.firestore, returnsNormally);
        expect(() => firebaseService.storage, returnsNormally);
        expect(() => firebaseService.messaging, returnsNormally);
        expect(() => firebaseService.currentUser, returnsNormally);
        expect(() => firebaseService.authStateChanges, returnsNormally);
        expect(() => firebaseService.useEmulators, returnsNormally);
        expect(() => firebaseService.usersCollection, returnsNormally);
      });
    });

    group('Properties', () {
      test('should have non-null Firebase instances', () {
        expect(firebaseService.auth, isNotNull);
        expect(firebaseService.firestore, isNotNull);
        expect(firebaseService.storage, isNotNull);
        expect(firebaseService.messaging, isNotNull);
      });

      test('should have useEmulators as boolean', () {
        expect(firebaseService.useEmulators, isA<bool>());
      });

      test('should have authStateChanges as stream', () {
        expect(firebaseService.authStateChanges, isA<Stream>());
      });

      test('should provide usersCollection reference', () {
        final collection = firebaseService.usersCollection;
        expect(collection, isNotNull);
        expect(collection.path, equals('users'));
      });
    });

    group('Firestore Helper Methods', () {
      test('getUserDoc should return document reference with correct path', () {
        const userId = 'test_user_123';

        final docRef = firebaseService.getUserDoc(userId);

        expect(docRef, isNotNull);
        expect(docRef.path, equals('users/test_user_123'));
      });

      test('getUserDoc should handle different user ID formats', () {
        const userId1 = 'uid-with-dashes';
        const userId2 = 'uid_with_underscores';
        const userId3 = 'simpleuid123';

        expect(
          firebaseService.getUserDoc(userId1).path,
          equals('users/uid-with-dashes'),
        );
        expect(
          firebaseService.getUserDoc(userId2).path,
          equals('users/uid_with_underscores'),
        );
        expect(
          firebaseService.getUserDoc(userId3).path,
          equals('users/simpleuid123'),
        );
      });

      test('usersCollection should return collection with correct path', () {
        final collection = firebaseService.usersCollection;

        expect(collection.path, equals('users'));
      });
    });

    group('Authentication State', () {
      test('currentUser should be null when not authenticated', () {
        // Note: This test assumes no user is logged in during test execution
        // In a real scenario, you'd mock FirebaseAuth
        expect(firebaseService.currentUser, isNull);
      });

      test(
        'authStateChanges should emit stream of auth state changes',
        () async {
          // Note: This test requires proper Firebase initialization
          // It should emit null initially when no user is logged in
          final stream = firebaseService.authStateChanges;

          expect(stream, isA<Stream>());

          // Listen to first event
          final firstEvent = await stream.first;
          expect(firstEvent, isNull); // Should be null when not authenticated
        },
      );
    });

    group('Emulator Configuration', () {
      test('useEmulators should return configuration value', () {
        final useEmulators = firebaseService.useEmulators;
        expect(useEmulators, isA<bool>());
      });

      test('connectToEmulators should complete without error', () async {
        // Note: This test may fail if emulators are not running
        // In production tests, you'd mock the AppConfig
        expect(() => firebaseService.connectToEmulators(), returnsNormally);
      });
    });

    group('Initialization', () {
      test('initialize should be callable', () {
        expect(() => firebaseService.initialize(), returnsNormally);
      });

      // Note: Actual initialization tests require Firebase to be properly set up
      // These tests would typically be integration tests, not unit tests
    });

    group('Error Handling', () {
      test('getUserDoc should handle empty user ID gracefully', () {
        final docRef = firebaseService.getUserDoc('');
        expect(docRef.path, equals('users/'));
      });

      test(
        'should not throw when accessing properties without initialization',
        () {
          // Firebase services are lazy-initialized
          expect(() => firebaseService.auth, returnsNormally);
          expect(() => firebaseService.firestore, returnsNormally);
          expect(() => firebaseService.storage, returnsNormally);
        },
      );
    });

    group('Type Safety', () {
      test('should return correctly typed Firebase instances', () {
        expect(
          firebaseService.auth.runtimeType.toString(),
          contains('FirebaseAuth'),
        );
        expect(
          firebaseService.firestore.runtimeType.toString(),
          contains('FirebaseFirestore'),
        );
        expect(
          firebaseService.storage.runtimeType.toString(),
          contains('FirebaseStorage'),
        );
        expect(
          firebaseService.messaging.runtimeType.toString(),
          contains('FirebaseMessaging'),
        );
      });
    });
  });

  group('Integration with Interface', () {
    test('should be usable as IFirebaseService type', () {
      IFirebaseService service = FirebaseServiceImpl.instance;

      expect(service.auth, isNotNull);
      expect(service.firestore, isNotNull);
      expect(service.getUserDoc('test'), isNotNull);
    });

    test('should support interface polymorphism', () {
      void acceptsInterface(IFirebaseService service) {
        expect(service, isNotNull);
      }

      expect(
        () => acceptsInterface(FirebaseServiceImpl.instance),
        returnsNormally,
      );
    });
  });
}
