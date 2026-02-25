// Firestore Seed Tool for SportConnect
// Run with: dart run tool/seed.dart
// Options:
//   --clear          Clear all data before seeding
//   --users / -u     Seed users collection
//   --rides / -r     Seed rides collection
//   --vehicles / -v  Seed vehicles collection
//   --chats          Seed chats collection
//   --hotspots / -h  Seed hotspots collection
//   --events / -e    Seed events collection
//   --notifications / -n  Seed notifications collection
//   --all / -a       Seed all collections (default)

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sport_connect/firebase_options.dart';

final random = Random();

/// Path to JSON fixture files (relative to project root).
const String dataDir = 'tool/data';

/// Loads a JSON array from a fixture file.
Future<List<Map<String, dynamic>>> loadFixture(String filename) async {
  final file = File('$dataDir/$filename');
  if (!file.existsSync()) {
    throw FileSystemException('Fixture file not found', file.path);
  }
  final content = await file.readAsString();
  final list = json.decode(content) as List<dynamic>;
  return list.cast<Map<String, dynamic>>();
}

/// Returns a copy of [raw] with all underscore-prefixed directive keys removed.
Map<String, dynamic> stripDirectives(Map<String, dynamic> raw) =>
    Map.fromEntries(raw.entries.where((e) => !e.key.startsWith('_')));

// Collection names
const usersCollection = 'users';
const ridesCollection = 'rides';
const vehiclesCollection = 'vehicles';
const chatsCollection = 'chats';
const notificationsCollection = 'notifications';
const hotspotsCollection = 'hotspots';
const eventsCollection = 'events';

// Seed counts
const int numUsers = 20;
const int numRides = 30;
const int numVehicles = 15;
const int numChats = 10;
const int numHotspots = 12;
const int numEvents = 12;
const int numNotifications = 25;

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('clear', abbr: 'c', help: 'Clear all data before seeding')
    ..addFlag('users', abbr: 'u', help: 'Seed users collection')
    ..addFlag('rides', abbr: 'r', help: 'Seed rides collection')
    ..addFlag('vehicles', abbr: 'v', help: 'Seed vehicles collection')
    ..addFlag('chats', help: 'Seed chats collection')
    ..addFlag('hotspots', abbr: 'h', help: 'Seed hotspots collection')
    ..addFlag('events', abbr: 'e', help: 'Seed events collection')
    ..addFlag('notifications', abbr: 'n', help: 'Seed notifications collection')
    ..addFlag('all', abbr: 'a', help: 'Seed all collections (default)')
    ..addFlag('help', help: 'Show usage');

  final results = parser.parse(arguments);

  if (results['help'] as bool) {
    print('SportConnect Firestore Seed Tool\n');
    print('Usage: dart run tool/seed.dart [options]\n');
    print(parser.usage);
    exit(0);
  }

  print('🌱 SportConnect Firestore Seed Tool\n');
  print('═══════════════════════════════════════\n');

  print('🔥 Initializing Firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;
  print('✅ Firebase initialized\n');

  final seedAll =
      results['all'] as bool ||
      (!results['users'] &&
          !results['rides'] &&
          !results['vehicles'] &&
          !results['chats'] &&
          !results['hotspots'] &&
          !results['events'] &&
          !results['notifications']);

  final shouldClear = results['clear'] as bool;

  if (shouldClear) {
    print('🗑️  Clearing existing data...\n');
    for (final col in [
      usersCollection,
      ridesCollection,
      vehiclesCollection,
      chatsCollection,
      notificationsCollection,
      hotspotsCollection,
      eventsCollection,
    ]) {
      await clearCollection(firestore, col);
    }
    print('✅ Data cleared\n');
  }

  // Generate stable document IDs for users (referenced by other collections)
  final userIds = List.generate(
    numUsers,
    (_) => firestore.collection(usersCollection).doc().id,
  );

  // Load user fixtures once – reused by chats & events for display names
  final userFixtures = await loadFixture('users.json');

  if (seedAll || results['users'] as bool) {
    await seedUsers(firestore, userIds);
  }
  if (seedAll || results['vehicles'] as bool) {
    await seedVehicles(firestore, userIds);
  }
  if (seedAll || results['rides'] as bool) {
    await seedRides(firestore, userIds);
  }
  if (seedAll || results['chats'] as bool) {
    await seedChats(firestore, userIds, userFixtures);
  }
  if (seedAll || results['hotspots'] as bool) {
    await seedHotspots(firestore);
  }
  if (seedAll || results['events'] as bool) {
    await seedEvents(firestore, userIds, userFixtures);
  }
  if (seedAll || results['notifications'] as bool) {
    await seedNotifications(firestore, userIds);
  }

  print('\n═══════════════════════════════════════');
  print('🎉 Seeding complete!\n');
  exit(0);
}

Future<void> clearCollection(
  FirebaseFirestore firestore,
  String collection,
) async {
  stdout.write('  Clearing $collection... ');
  final docs = await firestore.collection(collection).limit(500).get();
  final batch = firestore.batch();
  for (final doc in docs.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();
  print('✓');
}

// ============================================================================
// SEED USERS
// ============================================================================
Future<void> seedUsers(
  FirebaseFirestore firestore,
  List<String> userIds,
) async {
  print('👥 Seeding users ($numUsers)...');
  final fixtures = await loadFixture('users.json');
  final batch = firestore.batch();

  for (int i = 0; i < numUsers; i++) {
    final raw = fixtures[i % fixtures.length];
    final docRef = firestore.collection(usersCollection).doc(userIds[i]);
    final createdAtDaysAgo =
        (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(365);
    final lastSeenMinutesAgo =
        (raw['_lastSeenMinutesAgo'] as int?) ?? random.nextInt(1440);

    final data = stripDirectives(raw)
      ..addAll({
        'uid': userIds[i],
        'photoUrl': 'https://i.pravatar.cc/150?u=${userIds[i]}',
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
        ),
        'updatedAt': Timestamp.now(),
        'lastSeenAt': Timestamp.fromDate(
          DateTime.now().subtract(Duration(minutes: lastSeenMinutesAgo)),
        ),
      });

    batch.set(docRef, data);
    stdout.write('\r  Progress: ${i + 1}/$numUsers');
  }

  await batch.commit();
  print('\n✅ Users seeded\n');
}

// ============================================================================
// SEED VEHICLES
// ============================================================================
Future<void> seedVehicles(
  FirebaseFirestore firestore,
  List<String> userIds,
) async {
  print('🚗 Seeding vehicles ($numVehicles)...');
  final fixtures = await loadFixture('vehicles.json');
  final batch = firestore.batch();

  for (int i = 0; i < numVehicles; i++) {
    final raw = fixtures[i % fixtures.length];
    final docRef = firestore.collection(vehiclesCollection).doc();
    final ownerIndex =
        (raw['_ownerIndex'] as int?) ?? random.nextInt(userIds.length);
    final createdAtDaysAgo =
        (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(180);
    final safeOwnerIndex = ownerIndex.clamp(0, userIds.length - 1);

    final data = stripDirectives(raw)
      ..addAll({
        'id': docRef.id,
        'ownerId': userIds[safeOwnerIndex],
        'ownerPhotoUrl':
            'https://i.pravatar.cc/150?u=${userIds[safeOwnerIndex]}',
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
        ),
        'updatedAt': Timestamp.now(),
      });

    batch.set(docRef, data);
    stdout.write('\r  Progress: ${i + 1}/$numVehicles');
  }

  await batch.commit();
  print('\n✅ Vehicles seeded\n');
}

// ============================================================================
// SEED RIDES
// ============================================================================
Future<void> seedRides(
  FirebaseFirestore firestore,
  List<String> userIds,
) async {
  print('🚕 Seeding rides ($numRides)...');
  final fixtures = await loadFixture('rides.json');
  final batch = firestore.batch();

  for (int i = 0; i < numRides; i++) {
    final raw = fixtures[i % fixtures.length];
    final docRef = firestore.collection(ridesCollection).doc();
    final driverIndex =
        (raw['_driverIndex'] as int?) ?? random.nextInt(userIds.length);
    final departureHoursFromNow =
        (raw['_departureHoursFromNow'] as int?) ?? (random.nextInt(72) + 1);
    final createdAtDaysAgo =
        (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(7);

    final safeDriverIndex = driverIndex.clamp(0, userIds.length - 1);
    final departureTime = DateTime.now().add(
      Duration(hours: departureHoursFromNow),
    );

    final data = stripDirectives(raw);

    // Inject departureTime into the nested schedule sub-model
    final schedule = Map<String, dynamic>.from(
      (data['schedule'] as Map<String, dynamic>?) ?? {},
    );
    schedule['departureTime'] = Timestamp.fromDate(departureTime);
    data['schedule'] = schedule;

    data.addAll({
      'id': docRef.id,
      'driverId': userIds[safeDriverIndex],
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
      ),
      'updatedAt': Timestamp.now(),
    });

    batch.set(docRef, data);
    stdout.write('\r  Progress: ${i + 1}/$numRides');
  }

  await batch.commit();
  print('\n✅ Rides seeded\n');
}

// ============================================================================
// SEED CHATS
// ============================================================================
Future<void> seedChats(
  FirebaseFirestore firestore,
  List<String> userIds,
  List<Map<String, dynamic>> userFixtures,
) async {
  print('💬 Seeding chats ($numChats)...');
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
        .map((idx) => userIds[idx.clamp(0, userIds.length - 1)])
        .toList();

    // Build ChatParticipant objects (field is 'odid', not 'uid')
    final participants = participantIndices.asMap().entries.map((entry) {
      final listPos = entry.key;
      final idx = entry.value.clamp(0, userIds.length - 1);
      final userFix = userFixtures[idx.clamp(0, userFixtures.length - 1)];
      return <String, dynamic>{
        'odid': userIds[idx],
        'displayName': userFix['displayName'] as String? ?? 'User $idx',
        'photoUrl': 'https://i.pravatar.cc/150?u=${userIds[idx]}',
        'isOnline': userFix['isOnline'] as bool? ?? false,
        // Last participant in group chats is the driver/admin
        'isAdmin': listPos == participantIndices.length - 1,
        'isMuted': false,
        'joinedAt': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
        ),
        'lastSeenAt': Timestamp.now(),
      };
    }).toList();

    final safeSenderIdx = lastMessageSenderIndex.clamp(
      0,
      participantIndices.length - 1,
    );
    final senderUidIdx = participantIndices[safeSenderIdx].clamp(
      0,
      userFixtures.length - 1,
    );

    final data = stripDirectives(raw)
      ..addAll({
        'id': docRef.id,
        'participantIds': participantIds,
        'participants': participants,
        'lastMessageSenderId': participantIds[safeSenderIdx],
        'lastMessageSenderName':
            userFixtures[senderUidIdx]['displayName'] as String? ?? '',
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
    stdout.write('\r  Progress: ${i + 1}/$numChats');
  }

  await batch.commit();
  print('\n✅ Chats seeded\n');
}

// ============================================================================
// SEED HOTSPOTS
// ============================================================================
Future<void> seedHotspots(FirebaseFirestore firestore) async {
  print('📍 Seeding hotspots ($numHotspots)...');
  final fixtures = await loadFixture('hotspots.json');
  final batch = firestore.batch();

  for (int i = 0; i < numHotspots && i < fixtures.length; i++) {
    final raw = fixtures[i];
    final docRef = firestore.collection(hotspotsCollection).doc();
    final data = Map<String, dynamic>.from(raw)
      ..addAll({'id': docRef.id, 'createdAt': Timestamp.now()});

    batch.set(docRef, data);
    stdout.write('\r  Progress: ${i + 1}/$numHotspots');
  }

  await batch.commit();
  print('\n✅ Hotspots seeded\n');
}

// ============================================================================
// SEED EVENTS
// ============================================================================
Future<void> seedEvents(
  FirebaseFirestore firestore,
  List<String> userIds,
  List<Map<String, dynamic>> userFixtures,
) async {
  print('🏆 Seeding events ($numEvents)...');
  final fixtures = await loadFixture('events.json');
  final batch = firestore.batch();

  for (int i = 0; i < numEvents && i < fixtures.length; i++) {
    final raw = fixtures[i];
    final docRef = firestore.collection(eventsCollection).doc();

    final creatorIndex = ((raw['_creatorIndex'] as int?) ?? 0).clamp(
      0,
      userIds.length - 1,
    );
    final participantIndices =
        ((raw['_participantIndices'] as List<dynamic>?) ?? []).cast<int>();
    final startsAtHoursFromNow = (raw['_startsAtHoursFromNow'] as int?) ?? 24;
    final createdAtDaysAgo =
        (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(14);

    final participantIds = participantIndices
        .map((idx) => userIds[idx.clamp(0, userIds.length - 1)])
        .toList();

    final data = stripDirectives(raw)
      ..addAll({
        'id': docRef.id,
        'creatorId': userIds[creatorIndex],
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
    stdout.write('\r  Progress: ${i + 1}/$numEvents');
  }

  await batch.commit();
  print('\n✅ Events seeded\n');
}

// ============================================================================
// SEED NOTIFICATIONS
// ============================================================================
Future<void> seedNotifications(
  FirebaseFirestore firestore,
  List<String> userIds,
) async {
  print('🔔 Seeding notifications ($numNotifications)...');
  final fixtures = await loadFixture('notifications.json');
  final batch = firestore.batch();

  for (int i = 0; i < numNotifications && i < fixtures.length; i++) {
    final raw = fixtures[i];
    final docRef = firestore.collection(notificationsCollection).doc();

    final userIndex = ((raw['_userIndex'] as int?) ?? 0).clamp(
      0,
      userIds.length - 1,
    );
    final senderIndex = raw['_senderIndex'] as int? ?? -1;
    final createdAtDaysAgo =
        (raw['_createdAtDaysAgo'] as int?) ?? random.nextInt(7);

    final data = stripDirectives(raw)
      ..addAll({
        'id': docRef.id,
        'userId': userIds[userIndex],
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: createdAtDaysAgo)),
        ),
      });

    // Only set senderId when a valid sender index is provided
    if (senderIndex >= 0 && senderIndex < userIds.length) {
      data['senderId'] = userIds[senderIndex];
    }

    batch.set(docRef, data);
    stdout.write('\r  Progress: ${i + 1}/$numNotifications');
  }

  await batch.commit();
  print('\n✅ Notifications seeded\n');
}
