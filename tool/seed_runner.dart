// Firestore Seed Tool for SportConnect
// Run with: flutter run -t tool/seed_runner.dart
// Or use Firebase CLI to import JSON data

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:sport_connect/firebase_options.dart';

final faker = Faker();
final random = Random();

// Collection names
const usersCollection = 'users';
const ridesCollection = 'rides';
const vehiclesCollection = 'vehicles';
const chatsCollection = 'chats';
const notificationsCollection = 'notifications';
const hotspotsCollection = 'hotspots';

// Seed configuration
const int numUsers = 20;
const int numRides = 30;
const int numVehicles = 15;
const int numChats = 10;
const int numHotspots = 8;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SeedApp());
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

      // Generate user IDs
      _userIds = List.generate(
        numUsers,
        (_) => firestore.collection(usersCollection).doc().id,
      );

      await _seedUsers(firestore);
      await _seedVehicles(firestore);
      await _seedRides(firestore);
      await _seedChats(firestore);
      await _seedHotspots(firestore);

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
      _log('🗑️ Clearing all collections...\n');

      await _clearCollection(firestore, usersCollection);
      await _clearCollection(firestore, ridesCollection);
      await _clearCollection(firestore, vehiclesCollection);
      await _clearCollection(firestore, chatsCollection);
      await _clearCollection(firestore, notificationsCollection);
      await _clearCollection(firestore, hotspotsCollection);

      _log('\n✅ All collections cleared!');
    } catch (e) {
      _log('❌ Error: $e');
    }

    setState(() => _isSeeding = false);
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

  Future<void> _seedUsers(FirebaseFirestore firestore) async {
    _log('👥 Seeding $numUsers users...');

    final batch = firestore.batch();
    final sports = [
      'Football',
      'Basketball',
      'Tennis',
      'Golf',
      'Soccer',
      'Baseball',
    ];
    final cities = [
      'San Francisco',
      'Los Angeles',
      'New York',
      'Chicago',
      'Houston',
    ];

    for (int i = 0; i < _userIds.length; i++) {
      final docRef = firestore.collection(usersCollection).doc(_userIds[i]);
      final isDriver = random.nextBool();

      batch.set(docRef, {
        'uid': _userIds[i],
        'email': faker.internet.email(),
        'displayName': faker.person.name(),
        'photoUrl': 'https://i.pravatar.cc/150?u=${_userIds[i]}',
        'phoneNumber': faker.phoneNumber.us(),
        'bio': faker.lorem.sentence(),
        'role': isDriver ? (random.nextBool() ? 'driver' : 'both') : 'rider',
        'isDriver': isDriver,
        'isEmailVerified': random.nextBool(),
        'isPhoneVerified': random.nextBool(),
        'isPremium': random.nextDouble() < 0.2,
        'isOnline': random.nextBool(),
        'city': cities[random.nextInt(cities.length)],
        'country': 'USA',
        'interests': List.generate(
          random.nextInt(3) + 1,
          (_) => sports[random.nextInt(sports.length)],
        ),
        'gamification': {
          'totalXP': random.nextInt(10000),
          'level': random.nextInt(10) + 1,
          'totalRides': random.nextInt(100),
          'ridesAsDriver': random.nextInt(50),
          'ridesAsPassenger': random.nextInt(50),
          'currentStreak': random.nextInt(15),
          'co2Saved': random.nextDouble() * 500,
        },
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: random.nextInt(365))),
        ),
        'lastSeenAt': Timestamp.now(),
      });
    }

    await batch.commit();
    _log('  ✓ Created $numUsers users');
  }

  Future<void> _seedVehicles(FirebaseFirestore firestore) async {
    _log('🚗 Seeding $numVehicles vehicles...');

    final batch = firestore.batch();
    final makes = ['Tesla', 'Toyota', 'Honda', 'Ford', 'BMW', 'Mercedes'];
    final models = ['Model 3', 'Camry', 'Accord', 'Mustang', 'X5', 'C-Class'];
    final colors = ['White', 'Black', 'Silver', 'Blue', 'Red'];

    for (int i = 0; i < numVehicles; i++) {
      final docRef = firestore.collection(vehiclesCollection).doc();
      final makeIndex = random.nextInt(makes.length);

      batch.set(docRef, {
        'id': docRef.id,
        'ownerId': _userIds[random.nextInt(_userIds.length)],
        'make': makes[makeIndex],
        'model': models[makeIndex % models.length],
        'year': '${2018 + random.nextInt(8)}',
        'color': colors[random.nextInt(colors.length)],
        'licensePlate':
            '${String.fromCharCodes(List.generate(3, (_) => random.nextInt(26) + 65))} ${random.nextInt(9000) + 1000}',
        'capacity': random.nextInt(4) + 2,
        'fuelType': ['gasoline', 'electric', 'hybrid'][random.nextInt(3)],
        'isActive': true,
        'verificationStatus': 'verified',
        'hasAC': true,
        'totalRides': random.nextInt(100),
        'averageRating': 4.0 + random.nextDouble(),
        'createdAt': Timestamp.now(),
      });
    }

    await batch.commit();
    _log('  ✓ Created $numVehicles vehicles');
  }

  Future<void> _seedRides(FirebaseFirestore firestore) async {
    _log('🚕 Seeding $numRides rides...');

    final batch = firestore.batch();
    final statuses = ['active', 'active', 'active', 'full', 'completed'];

    final locations = [
      {'city': 'San Francisco', 'lat': 37.7749, 'lng': -122.4194},
      {'city': 'Palo Alto', 'lat': 37.4419, 'lng': -122.1430},
      {'city': 'San Jose', 'lat': 37.3382, 'lng': -121.8863},
      {'city': 'Oakland', 'lat': 37.8044, 'lng': -122.2712},
      {'city': 'Los Angeles', 'lat': 34.0522, 'lng': -118.2437},
    ];

    for (int i = 0; i < numRides; i++) {
      final docRef = firestore.collection(ridesCollection).doc();
      final driverId = _userIds[random.nextInt(_userIds.length)];
      final originLoc = locations[random.nextInt(locations.length)];
      final destLoc = locations[random.nextInt(locations.length)];
      final status = statuses[random.nextInt(statuses.length)];
      final availableSeats = random.nextInt(4) + 1;

      final departureTime = status == 'completed'
          ? DateTime.now().subtract(Duration(days: random.nextInt(30)))
          : DateTime.now().add(Duration(hours: random.nextInt(72) + 1));

      batch.set(docRef, {
        'id': docRef.id,
        'driverId': driverId,
        'driverName': faker.person.name(),
        'driverPhotoUrl': 'https://i.pravatar.cc/150?u=$driverId',
        'driverRating': 4.0 + random.nextDouble(),
        'origin': {
          'address': '${faker.address.streetAddress()}, ${originLoc['city']}',
          'latitude':
              (originLoc['lat'] as double) + (random.nextDouble() - 0.5) * 0.1,
          'longitude':
              (originLoc['lng'] as double) + (random.nextDouble() - 0.5) * 0.1,
          'city': originLoc['city'],
        },
        'destination': {
          'address': '${faker.address.streetAddress()}, ${destLoc['city']}',
          'latitude':
              (destLoc['lat'] as double) + (random.nextDouble() - 0.5) * 0.1,
          'longitude':
              (destLoc['lng'] as double) + (random.nextDouble() - 0.5) * 0.1,
          'city': destLoc['city'],
        },
        'departureTime': Timestamp.fromDate(departureTime),
        'distanceKm': 10.0 + random.nextDouble() * 90,
        'durationMinutes': 15 + random.nextInt(90),
        'availableSeats': availableSeats,
        'bookedSeats': status == 'full'
            ? availableSeats
            : random.nextInt(availableSeats),
        'pricePerSeat': 5.0 + random.nextDouble() * 25,
        'currency': 'USD',
        'status': status,
        'allowPets': random.nextBool(),
        'allowSmoking': false,
        'allowLuggage': random.nextBool(),
        'vehicleInfo': '${2020 + random.nextInt(6)} Tesla Model 3',
        'bookings': [],
        'reviews': [],
        'xpReward': 25 + random.nextInt(75),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    }

    await batch.commit();
    _log('  ✓ Created $numRides rides');
  }

  Future<void> _seedChats(FirebaseFirestore firestore) async {
    _log('💬 Seeding $numChats chats...');

    final batch = firestore.batch();

    for (int i = 0; i < numChats; i++) {
      final docRef = firestore.collection(chatsCollection).doc();
      final participants = <String>[];
      final participantCount = random.nextInt(2) + 2;

      for (int j = 0; j < participantCount; j++) {
        String userId;
        do {
          userId = _userIds[random.nextInt(_userIds.length)];
        } while (participants.contains(userId));
        participants.add(userId);
      }

      batch.set(docRef, {
        'id': docRef.id,
        'type': participantCount > 2 ? 'rideGroup' : 'private',
        'participantIds': participants,
        'lastMessageContent': faker.lorem.sentence(),
        'lastMessageSenderId': participants.first,
        'lastMessageAt': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });
    }

    await batch.commit();
    _log('  ✓ Created $numChats chats');
  }

  Future<void> _seedHotspots(FirebaseFirestore firestore) async {
    _log('📍 Seeding hotspots...');

    final batch = firestore.batch();

    final hotspots = [
      {'name': 'Levi\'s Stadium', 'lat': 37.4033, 'lng': -121.9694},
      {'name': 'Oracle Park', 'lat': 37.7786, 'lng': -122.3893},
      {'name': 'Chase Center', 'lat': 37.7680, 'lng': -122.3877},
      {'name': 'Stanford Stadium', 'lat': 37.4346, 'lng': -122.1609},
      {'name': 'SoFi Stadium', 'lat': 33.9535, 'lng': -118.3390},
      {'name': 'Dodger Stadium', 'lat': 34.0739, 'lng': -118.2400},
    ];

    for (final hotspot in hotspots) {
      final docRef = firestore.collection(hotspotsCollection).doc();
      batch.set(docRef, {
        'id': docRef.id,
        'name': hotspot['name'],
        'latitude': hotspot['lat'],
        'longitude': hotspot['lng'],
        'rideCount': random.nextInt(50) + 5,
        'isActive': true,
        'createdAt': Timestamp.now(),
      });
    }

    await batch.commit();
    _log('  ✓ Created ${hotspots.length} hotspots');
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
