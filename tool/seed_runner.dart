// Firestore Seed Tool for SportConnect
// Run with: flutter run -t tool/seed_runner.dart
// JSON fixtures are bundled as Flutter assets and loaded via rootBundle (works on all platforms).

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/firebase_options.dart';

final random = Random();

// Collection names
const usersCollection = 'users';
const ridesCollection = 'rides';
const vehiclesCollection = 'vehicles';
const chatsCollection = 'chats';
const notificationsCollection = 'notifications';
const hotspotsCollection = 'hotspots';
const eventsCollection = 'events';
const rideRequestsCollection = 'rideRequests';
const bookingsCollection = 'bookings';
const reviewsCollection = 'reviews';
const paymentsCollection = 'payments';
const payoutsCollection = 'payouts';
const transactionsCollection = 'transactions';
const driverStatsCollection = 'driver_stats';
const disputesCollection = 'disputes';
const reportsCollection = 'reports';
const supportTicketsCollection = 'support_tickets';

// Seed configuration
const int numUsers = 20;
const int numRides = 30;
const int numVehicles = 15;
const int numChats = 10;
const int numHotspots = 12;
const int numEvents = 12;
const int numNotifications = 25;
const int numRideRequests = 20;
const int numBookings = 15;
const int numReviews = 20;
const int numPayments = 15;
const int numPayouts = 10;
const int numTransactions = 15;
const int numDriverStats = 10;
const int numDisputes = 8;
const int numReports = 8;
const int numSupportTickets = 8;

/// Path to JSON fixture files (relative to project root).
const String dataDir = 'tool/data';

/// Loads a JSON array from a fixture file bundled as a Flutter asset.
Future<List<Map<String, dynamic>>> loadFixture(String filename) async {
  final assetPath = '$dataDir/$filename';
  final content = await rootBundle.loadString(assetPath);
  final list = json.decode(content) as List<dynamic>;
  return list.cast<Map<String, dynamic>>();
}

/// Returns a copy of [raw] with all underscore-prefixed directive keys removed.
Map<String, dynamic> stripDirectives(Map<String, dynamic> raw) =>
    Map.fromEntries(raw.entries.where((e) => !e.key.startsWith('_')));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: SeedApp()));
}

class SeedApp extends StatelessWidget {
  const SeedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportConnect Seed Tool',
      theme: ThemeData.dark(),
      home: const SeedScreen(),
    );
  }
}

class SeedScreen extends StatefulWidget {
  const SeedScreen({super.key});

  @override
  State<SeedScreen> createState() => _SeedScreenState();
}

class _SeedScreenState extends State<SeedScreen> {
  final List<String> _logs = [];
  bool _isSeeding = false;
  List<String> _userIds = [];
  List<String> _rideIds = [];
  List<Map<String, dynamic>> _userFixtures = [];

  void _log(String message) {
    setState(() => _logs.add(message));
  }

  Future<void> _seedAll() async {
    if (_isSeeding) return;
    setState(() {
      _isSeeding = true;
      _logs.clear();
    });

    try {
      final firestore = FirebaseFirestore.instance;

      _log('🌱 Starting Firestore seed...\n');

      // _userIds and _userFixtures are populated by _seedUsers
      _userIds = [];
      _rideIds = [];
      _userFixtures = await loadFixture('users.json');

      await _seedUsers(firestore);
      await _seedVehicles(firestore);
      await _seedRides(firestore);
      await _seedChats(firestore);
      await _seedEvents(firestore);
      await _seedNotifications(firestore);
      await _seedHotspots(firestore);
      await _seedRideRequests(firestore);
      await _seedBookings(firestore);
      await _seedReviews(firestore);
      await _seedPayments(firestore);
      await _seedPayouts(firestore);
      await _seedTransactions(firestore);
      await _seedDriverStats(firestore);
      await _seedDisputes(firestore);
      await _seedReports(firestore);
      await _seedSupportTickets(firestore);

      _log('\n✅ All collections seeded successfully!');
    } catch (e) {
      _log('❌ Error: $e');
    }

    setState(() => _isSeeding = false);
  }

  Future<void> _clearAll() async {
    if (_isSeeding) return;
    setState(() {
      _isSeeding = true;
      _logs.clear();
    });

    try {
      final firestore = FirebaseFirestore.instance;

      await _clearAuthAccounts();

      _log('🗑️ Clearing all collections...\n');

      await _clearCollection(firestore, usersCollection);
      await _clearCollection(firestore, ridesCollection);
      await _clearCollection(firestore, vehiclesCollection);
      await _clearCollection(firestore, chatsCollection);
      await _clearCollection(firestore, notificationsCollection);
      await _clearCollection(firestore, eventsCollection);
      await _clearCollection(firestore, hotspotsCollection);
      await _clearCollection(firestore, rideRequestsCollection);
      await _clearCollection(firestore, bookingsCollection);
      await _clearCollection(firestore, reviewsCollection);
      await _clearCollection(firestore, paymentsCollection);
      await _clearCollection(firestore, payoutsCollection);
      await _clearCollection(firestore, transactionsCollection);
      await _clearCollection(firestore, driverStatsCollection);
      await _clearCollection(firestore, disputesCollection);
      await _clearCollection(firestore, reportsCollection);
      await _clearCollection(firestore, supportTicketsCollection);

      _log('\n✅ All collections cleared!');
    } catch (e) {
      _log('❌ Error: $e');
    }

    setState(() => _isSeeding = false);
  }

  Future<void> _clearAuthAccounts() async {
    _log('🔐 Clearing Firebase Auth accounts...');
    final auth = FirebaseAuth.instance;
    final fixtures = await loadFixture('users.json');
    int deleted = 0;
    int skipped = 0;

    for (final user in fixtures) {
      final email = user['email'] as String;
      final password = user['_password'] as String? ?? 'password';
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        await credential.user?.delete();
        deleted++;
      } on FirebaseAuthException catch (e) {
        // user-not-found means the account never existed — skip silently
        if (e.code != 'user-not-found') {
          _log('  ⚠️  Could not delete $email: ${e.code}');
        }
        skipped++;
      }
    }

    _log('  ✓ Deleted $deleted Auth accounts ($skipped not found / skipped)\n');
    await auth.signOut();
  }

  Future<void> _clearCollection(
    FirebaseFirestore firestore,
    String collection,
  ) async {
    _log('  Clearing $collection...');
    final docs = await firestore.collection(collection).limit(500).get();
    final batch = firestore.batch();
    for (final doc in docs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    _log('  ✓ Cleared ${docs.docs.length} documents');
  }

  // --------------------------------------------------------------------------
  // SEED USERS  (creates Firebase Auth accounts + Firestore docs)
  // --------------------------------------------------------------------------
  Future<void> _seedUsers(FirebaseFirestore firestore) async {
    _log('👥 Seeding $numUsers users (Firebase Auth + Firestore)...');

    final auth = FirebaseAuth.instance;
    final fixtures = _userFixtures;
    _userIds = [];
    final batch = firestore.batch();

    for (int i = 0; i < numUsers; i++) {
      final raw = fixtures[i % fixtures.length];
      final email = (raw['email'] as String?) ?? 'user$i@sportconnect.seed';
      final password = (raw['_password'] as String?) ?? 'Password123!';

      String uid;
      try {
        final cred = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        uid = cred.user!.uid;
        _log('  ✓ Created auth: $email');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Account exists from a previous seed run — sign in to get the UID
          final cred = await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          uid = cred.user!.uid;
          _log('  ↩ Reusing existing auth: $email');
        } else {
          _log('  ⚠️ Auth error for $email: $e');
          // Fallback: generate a Firestore doc ID so other collections don't break
          uid = firestore.collection(usersCollection).doc().id;
        }
      }

      _userIds.add(uid);

      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(365);
      final lastSeenMinutesAgo =
          (raw['_lastSeenMinutesAgo'] as int?) ?? random.nextInt(1440);

      final docRef = firestore.collection(usersCollection).doc(uid);
      final data = stripDirectives(raw)
        ..addAll({
          'uid': uid,
          'photoUrl': 'https://i.pravatar.cc/150?u=$uid',
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'lastSeenAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(minutes: lastSeenMinutesAgo)),
          ),
          'updatedAt': Timestamp.now(),
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    await FirebaseAuth.instance.signOut();
    _log('  ✓ Seeded $numUsers users (Auth + Firestore)');
  }

  // --------------------------------------------------------------------------
  // SEED VEHICLES  (data loaded from tool/data/vehicles.json)
  // --------------------------------------------------------------------------
  Future<void> _seedVehicles(FirebaseFirestore firestore) async {
    _log('🚗 Seeding $numVehicles vehicles...');

    final fixtures = await loadFixture('vehicles.json');
    final batch = firestore.batch();

    for (int i = 0; i < numVehicles; i++) {
      final raw = fixtures[i % fixtures.length];
      final docRef = firestore.collection(vehiclesCollection).doc();

      final ownerIndex =
          (raw['_ownerIndex'] as int?) ?? random.nextInt(_userIds.length);
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(180);

      final safeOwnerIndex = ownerIndex.clamp(0, _userIds.length - 1);
      final data = stripDirectives(raw)
        ..addAll({
          'id': docRef.id,
          'ownerId': _userIds[safeOwnerIndex],
          'ownerPhotoUrl':
              'https://i.pravatar.cc/150?u=${_userIds[safeOwnerIndex]}',
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'updatedAt': Timestamp.now(),
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numVehicles vehicles');
  }

  // --------------------------------------------------------------------------
  // SEED RIDES  (data loaded from tool/data/rides.json)
  // --------------------------------------------------------------------------
  Future<void> _seedRides(FirebaseFirestore firestore) async {
    _log('🚕 Seeding $numRides rides...');

    final fixtures = await loadFixture('rides.json');
    final batch = firestore.batch();

    for (int i = 0; i < numRides; i++) {
      final raw = fixtures[i % fixtures.length];
      final docRef = firestore.collection(ridesCollection).doc();

      final driverIndex =
          (raw['_driverIndex'] as int?) ?? random.nextInt(_userIds.length);
      final departureHoursFromNow =
          (raw['_departureHoursFromNow'] as int?) ?? (random.nextInt(72) + 1);
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(7);

      final safeDriverIndex = driverIndex.clamp(0, _userIds.length - 1);
      final departureTime = DateTime.now().add(
        Duration(hours: departureHoursFromNow),
      );

      final mutableRaw = Map<String, dynamic>.from(raw);
      final schedule = Map<String, dynamic>.from(
        (mutableRaw['schedule'] as Map<String, dynamic>?) ?? {},
      );
      schedule['departureTime'] = Timestamp.fromDate(departureTime);
      mutableRaw['schedule'] = schedule;

      final data = stripDirectives(mutableRaw)
        ..addAll({
          'id': docRef.id,
          'driverId': _userIds[safeDriverIndex],
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'updatedAt': Timestamp.now(),
        });

      batch.set(docRef, data);
      _rideIds.add(docRef.id);
    }

    await batch.commit();
    _log('  ✓ Created $numRides rides');
  }

  // --------------------------------------------------------------------------
  // SEED CHATS  (data loaded from tool/data/chats.json)
  // --------------------------------------------------------------------------
  Future<void> _seedChats(FirebaseFirestore firestore) async {
    _log('💬 Seeding $numChats chats...');

    final fixtures = await loadFixture('chats.json');
    final batch = firestore.batch();

    for (int i = 0; i < numChats; i++) {
      final raw = fixtures[i % fixtures.length];
      final docRef = firestore.collection(chatsCollection).doc();

      final participantIndices = (raw['_participantIndices'] as List<dynamic>)
          .cast<int>();
      final lastMessageSenderIndex =
          (raw['_lastMessageSenderIndex'] as int?) ?? 0;
      final lastMessageMinutesAgo =
          (raw['_lastMessageMinutesAgo'] as int?) ?? random.nextInt(1440);
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(30);

      final participantIds = participantIndices
          .map((idx) => _userIds[idx.clamp(0, _userIds.length - 1)])
          .toList();

      final safeSenderIndex = lastMessageSenderIndex.clamp(
        0,
        participantIndices.length - 1,
      );

      final participants = participantIndices.map((idx) {
        final safeIdx = idx.clamp(0, _userIds.length - 1);
        final uid = _userIds[safeIdx];
        final userRaw = _userFixtures[safeIdx % _userFixtures.length];
        final name =
            (userRaw['displayName'] as String?) ??
            (userRaw['name'] as String?) ??
            'User $safeIdx';
        return {
          'odid': uid,
          'displayName': name,
          'photoUrl': 'https://i.pravatar.cc/150?u=$uid',
          'isOnline': random.nextBool(),
          'isAdmin': false,
          'isMuted': false,
          'joinedAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'lastSeenAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(minutes: random.nextInt(1440))),
          ),
        };
      }).toList();

      final senderUserRaw =
          _userFixtures[participantIndices[safeSenderIndex].clamp(
                0,
                _userFixtures.length - 1,
              ) %
              _userFixtures.length];
      final lastMessageSenderName =
          (senderUserRaw['displayName'] as String?) ??
          (senderUserRaw['name'] as String?) ??
          'User';

      final data = stripDirectives(raw)
        ..addAll({
          'id': docRef.id,
          'participantIds': participantIds,
          'participants': participants,
          'lastMessageSenderId': participantIds[safeSenderIndex],
          'lastMessageSenderName': lastMessageSenderName,
          'lastMessageAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(minutes: lastMessageMinutesAgo)),
          ),
          'unreadCounts': {},
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'updatedAt': Timestamp.now(),
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numChats chats');
  }

  // --------------------------------------------------------------------------
  // SEED EVENTS  (data loaded from tool/data/events.json)
  // --------------------------------------------------------------------------
  Future<void> _seedEvents(FirebaseFirestore firestore) async {
    _log('🏅 Seeding $numEvents events...');

    final fixtures = await loadFixture('events.json');
    final batch = firestore.batch();

    for (int i = 0; i < numEvents && i < fixtures.length; i++) {
      final raw = fixtures[i];
      final docRef = firestore.collection(eventsCollection).doc();

      final creatorIndex =
          (raw['_creatorIndex'] as int?) ?? random.nextInt(_userIds.length);
      final participantIndices =
          (raw['_participantIndices'] as List<dynamic>?)?.cast<int>() ?? [];
      final startsAtHoursFromNow =
          (raw['_startsAtHoursFromNow'] as int?) ?? (random.nextInt(168) + 1);
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(14);

      final safeCreatorIndex = creatorIndex.clamp(0, _userIds.length - 1);
      final participantIds = participantIndices
          .map((idx) => _userIds[idx.clamp(0, _userIds.length - 1)])
          .toList();

      final data = stripDirectives(raw)
        ..addAll({
          'id': docRef.id,
          'creatorId': _userIds[safeCreatorIndex],
          'participantIds': participantIds,
          'startsAt': Timestamp.fromDate(
            DateTime.now().add(Duration(hours: startsAtHoursFromNow)),
          ),
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'updatedAt': Timestamp.now(),
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numEvents events');
  }

  // --------------------------------------------------------------------------
  // SEED NOTIFICATIONS  (data loaded from tool/data/notifications.json)
  // --------------------------------------------------------------------------
  Future<void> _seedNotifications(FirebaseFirestore firestore) async {
    _log('🔔 Seeding $numNotifications notifications...');

    final fixtures = await loadFixture('notifications.json');
    final batch = firestore.batch();

    for (int i = 0; i < numNotifications && i < fixtures.length; i++) {
      final raw = fixtures[i];
      final docRef = firestore.collection(notificationsCollection).doc();

      final userIndex =
          (raw['_userIndex'] as int?) ?? random.nextInt(_userIds.length);
      final senderIndex = raw['_senderIndex'] as int?;
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(7);

      final safeUserIndex = userIndex.clamp(0, _userIds.length - 1);

      final extra = <String, dynamic>{
        'id': docRef.id,
        'userId': _userIds[safeUserIndex],
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
        ),
      };
      if (senderIndex != null && senderIndex >= 0) {
        extra['senderId'] = _userIds[senderIndex.clamp(0, _userIds.length - 1)];
      }

      final data = stripDirectives(raw)..addAll(extra);
      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numNotifications notifications');
  }

  // --------------------------------------------------------------------------
  // SEED HOTSPOTS  (data loaded from tool/data/hotspots.json)
  // --------------------------------------------------------------------------
  Future<void> _seedHotspots(FirebaseFirestore firestore) async {
    _log('📍 Seeding hotspots...');

    final fixtures = await loadFixture('hotspots.json');
    final batch = firestore.batch();

    for (int i = 0; i < numHotspots && i < fixtures.length; i++) {
      final raw = fixtures[i];
      final docRef = firestore.collection(hotspotsCollection).doc();

      final data = Map<String, dynamic>.from(raw)
        ..addAll({'id': docRef.id, 'createdAt': Timestamp.now()});

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created ${fixtures.take(numHotspots).length} hotspots');
  }

  // --------------------------------------------------------------------------
  // SEED RIDE REQUESTS  (data loaded from tool/data/rideRequests.json)
  // --------------------------------------------------------------------------
  Future<void> _seedRideRequests(FirebaseFirestore firestore) async {
    _log('📋 Seeding $numRideRequests ride requests...');

    final fixtures = await loadFixture('rideRequests.json');
    final batch = firestore.batch();

    for (int i = 0; i < numRideRequests; i++) {
      final raw = fixtures[i % fixtures.length];
      final docRef = firestore.collection(rideRequestsCollection).doc();

      final requesterIndex =
          (raw['_requesterIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final driverIndex =
          (raw['_driverIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(7);
      final rideId = _rideIds.isNotEmpty
          ? _rideIds[i % _rideIds.length]
          : docRef.id;

      final data = stripDirectives(raw)
        ..addAll({
          'id': docRef.id,
          'rideId': rideId,
          'requesterId': _userIds[requesterIndex],
          'driverId': _userIds[driverIndex],
          'passengerPhotoUrl':
              'https://i.pravatar.cc/150?u=${_userIds[requesterIndex]}',
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'updatedAt': Timestamp.now(),
          'expiresAt': Timestamp.fromDate(
            DateTime.now()
                .subtract(Duration(days: createdAtDaysAgo))
                .add(const Duration(hours: 24)),
          ),
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numRideRequests ride requests');
  }

  // --------------------------------------------------------------------------
  // SEED BOOKINGS  (data loaded from tool/data/bookings.json)
  // --------------------------------------------------------------------------
  Future<void> _seedBookings(FirebaseFirestore firestore) async {
    _log('🎫 Seeding $numBookings bookings...');

    final fixtures = await loadFixture('bookings.json');
    final batch = firestore.batch();

    for (int i = 0; i < numBookings; i++) {
      final raw = fixtures[i % fixtures.length];
      final docRef = firestore.collection(bookingsCollection).doc();

      final passengerIndex =
          (raw['_passengerIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(7);
      final rideId = _rideIds.isNotEmpty
          ? _rideIds[i % _rideIds.length]
          : docRef.id;

      final data = stripDirectives(raw)
        ..addAll({
          'id': docRef.id,
          'rideId': rideId,
          'passengerId': _userIds[passengerIndex],
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'respondedAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo - 0)),
          ),
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numBookings bookings');
  }

  // --------------------------------------------------------------------------
  // SEED REVIEWS  (data loaded from tool/data/reviews.json)
  // --------------------------------------------------------------------------
  Future<void> _seedReviews(FirebaseFirestore firestore) async {
    _log('⭐ Seeding $numReviews reviews...');

    final fixtures = await loadFixture('reviews.json');
    final batch = firestore.batch();

    for (int i = 0; i < numReviews && i < fixtures.length; i++) {
      final raw = fixtures[i];
      final docRef = firestore.collection(reviewsCollection).doc();

      final reviewerIndex =
          (raw['_reviewerIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final revieweeIndex =
          (raw['_revieweeIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(30);
      final rideId = _rideIds.isNotEmpty
          ? _rideIds[i % _rideIds.length]
          : docRef.id;

      final reviewerRaw = _userFixtures[reviewerIndex % _userFixtures.length];
      final revieweeRaw = _userFixtures[revieweeIndex % _userFixtures.length];
      final reviewerName = (reviewerRaw['displayName'] as String?) ?? 'User';
      final revieweeName = (revieweeRaw['displayName'] as String?) ?? 'User';

      final data = stripDirectives(raw)
        ..addAll({
          'id': docRef.id,
          'rideId': rideId,
          'reviewerId': _userIds[reviewerIndex],
          'reviewerName': reviewerName,
          'reviewerPhotoUrl':
              'https://i.pravatar.cc/150?u=${_userIds[reviewerIndex]}',
          'revieweeId': _userIds[revieweeIndex],
          'revieweeName': revieweeName,
          'revieweePhotoUrl':
              'https://i.pravatar.cc/150?u=${_userIds[revieweeIndex]}',
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'updatedAt': Timestamp.now(),
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numReviews reviews');
  }

  // --------------------------------------------------------------------------
  // SEED PAYMENTS  (data loaded from tool/data/payments.json)
  // --------------------------------------------------------------------------
  Future<void> _seedPayments(FirebaseFirestore firestore) async {
    _log('💳 Seeding $numPayments payments...');

    final fixtures = await loadFixture('payments.json');
    final batch = firestore.batch();

    for (int i = 0; i < numPayments && i < fixtures.length; i++) {
      final raw = fixtures[i];
      final docRef = firestore.collection(paymentsCollection).doc();

      final riderIndex =
          (raw['_riderIndex'] as int? ?? random.nextInt(_userIds.length)).clamp(
            0,
            _userIds.length - 1,
          );
      final driverIndex =
          (raw['_driverIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(30);
      final rideId = _rideIds.isNotEmpty
          ? _rideIds[i % _rideIds.length]
          : docRef.id;

      final riderRaw = _userFixtures[riderIndex % _userFixtures.length];
      final driverRaw = _userFixtures[driverIndex % _userFixtures.length];

      final data = stripDirectives(raw)
        ..addAll({
          'id': docRef.id,
          'rideId': rideId,
          'riderId': _userIds[riderIndex],
          'riderName': (riderRaw['displayName'] as String?) ?? 'Rider',
          'driverId': _userIds[driverIndex],
          'driverName': (driverRaw['displayName'] as String?) ?? 'Driver',
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'updatedAt': Timestamp.now(),
          'completedAt': (raw['status'] as String?) == 'succeeded'
              ? Timestamp.fromDate(
                  DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
                )
              : null,
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numPayments payments');
  }

  // --------------------------------------------------------------------------
  // SEED PAYOUTS  (data loaded from tool/data/payouts.json)
  // --------------------------------------------------------------------------
  Future<void> _seedPayouts(FirebaseFirestore firestore) async {
    _log('💰 Seeding $numPayouts payouts...');

    final fixtures = await loadFixture('payouts.json');
    final batch = firestore.batch();

    for (int i = 0; i < numPayouts && i < fixtures.length; i++) {
      final raw = fixtures[i];
      final docRef = firestore.collection(payoutsCollection).doc();

      final driverIndex =
          (raw['_driverIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(14);

      final data = stripDirectives(raw)
        ..addAll({
          'id': docRef.id,
          'driverId': _userIds[driverIndex],
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'updatedAt': Timestamp.now(),
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numPayouts payouts');
  }

  // --------------------------------------------------------------------------
  // SEED TRANSACTIONS  (data loaded from tool/data/transactions.json)
  // --------------------------------------------------------------------------
  Future<void> _seedTransactions(FirebaseFirestore firestore) async {
    _log('🧾 Seeding $numTransactions transactions...');

    final fixtures = await loadFixture('transactions.json');
    final batch = firestore.batch();

    for (int i = 0; i < numTransactions && i < fixtures.length; i++) {
      final raw = fixtures[i];
      final docRef = firestore.collection(transactionsCollection).doc();

      final driverIndex =
          (raw['_driverIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(14);
      final rideId = _rideIds.isNotEmpty
          ? _rideIds[i % _rideIds.length]
          : docRef.id;

      final data = stripDirectives(raw)
        ..addAll({
          'id': docRef.id,
          'driverId': _userIds[driverIndex],
          'rideId': rideId,
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numTransactions transactions');
  }

  // --------------------------------------------------------------------------
  // SEED DRIVER STATS  (data loaded from tool/data/driverStats.json)
  // --------------------------------------------------------------------------
  Future<void> _seedDriverStats(FirebaseFirestore firestore) async {
    _log('📊 Seeding $numDriverStats driver stats...');

    final fixtures = await loadFixture('driverStats.json');
    final batch = firestore.batch();

    for (int i = 0; i < numDriverStats && i < fixtures.length; i++) {
      final raw = fixtures[i];
      final driverIndex =
          (raw['_driverIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final driverId = _userIds[driverIndex];
      // Use driverId as doc ID so it can be fetched by driver easily
      final docRef = firestore.collection(driverStatsCollection).doc(driverId);

      final data = stripDirectives(raw)
        ..addAll({
          'driverId': driverId,
          'lastRideAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 12)),
          ),
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numDriverStats driver stats records');
  }

  // --------------------------------------------------------------------------
  // SEED DISPUTES  (data loaded from tool/data/disputes.json)
  // --------------------------------------------------------------------------
  Future<void> _seedDisputes(FirebaseFirestore firestore) async {
    _log('⚖️ Seeding $numDisputes disputes...');

    final fixtures = await loadFixture('disputes.json');
    final batch = firestore.batch();

    for (int i = 0; i < numDisputes && i < fixtures.length; i++) {
      final raw = fixtures[i];
      final docRef = firestore.collection(disputesCollection).doc();

      final complainantIndex =
          (raw['_complainantIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final respondentIndex =
          (raw['_respondentIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(14);
      final rideId = _rideIds.isNotEmpty
          ? _rideIds[i % _rideIds.length]
          : docRef.id;

      final compRaw = _userFixtures[complainantIndex % _userFixtures.length];
      final respRaw = _userFixtures[respondentIndex % _userFixtures.length];

      final data = stripDirectives(raw)
        ..addAll({
          'id': docRef.id,
          'rideId': rideId,
          'complainantId': _userIds[complainantIndex],
          'complainantName': (compRaw['displayName'] as String?) ?? 'User',
          'respondentId': _userIds[respondentIndex],
          'respondentName': (respRaw['displayName'] as String?) ?? 'User',
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'updatedAt': Timestamp.now(),
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numDisputes disputes');
  }

  // --------------------------------------------------------------------------
  // SEED REPORTS  (data loaded from tool/data/reports.json)
  // --------------------------------------------------------------------------
  Future<void> _seedReports(FirebaseFirestore firestore) async {
    _log('🚨 Seeding $numReports reports...');

    final fixtures = await loadFixture('reports.json');
    final batch = firestore.batch();

    for (int i = 0; i < numReports && i < fixtures.length; i++) {
      final raw = fixtures[i];
      final docRef = firestore.collection(reportsCollection).doc();

      final reporterIndex =
          (raw['_reporterIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final reportedIndex =
          (raw['_reportedUserIndex'] as int? ?? random.nextInt(_userIds.length))
              .clamp(0, _userIds.length - 1);
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(14);

      final reporterRaw = _userFixtures[reporterIndex % _userFixtures.length];
      final reportedRaw = _userFixtures[reportedIndex % _userFixtures.length];

      final data = stripDirectives(raw)
        ..addAll({
          'id': docRef.id,
          'reporterId': _userIds[reporterIndex],
          'reporterName': (reporterRaw['displayName'] as String?) ?? 'User',
          'reportedUserId': _userIds[reportedIndex],
          'reportedUserName': (reportedRaw['displayName'] as String?) ?? 'User',
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'updatedAt': Timestamp.now(),
          'resolvedAt': (raw['isResolved'] as bool? ?? false)
              ? Timestamp.fromDate(
                  DateTime.now().subtract(Duration(days: createdAtDaysAgo - 1)),
                )
              : null,
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numReports reports');
  }

  // --------------------------------------------------------------------------
  // SEED SUPPORT TICKETS  (data loaded from tool/data/supportTickets.json)
  // --------------------------------------------------------------------------
  Future<void> _seedSupportTickets(FirebaseFirestore firestore) async {
    _log('🎫 Seeding $numSupportTickets support tickets...');

    final fixtures = await loadFixture('supportTickets.json');
    final batch = firestore.batch();

    for (int i = 0; i < numSupportTickets && i < fixtures.length; i++) {
      final raw = fixtures[i];
      final docRef = firestore.collection(supportTicketsCollection).doc();

      final userIndex =
          (raw['_userIndex'] as int? ?? random.nextInt(_userIds.length)).clamp(
            0,
            _userIds.length - 1,
          );
      final createdAtDaysAgo =
          (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(14);

      final userRaw = _userFixtures[userIndex % _userFixtures.length];

      final data = stripDirectives(raw)
        ..addAll({
          'id': docRef.id,
          'userId': _userIds[userIndex],
          'userName': (userRaw['displayName'] as String?) ?? 'User',
          'userEmail': (userRaw['email'] as String?) ?? '',
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
          ),
          'updatedAt': Timestamp.now(),
          'resolvedAt': (raw['status'] as String?) == 'resolved'
              ? Timestamp.fromDate(
                  DateTime.now().subtract(Duration(days: createdAtDaysAgo - 1)),
                )
              : null,
        });

      batch.set(docRef, data);
    }

    await batch.commit();
    _log('  ✓ Created $numSupportTickets support tickets');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 SportConnect Seed Tool'),
        backgroundColor: Colors.green.shade800,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSeeding ? null : _seedAll,
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Seed All Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSeeding ? null : _clearAll,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear All Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSeeding
                        ? null
                        : () async {
                            setState(() {
                              _isSeeding = true;
                              _logs.clear();
                            });
                            try {
                              final firestore = FirebaseFirestore.instance;
                              _userFixtures = await loadFixture('users.json');
                              await _seedEvents(firestore);
                            } catch (e) {
                              _log('❌ Error: $e');
                            }
                            setState(() => _isSeeding = false);
                          },
                    icon: const Icon(Icons.sports),
                    label: const Text('Seed Events'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSeeding
                        ? null
                        : () async {
                            setState(() {
                              _isSeeding = true;
                              _logs.clear();
                            });
                            try {
                              final firestore = FirebaseFirestore.instance;
                              _userFixtures = await loadFixture('users.json');
                              await _seedNotifications(firestore);
                            } catch (e) {
                              _log('❌ Error: $e');
                            }
                            setState(() => _isSeeding = false);
                          },
                    icon: const Icon(Icons.notifications),
                    label: const Text('Seed Notifications'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSeeding) const LinearProgressIndicator(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) => Text(
                  _logs[index],
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
