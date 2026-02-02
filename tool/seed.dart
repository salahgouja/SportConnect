// Firestore Seed Tool for SportConnect
// Run with: dart run tool/seed.dart
// Options:
//   --clear     Clear all data before seeding
//   --users     Seed users collection only
//   --rides     Seed rides collection only
//   --vehicles  Seed vehicles collection only
//   --chats     Seed chats collection only
//   --all       Seed all collections (default)

import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:faker/faker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

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
const int numHotspots = 12;

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('clear', abbr: 'c', help: 'Clear all data before seeding')
    ..addFlag('users', abbr: 'u', help: 'Seed users collection')
    ..addFlag('rides', abbr: 'r', help: 'Seed rides collection')
    ..addFlag('vehicles', abbr: 'v', help: 'Seed vehicles collection')
    ..addFlag('chats', help: 'Seed chats collection')
    ..addFlag('hotspots', abbr: 'h', help: 'Seed hotspots collection')
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

  // Initialize Firebase
  print('🔥 Initializing Firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;
  print('✅ Firebase initialized\n');

  // Determine what to seed
  final seedAll =
      results['all'] as bool ||
      (!results['users'] &&
          !results['rides'] &&
          !results['vehicles'] &&
          !results['chats'] &&
          !results['hotspots']);

  final shouldClear = results['clear'] as bool;

  // Clear data if requested
  if (shouldClear) {
    print('🗑️  Clearing existing data...\n');
    await clearCollection(firestore, usersCollection);
    await clearCollection(firestore, ridesCollection);
    await clearCollection(firestore, vehiclesCollection);
    await clearCollection(firestore, chatsCollection);
    await clearCollection(firestore, notificationsCollection);
    await clearCollection(firestore, hotspotsCollection);
    print('✅ Data cleared\n');
  }

  // Generate user IDs first (needed for relationships)
  final userIds = List.generate(
    numUsers,
    (_) => firestore.collection(usersCollection).doc().id,
  );

  // Seed collections
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
    await seedChats(firestore, userIds);
  }

  if (seedAll || results['hotspots'] as bool) {
    await seedHotspots(firestore);
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

  final batch = firestore.batch();
  final sports = [
    'Football',
    'Basketball',
    'Tennis',
    'Handball',
    'Swimming',
    'Volleyball',
    'Athletics',
    'Taekwondo',
  ];
  final cities = [
    'Tunis',
    'Sfax',
    'Sousse',
    'Kairouan',
    'Bizerte',
    'Gabès',
    'Ariana',
    'Gafsa',
    'Monastir',
    'Ben Arous',
    'La Marsa',
    'Hammamet',
  ];

  // Tunisian first names
  final tunisianFirstNames = [
    'Ahmed',
    'Mohamed',
    'Ali',
    'Amine',
    'Yassine',
    'Khalil',
    'Omar',
    'Aymen',
    'Firas',
    'Rami',
    'Fatma',
    'Mariem',
    'Ines',
    'Sarra',
    'Amira',
    'Nour',
    'Rania',
    'Yasmine',
    'Sirine',
    'Emna',
  ];
  final tunisianLastNames = [
    'Ben Ali',
    'Trabelsi',
    'Gharbi',
    'Mejri',
    'Khelifi',
    'Bouazizi',
    'Dridi',
    'Haddad',
    'Sassi',
    'Ferchichi',
    'Mansouri',
    'Chaabane',
    'Riahi',
    'Hamdi',
    'Attia',
  ];

  for (int i = 0; i < userIds.length; i++) {
    final docRef = firestore.collection(usersCollection).doc(userIds[i]);
    final isDriver = random.nextBool();
    final firstName =
        tunisianFirstNames[random.nextInt(tunisianFirstNames.length)];
    final lastName =
        tunisianLastNames[random.nextInt(tunisianLastNames.length)];

    batch.set(docRef, {
      'uid': userIds[i],
      'email':
          '${firstName.toLowerCase()}.${lastName.toLowerCase().replaceAll(' ', '')}@gmail.com',
      'displayName': '$firstName $lastName',
      'photoUrl': 'https://i.pravatar.cc/150?u=${userIds[i]}',
      'phoneNumber':
          '+216 ${20 + random.nextInt(80)} ${random.nextInt(900) + 100} ${random.nextInt(900) + 100}',
      'bio': faker.lorem.sentence(),
      'role': isDriver ? (random.nextBool() ? 'driver' : 'both') : 'rider',
      'isDriver': isDriver,
      'isEmailVerified': random.nextBool(),
      'isPhoneVerified': random.nextBool(),
      'isPremium': random.nextDouble() < 0.2,
      'isOnline': random.nextBool(),
      'city': cities[random.nextInt(cities.length)],
      'country': 'Tunisia',
      'interests': List.generate(
        random.nextInt(3) + 1,
        (_) => sports[random.nextInt(sports.length)],
      ),
      'gamification': {
        'totalXP': random.nextInt(10000),
        'level': random.nextInt(10) + 1,
        'currentLevelXP': random.nextInt(1000),
        'xpToNextLevel': 1000,
        'totalRides': random.nextInt(100),
        'ridesAsDriver': random.nextInt(50),
        'ridesAsPassenger': random.nextInt(50),
        'currentStreak': random.nextInt(15),
        'longestStreak': random.nextInt(30),
        'co2Saved': random.nextDouble() * 500,
        'moneySaved': random.nextDouble() * 1000,
        'totalDistance': random.nextDouble() * 5000,
        'unlockedBadges': ['early_adopter'],
      },
      'driverRating': isDriver
          ? {
              'total': random.nextInt(100),
              'average': 4.0 + random.nextDouble(),
              'fiveStars': random.nextInt(80),
              'fourStars': random.nextInt(15),
              'threeStars': random.nextInt(5),
            }
          : null,
      'passengerRating': {
        'total': random.nextInt(50),
        'average': 4.0 + random.nextDouble(),
        'fiveStars': random.nextInt(40),
        'fourStars': random.nextInt(8),
      },
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: random.nextInt(365))),
      ),
      'lastSeenAt': Timestamp.fromDate(
        DateTime.now().subtract(Duration(minutes: random.nextInt(1440))),
      ),
    });

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

  final batch = firestore.batch();
  // Popular car brands in Tunisia
  final makes = [
    'Peugeot',
    'Renault',
    'Volkswagen',
    'Citroën',
    'Kia',
    'Hyundai',
    'Toyota',
    'Dacia',
    'Fiat',
    'Seat',
  ];
  final models = {
    'Peugeot': ['208', '308', '3008', '2008', '5008'],
    'Renault': ['Clio', 'Megane', 'Symbol', 'Captur', 'Duster'],
    'Volkswagen': ['Golf', 'Polo', 'Passat', 'Tiguan', 'T-Roc'],
    'Citroën': ['C3', 'C4', 'C5 Aircross', 'Berlingo'],
    'Kia': ['Picanto', 'Rio', 'Sportage', 'Ceed', 'Sorento'],
    'Hyundai': ['i10', 'i20', 'Tucson', 'Accent', 'Elantra'],
    'Toyota': ['Yaris', 'Corolla', 'RAV4', 'Hilux', 'C-HR'],
    'Dacia': ['Logan', 'Sandero', 'Duster', 'Spring'],
    'Fiat': ['Punto', '500', 'Tipo', 'Panda'],
    'Seat': ['Ibiza', 'Leon', 'Arona', 'Ateca'],
  };
  final colors = ['White', 'Black', 'Silver', 'Gray', 'Blue', 'Red', 'Beige'];
  final fuelTypes = ['gasoline', 'diesel', 'electric', 'hybrid'];

  // Tunisian license plate format: RS XXXX (governorate code + numbers)
  final governorateCodes = [
    'TU',
    'AR',
    'BE',
    'MN',
    'BJ',
    'GF',
    'GB',
    'JE',
    'KB',
    'KF',
    'KS',
    'MH',
    'MD',
    'NB',
    'SF',
    'SB',
    'SZ',
    'SL',
    'SO',
    'TA',
    'TO',
    'TZ',
    'ZG',
  ];

  for (int i = 0; i < numVehicles; i++) {
    final docRef = firestore.collection(vehiclesCollection).doc();
    final makeIndex = random.nextInt(makes.length);
    final make = makes[makeIndex];
    final modelList = models[make]!;
    final model = modelList[random.nextInt(modelList.length)];
    final governorateCode =
        governorateCodes[random.nextInt(governorateCodes.length)];

    batch.set(docRef, {
      'id': docRef.id,
      'ownerId': userIds[random.nextInt(userIds.length)],
      'make': make,
      'model': model,
      'year': '${2015 + random.nextInt(10)}',
      'color': colors[random.nextInt(colors.length)],
      'licensePlate': '$governorateCode ${random.nextInt(9000) + 1000} TN',
      'capacity': random.nextInt(4) + 2,
      'fuelType': fuelTypes[random.nextInt(fuelTypes.length)],
      'isActive': random.nextDouble() > 0.2,
      'verificationStatus': 'verified',
      'hasAC': true,
      'hasCharger': random.nextBool(),
      'hasWifi': random.nextBool(),
      'hasLuggage': random.nextBool(),
      'petsAllowed': random.nextBool(),
      'totalRides': random.nextInt(100),
      'averageRating': 4.0 + random.nextDouble(),
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: random.nextInt(180))),
      ),
    });

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

  final batch = firestore.batch();
  final statuses = [
    'active',
    'active',
    'active',
    'full',
    'completed',
    'cancelled',
  ];

  // Tunisian driver names
  final driverFirstNames = [
    'Ahmed',
    'Mohamed',
    'Ali',
    'Amine',
    'Yassine',
    'Khalil',
    'Omar',
    'Aymen',
    'Firas',
    'Rami',
    'Fatma',
    'Mariem',
    'Ines',
    'Sarra',
    'Amira',
  ];
  final driverLastNames = [
    'Ben Ali',
    'Trabelsi',
    'Gharbi',
    'Mejri',
    'Khelifi',
    'Bouazizi',
    'Dridi',
    'Haddad',
    'Sassi',
    'Ferchichi',
  ];

  // Popular cars in Tunisia
  final tunisianCars = [
    'Peugeot 208',
    'Peugeot 308',
    'Renault Clio',
    'Renault Symbol',
    'Volkswagen Golf',
    'Volkswagen Polo',
    'Kia Picanto',
    'Kia Rio',
    'Hyundai i10',
    'Hyundai i20',
    'Toyota Yaris',
    'Toyota Corolla',
    'Dacia Logan',
    'Dacia Sandero',
    'Citroën C3',
    'Fiat Punto',
  ];

  // Real locations in Tunisia
  final locations = [
    // Tunis & Greater Tunis
    {
      'city': 'Tunis',
      'area': 'Centre Ville',
      'lat': 36.8065,
      'lng': 10.1815,
      'address': 'Avenue Habib Bourguiba',
    },
    {
      'city': 'Tunis',
      'area': 'Lac 1',
      'lat': 36.8340,
      'lng': 10.2247,
      'address': 'Les Berges du Lac',
    },
    {
      'city': 'Tunis',
      'area': 'Lac 2',
      'lat': 36.8421,
      'lng': 10.2542,
      'address': 'Rue du Lac Biwa',
    },
    {
      'city': 'La Marsa',
      'area': 'Marsa Plage',
      'lat': 36.8780,
      'lng': 10.3241,
      'address': 'Avenue Taieb Mhiri',
    },
    {
      'city': 'La Marsa',
      'area': 'Sidi Bou Said',
      'lat': 36.8689,
      'lng': 10.3417,
      'address': 'Rue Habib Thameur',
    },
    {
      'city': 'Ariana',
      'area': 'Ariana Ville',
      'lat': 36.8625,
      'lng': 10.1956,
      'address': 'Avenue de l\'Indépendance',
    },
    {
      'city': 'Ben Arous',
      'area': 'Mégrine',
      'lat': 36.7675,
      'lng': 10.2361,
      'address': 'Route de Tunis',
    },
    {
      'city': 'Carthage',
      'area': 'Carthage Byrsa',
      'lat': 36.8528,
      'lng': 10.3247,
      'address': 'Rue Hannibal',
    },
    {
      'city': 'El Menzah',
      'area': 'Menzah 6',
      'lat': 36.8283,
      'lng': 10.1417,
      'address': 'Rue du Parc',
    },
    // Sousse Region
    {
      'city': 'Sousse',
      'area': 'Centre Ville',
      'lat': 35.8256,
      'lng': 10.6084,
      'address': 'Avenue Habib Bourguiba',
    },
    {
      'city': 'Sousse',
      'area': 'Médina',
      'lat': 35.8270,
      'lng': 10.6392,
      'address': 'Rue de la Médina',
    },
    {
      'city': 'Sousse',
      'area': 'Khezama',
      'lat': 35.8420,
      'lng': 10.5920,
      'address': 'Route de la Corniche',
    },
    {
      'city': 'Hammam Sousse',
      'area': 'Bord de Mer',
      'lat': 35.8604,
      'lng': 10.5894,
      'address': 'Avenue de la Plage',
    },
    // Sfax Region
    {
      'city': 'Sfax',
      'area': 'Centre Ville',
      'lat': 34.7406,
      'lng': 10.7603,
      'address': 'Avenue Habib Bourguiba',
    },
    {
      'city': 'Sfax',
      'area': 'Médina',
      'lat': 34.7356,
      'lng': 10.7592,
      'address': 'Rue Mongi Slim',
    },
    // Monastir Region
    {
      'city': 'Monastir',
      'area': 'Centre',
      'lat': 35.7643,
      'lng': 10.8113,
      'address': 'Rue de l\'Indépendance',
    },
    {
      'city': 'Monastir',
      'area': 'Skanes',
      'lat': 35.7858,
      'lng': 10.7539,
      'address': 'Route Touristique',
    },
    {
      'city': 'Mahdia',
      'area': 'Centre Ville',
      'lat': 35.5047,
      'lng': 11.0622,
      'address': 'Avenue Farhat Hached',
    },
    // Hammamet & Nabeul
    {
      'city': 'Hammamet',
      'area': 'Centre Ville',
      'lat': 36.4000,
      'lng': 10.6167,
      'address': 'Avenue Habib Bourguiba',
    },
    {
      'city': 'Hammamet',
      'area': 'Yasmine',
      'lat': 36.3658,
      'lng': 10.5475,
      'address': 'Zone Touristique',
    },
    {
      'city': 'Nabeul',
      'area': 'Centre',
      'lat': 36.4561,
      'lng': 10.7356,
      'address': 'Avenue Habib Thameur',
    },
    // Other Cities
    {
      'city': 'Bizerte',
      'area': 'Vieux Port',
      'lat': 37.2744,
      'lng': 9.8739,
      'address': 'Corniche',
    },
    {
      'city': 'Kairouan',
      'area': 'Médina',
      'lat': 35.6781,
      'lng': 10.0972,
      'address': 'Avenue de la République',
    },
    {
      'city': 'Gabès',
      'area': 'Centre',
      'lat': 33.8814,
      'lng': 10.0983,
      'address': 'Avenue Farhat Hached',
    },
    {
      'city': 'Gafsa',
      'area': 'Centre Ville',
      'lat': 34.4250,
      'lng': 8.7842,
      'address': 'Avenue Habib Bourguiba',
    },
    {
      'city': 'Tozeur',
      'area': 'Centre',
      'lat': 33.9197,
      'lng': 8.1339,
      'address': 'Avenue Abou el Kacem Chebbi',
    },
    {
      'city': 'Djerba',
      'area': 'Houmt Souk',
      'lat': 33.8750,
      'lng': 10.8578,
      'address': 'Avenue Habib Bourguiba',
    },
    {
      'city': 'Tabarka',
      'area': 'Centre',
      'lat': 36.9544,
      'lng': 8.7581,
      'address': 'Avenue Habib Bourguiba',
    },
  ];

  for (int i = 0; i < numRides; i++) {
    final docRef = firestore.collection(ridesCollection).doc();
    final driverIndex = random.nextInt(userIds.length);
    final originLoc = locations[random.nextInt(locations.length)];
    final destLoc = locations[random.nextInt(locations.length)];
    final status = statuses[random.nextInt(statuses.length)];
    final availableSeats = random.nextInt(4) + 1;
    final bookedSeats = status == 'full'
        ? availableSeats
        : random.nextInt(availableSeats);
    final driverName =
        '${driverFirstNames[random.nextInt(driverFirstNames.length)]} ${driverLastNames[random.nextInt(driverLastNames.length)]}';
    final carYear = 2015 + random.nextInt(10);
    final car = tunisianCars[random.nextInt(tunisianCars.length)];

    // Generate departure time (future for active, past for completed)
    final departureTime = status == 'completed'
        ? DateTime.now().subtract(Duration(days: random.nextInt(30)))
        : DateTime.now().add(Duration(hours: random.nextInt(72) + 1));

    batch.set(docRef, {
      'id': docRef.id,
      'driverId': userIds[driverIndex],
      'driverName': driverName,
      'driverPhotoUrl': 'https://i.pravatar.cc/150?u=${userIds[driverIndex]}',
      'driverRating': 4.0 + random.nextDouble(),
      'origin': {
        'address':
            '${originLoc['address']}, ${originLoc['area']}, ${originLoc['city']}',
        'latitude':
            (originLoc['lat'] as double) + (random.nextDouble() - 0.5) * 0.02,
        'longitude':
            (originLoc['lng'] as double) + (random.nextDouble() - 0.5) * 0.02,
        'city': originLoc['city'],
      },
      'destination': {
        'address':
            '${destLoc['address']}, ${destLoc['area']}, ${destLoc['city']}',
        'latitude':
            (destLoc['lat'] as double) + (random.nextDouble() - 0.5) * 0.02,
        'longitude':
            (destLoc['lng'] as double) + (random.nextDouble() - 0.5) * 0.02,
        'city': destLoc['city'],
      },
      'departureTime': Timestamp.fromDate(departureTime),
      'distanceKm': 10.0 + random.nextDouble() * 150,
      'durationMinutes': 15 + random.nextInt(180),
      'availableSeats': availableSeats,
      'bookedSeats': bookedSeats,
      'pricePerSeat': 3.0 + random.nextDouble() * 20, // EUR pricing
      'currency': 'EUR',
      'status': status,
      'allowPets': random.nextBool(),
      'allowSmoking': false,
      'allowLuggage': random.nextBool(),
      'vehicleInfo': '$carYear $car',
      'bookings': [],
      'reviews': [],
      'xpReward': 25 + random.nextInt(75),
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: random.nextInt(7))),
      ),
      'updatedAt': Timestamp.now(),
    });

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
) async {
  print('💬 Seeding chats ($numChats)...');

  final batch = firestore.batch();

  for (int i = 0; i < numChats; i++) {
    final docRef = firestore.collection(chatsCollection).doc();
    final participantCount = random.nextInt(3) + 2;
    final participants = <String>[];

    for (int j = 0; j < participantCount; j++) {
      String userId;
      do {
        userId = userIds[random.nextInt(userIds.length)];
      } while (participants.contains(userId));
      participants.add(userId);
    }

    final isGroup = participantCount > 2;

    // Tunisian cities for group names
    final tunisianCities = [
      'Tunis',
      'Sousse',
      'Sfax',
      'Monastir',
      'Hammamet',
      'Bizerte',
      'Kairouan',
      'Gabès',
      'Djerba',
      'La Marsa',
      'Carthage',
      'Nabeul',
    ];
    final chatFirstNames = [
      'Ahmed',
      'Mohamed',
      'Ali',
      'Amine',
      'Yassine',
      'Fatma',
      'Mariem',
      'Ines',
    ];
    final chatLastNames = ['Ben Ali', 'Trabelsi', 'Gharbi', 'Mejri', 'Khelifi'];

    batch.set(docRef, {
      'id': docRef.id,
      'type': isGroup ? 'rideGroup' : 'private',
      'participantIds': participants,
      'participants': participants
          .map(
            (id) => {
              'uid': id,
              'displayName':
                  '${chatFirstNames[random.nextInt(chatFirstNames.length)]} ${chatLastNames[random.nextInt(chatLastNames.length)]}',
              'photoUrl': 'https://i.pravatar.cc/150?u=$id',
              'isOnline': random.nextBool(),
              'isAdmin': participants.indexOf(id) == 0,
            },
          )
          .toList(),
      'groupName': isGroup
          ? 'Ride to ${tunisianCities[random.nextInt(tunisianCities.length)]}'
          : null,
      'lastMessageContent': faker.lorem.sentence(),
      'lastMessageSenderId': participants[random.nextInt(participants.length)],
      'lastMessageSenderName':
          '${chatFirstNames[random.nextInt(chatFirstNames.length)]} ${chatLastNames[random.nextInt(chatLastNames.length)]}',
      'lastMessageAt': Timestamp.fromDate(
        DateTime.now().subtract(Duration(minutes: random.nextInt(1440))),
      ),
      'unreadCounts': {},
      'createdAt': Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: random.nextInt(30))),
      ),
    });

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

  final batch = firestore.batch();

  final hotspots = [
    // Tunisian stadiums and sports venues
    {'name': 'Stade Olympique de Radès', 'lat': 36.7453, 'lng': 10.2728},
    {'name': 'Stade Hammadi Agrebi (La Marsa)', 'lat': 36.8781, 'lng': 10.3244},
    {'name': 'Stade Olympique de Sousse', 'lat': 35.8289, 'lng': 10.5861},
    {'name': 'Stade Taïeb Mhiri (Sfax)', 'lat': 34.7464, 'lng': 10.7597},
    {
      'name': 'Stade Mustapha Ben Jannet (Monastir)',
      'lat': 35.7650,
      'lng': 10.8083,
    },
    {'name': 'Stade 15 Octobre (Bizerte)', 'lat': 37.2756, 'lng': 9.8736},
    {'name': 'Complexe Sportif El Menzah', 'lat': 36.8189, 'lng': 10.1483},
    {'name': 'Stade Chedly Zouiten (Tunis)', 'lat': 36.8011, 'lng': 10.1678},
    {'name': 'Tunisia Mall (La Marsa)', 'lat': 36.8506, 'lng': 10.2492},
    {'name': 'Carrefour La Marsa', 'lat': 36.8789, 'lng': 10.3247},
    {'name': 'Aéroport Tunis-Carthage', 'lat': 36.8510, 'lng': 10.2272},
    {'name': 'Faculté des Sciences de Tunis', 'lat': 36.8428, 'lng': 10.1969},
  ];

  for (int i = 0; i < hotspots.length && i < numHotspots; i++) {
    final docRef = firestore.collection(hotspotsCollection).doc();
    final hotspot = hotspots[i];

    batch.set(docRef, {
      'id': docRef.id,
      'name': hotspot['name'],
      'latitude': hotspot['lat'],
      'longitude': hotspot['lng'],
      'rideCount': random.nextInt(50) + 5,
      'isActive': true,
      'createdAt': Timestamp.now(),
    });

    stdout.write('\r  Progress: ${i + 1}/$numHotspots');
  }

  await batch.commit();
  print('\n✅ Hotspots seeded\n');
}
