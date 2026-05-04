#!/usr/bin/env node

import { createRequire } from 'node:module';

const projectId = process.env.FIREBASE_PROJECT_ID ?? 'marathon-connect';
const firestoreHost = process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080';
const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST ?? '127.0.0.1:9099';
const password = process.env.SEED_PASSWORD ?? 'Password123!';
const shouldClean = process.env.SEED_CLEAN === 'true';

process.env.FIRESTORE_EMULATOR_HOST = firestoreHost;
process.env.FIREBASE_AUTH_EMULATOR_HOST = authHost;

const require = createRequire(import.meta.url);
const admin = require('../functions/node_modules/firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp({ projectId });
}

const auth = admin.auth();
const db = admin.firestore();

const totals = {
  drivers: Number(process.env.SEED_DRIVERS ?? 240),
  riders: Number(process.env.SEED_RIDERS ?? 760),
  events: Number(process.env.SEED_EVENTS ?? 1500),
  rides: Number(process.env.SEED_RIDES ?? 2200),
  privateChats: Number(process.env.SEED_PRIVATE_CHATS ?? 350),
};

const firstNames = [
  'Amina',
  'Tunde',
  'Chioma',
  'Kemi',
  'Malik',
  'Sofia',
  'David',
  'Fatima',
  'Noah',
  'Zara',
  'Ibrahim',
  'Maya',
  'Daniel',
  'Nora',
  'Ethan',
  'Leila',
  'Samuel',
  'Amara',
  'Omar',
  'Grace',
];

const lastNames = [
  'Okafor',
  'Bello',
  'Mensah',
  'Adeyemi',
  'Hassan',
  'Johnson',
  'Dubois',
  'Moreau',
  'Smith',
  'Garcia',
  'Diallo',
  'Martin',
];

const locations = [
  {
    city: 'Lagos',
    country: 'Nigeria',
    latitude: 6.5244,
    longitude: 3.3792,
    places: [
      'National Stadium, Surulere, Lagos',
      'Ikoyi Club 1938, Lagos',
      'Muri Okunola Park, Victoria Island, Lagos',
      'Teslim Balogun Stadium, Lagos',
      'Lekki Conservation Centre, Lagos',
    ],
  },
  {
    city: 'Abuja',
    country: 'Nigeria',
    latitude: 9.0765,
    longitude: 7.3986,
    places: [
      'Moshood Abiola Stadium, Abuja',
      'Millennium Park, Abuja',
      'Jabi Lake Park, Abuja',
      'Maitama Amusement Park, Abuja',
    ],
  },
  {
    city: 'Port Harcourt',
    country: 'Nigeria',
    latitude: 4.8156,
    longitude: 7.0498,
    places: [
      'Yakubu Gowon Stadium, Port Harcourt',
      'Pleasure Park, Port Harcourt',
      'Rumuola Sports Centre, Port Harcourt',
    ],
  },
];

const vehicles = [
  ['Toyota', 'Corolla', 'gasoline'],
  ['Hyundai', 'Ioniq', 'electric'],
  ['Kia', 'Niro', 'hybrid'],
  ['Tesla', 'Model 3', 'electric'],
  ['Honda', 'Civic', 'gasoline'],
  ['Toyota', 'Sienna', 'hybrid'],
  ['Mercedes-Benz', 'Vito', 'diesel'],
  ['Nissan', 'Leaf', 'electric'],
];

function pick(list, index) {
  return list[index % list.length];
}

function slug(value) {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '');
}

function isoDays(days, hour = 8, minute = 0) {
  const now = new Date();
  const value = new Date(
    now.getFullYear(),
    now.getMonth(),
    now.getDate() + days,
    hour,
    minute,
    0,
    0,
  );
  return value.toISOString();
}

function startOfToday() {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}

function startOfWeek() {
  const today = startOfToday();
  const daysSinceMonday = (today.getDay() + 6) % 7;
  return new Date(today.getFullYear(), today.getMonth(), today.getDate() - daysSinceMonday);
}

function startOfMonth() {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), 1);
}

function dateAt(days, hour = 8, minute = 0) {
  return new Date(isoDays(days, hour, minute));
}

function addHours(value, hours) {
  return new Date(value.getTime() + hours * 60 * 60 * 1000);
}

function locationFor(index, placeIndex = index) {
  const area = pick(locations, index);
  const address = pick(area.places, placeIndex);
  const jitter = ((index % 9) - 4) * 0.006;
  return {
    latitude: Number((area.latitude + jitter).toFixed(6)),
    longitude: Number((area.longitude - jitter).toFixed(6)),
    address,
    city: area.city,
    country: area.country,
    placeId: `seed_place_${slug(address)}`,
  };
}

function firestoreValue(value) {
  if (value === undefined) return undefined;
  if (value === null) return { nullValue: null };
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  if (typeof value === 'string') {
    if (/^\d{4}-\d{2}-\d{2}T/.test(value)) return { timestampValue: value };
    return { stringValue: value };
  }
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number') {
    if (Number.isInteger(value)) return { integerValue: String(value) };
    return { doubleValue: value };
  }
  if (Array.isArray(value)) {
    return {
      arrayValue: {
        values: value.map(firestoreValue).filter(Boolean),
      },
    };
  }
  return {
    mapValue: {
      fields: firestoreFields(value),
    },
  };
}

function firestoreFields(object) {
  return Object.fromEntries(
    Object.entries(object)
      .map(([key, value]) => [key, firestoreValue(value)])
      .filter(([, value]) => value !== undefined),
  );
}

async function ensureAuthUser(email, displayName) {
  const existing = authUsersByEmail.get(email);
  if (existing) return existing.localId;

  try {
    const user = await auth.getUserByEmail(email);
    authUsersByEmail.set(email, {
      localId: user.uid,
      email,
      displayName: user.displayName ?? displayName,
    });
    return user.uid;
  } catch (error) {
    if (error.code !== 'auth/user-not-found') throw error;
  }

  const user = await auth.createUser({
    email,
    password,
    displayName,
    emailVerified: true,
  });
  authUsersByEmail.set(email, { localId: user.uid, email, displayName });
  return user.uid;
}

async function upsertDoc(path, data) {
  await db.doc(path).set(toAdminData(data));
}

async function deleteDoc(path) {
  await db.doc(path).delete();
}

async function listCollection(collection) {
  const snapshot = await db.collection(collection).get();
  return snapshot.docs;
}

async function deleteSeedDocs(collection) {
  const docs = await listCollection(collection);
  const seedDocs = docs.filter((doc) => doc.id.startsWith('seed_'));
  await Promise.all(seedDocs.map((doc) => doc.ref.delete()));
  return seedDocs.length;
}

function toAdminData(value) {
  if (value === undefined) return undefined;
  if (value === null) return null;
  if (value instanceof Date) return value;
  if (typeof value === 'string') {
    if (/^\d{4}-\d{2}-\d{2}T/.test(value)) return new Date(value);
    return value;
  }
  if (Array.isArray(value)) {
    return value.map(toAdminData).filter((item) => item !== undefined);
  }
  if (typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value)
        .map(([key, item]) => [key, toAdminData(item)])
        .filter(([, item]) => item !== undefined),
    );
  }
  return value;
}

async function writeMany(items, writer, label) {
  let done = 0;
  for (let i = 0; i < items.length; i += 25) {
    const chunk = items.slice(i, i + 25);
    await Promise.all(chunk.map(writer));
    done += chunk.length;
    process.stdout.write(`\r${label}: ${done}/${items.length}`);
  }
  process.stdout.write('\n');
}

function baseUser(email, username, role, index) {
  const loc = locationFor(index);
  return {
    uid: '',
    email,
    username,
    photoUrl: `https://i.pravatar.cc/160?u=${encodeURIComponent(email)}`,
    phoneNumber: `+23480${String(10000000 + index * 719).slice(0, 8)}`,
    gender: index % 3 === 0 ? 'female' : index % 3 === 1 ? 'male' : 'non_binary',
    fcmToken: '',
    address: loc.address,
    latitude: loc.latitude,
    longitude: loc.longitude,
    isEmailVerified: true,
    isBanned: false,
    isPremium: index % 5 === 0,
    blockedUsers: [],
    expertise: pick(['rookie', 'intermediate', 'advanced', 'expert'], index),
    createdAt: isoDays(-120 + (index % 60), 9),
    updatedAt: isoDays(-index % 12, 12),
    role,
  };
}

const authUsersByEmail = new Map();

const seed = {
  users: [],
  drivers: [],
  riders: [],
  vehicles: [],
  events: [],
  rides: [],
  bookings: [],
  chats: [],
  messages: [],
  payments: [],
  reviews: [],
  driverStats: [],
};

async function buildUsers() {
  for (let i = 0; i < totals.drivers; i += 1) {
    const name = `${pick(firstNames, i)} ${pick(lastNames, i + 3)}`;
    const email = `seed.driver.${String(i + 1).padStart(2, '0')}@sportconnect.test`;
    const uid = await ensureAuthUser(email, name);
    const vehicleIds = [0, 1].map((n) => `seed_vehicle_${String(i * 2 + n + 1).padStart(3, '0')}`);
    const user = {
      ...baseUser(email, name, 'driver', i),
      uid,
      vehicleIds,
      stripeAccountId: `acct_seed_${String(i + 1).padStart(3, '0')}`,
    };
    seed.users.push(user);
    seed.drivers.push(user);
  }

  for (let i = 0; i < totals.riders; i += 1) {
    const name = `${pick(firstNames, i + 7)} ${pick(lastNames, i + 11)}`;
    const email = `seed.rider.${String(i + 1).padStart(2, '0')}@sportconnect.test`;
    const uid = await ensureAuthUser(email, name);
    const user = {
      ...baseUser(email, name, 'rider', i + 100),
      uid,
      stripeCustomerId: `cus_seed_${String(i + 1).padStart(3, '0')}`,
      isStripeCustomerCreated: true,
    };
    seed.users.push(user);
    seed.riders.push(user);
  }
}

function buildVehicles() {
  for (let i = 0; i < seed.drivers.length; i += 1) {
    for (let n = 0; n < 2; n += 1) {
      const id = `seed_vehicle_${String(i * 2 + n + 1).padStart(3, '0')}`;
      const [make, model, fuelType] = pick(vehicles, i + n);
      const driver = seed.drivers[i];
      seed.vehicles.push({
        id,
        ownerId: driver.uid,
        make,
        model,
        year: 2018 + ((i + n) % 7),
        color: pick(['Black', 'White', 'Silver', 'Blue', 'Green', 'Red'], i + n),
        licensePlate: `SC-${String(i + 10).padStart(3, '0')}-${String.fromCharCode(65 + n)}G`,
        ownerName: driver.username,
        ownerPhotoUrl: driver.photoUrl,
        type: n === 1 && i % 5 === 0 ? 'van' : 'car',
        capacity: n === 1 && i % 5 === 0 ? 7 : 4,
        fuelType,
        imageUrl: `https://picsum.photos/seed/${id}/640/360`,
        imageUrls: [`https://picsum.photos/seed/${id}/640/360`],
        isActive: n === 0,
        isDefault: n === 0,
        verificationStatus: i % 6 === 0 ? 'pending' : 'verified',
        hasAC: true,
        hasCharger: i % 2 === 0,
        hasWifi: i % 4 === 0,
        petsAllowed: i % 3 === 0,
        smokingAllowed: i % 9 === 0,
        hasLuggage: true,
        totalRides: 10 + i * 3,
        averageRating: Number((4.2 + (i % 8) / 10).toFixed(1)),
        createdAt: isoDays(-90 + i),
        updatedAt: isoDays(-3),
      });
    }
  }
}

function buildEvents() {
  for (let i = 0; i < totals.events; i += 1) {
    const creator = seed.users[i % seed.users.length];
    const startsAt = isoDays(1 + (i % 75), 6 + (i % 12), (i % 4) * 15);
    const participantIds = seed.riders
      .slice(i % 10, (i % 10) + 12)
      .map((u) => u.uid);
    if (i % 4 === 0) participantIds.push(seed.drivers[i % seed.drivers.length].uid);
    const rideStatuses = Object.fromEntries(
      participantIds.slice(0, 10).map((uid, pIndex) => [
        uid,
        pick(['driving', 'need_ride', 'self_arranged'], i + pIndex),
      ]),
    );
    const loc = locationFor(i, i + 2);
    seed.events.push({
      id: `seed_event_${String(i + 1).padStart(3, '0')}`,
      creatorId: creator.uid,
      title: `${pick(['Sunrise', 'Tempo', 'Community', 'Weekend', 'City'], i)} Running Meetup ${i + 1}`,
      type: 'running',
      location: loc,
      startsAt,
      endsAt: isoDays(1 + (i % 75), 8 + (i % 12), (i % 4) * 15),
      description:
        'Seeded running event with realistic attendance, ride coordination, and enough volume to test picker/search UX.',
      organizerName: creator.username,
      imageUrl: `https://picsum.photos/seed/seed_event_${i + 1}/900/500`,
      participantIds,
      maxParticipants: 20 + (i % 60),
      isActive: i % 17 !== 0,
      linkedRideIds: [],
      rideStatuses,
      meetupPinLocation: loc,
      chatGroupId: `seed_event_chat_${String(i + 1).padStart(3, '0')}`,
      isRecurring: i % 9 === 0,
      recurringPattern: i % 9 === 0 ? 'weekly' : undefined,
      recurringEndDate: i % 9 === 0 ? isoDays(90, 18) : undefined,
      costSplitEnabled: i % 3 === 0,
      createdAt: isoDays(-30 + (i % 20)),
      updatedAt: isoDays(-2),
    });
  }
}

function buildRidesAndBookings() {
  for (let i = 0; i < totals.rides; i += 1) {
    const driver = seed.drivers[i % seed.drivers.length];
    const vehicle = seed.vehicles.find((v) => v.ownerId === driver.uid && v.isDefault) ?? seed.vehicles[0];
    const event = i % 3 === 0 ? seed.events[i % seed.events.length] : null;
    const origin = locationFor(i + 5);
    const destination = event?.location ?? locationFor(i + 11);
    const available = Math.min(vehicle.capacity, 3 + (i % 4));
    const acceptedBookings = i % available;
    const bookingIds = [];
    const tags = [];
    if (['electric', 'hybrid', 'pluginHybrid', 'hydrogen'].includes(vehicle.fuelType)) tags.push('eco');
    if (vehicle.verificationStatus === 'verified') tags.push('verified_driver');
    if (vehicle.hasAC || vehicle.hasWifi || vehicle.hasCharger) tags.push('premium');

    for (let b = 0; b < acceptedBookings + (i % 5 === 0 ? 1 : 0); b += 1) {
      const rider = seed.riders[(i + b * 7) % seed.riders.length];
      const id = `seed_booking_${String(seed.bookings.length + 1).padStart(4, '0')}`;
      const status = b < acceptedBookings ? 'accepted' : 'pending';
      bookingIds.push(id);
      seed.bookings.push({
        id,
        rideId: `seed_ride_${String(i + 1).padStart(4, '0')}`,
        passengerId: rider.uid,
        driverId: driver.uid,
        seatsBooked: 1 + ((i + b) % 2),
        status,
        pickupLocation: origin,
        dropoffLocation: destination,
        note: status === 'pending' ? 'Can I join from the main gate?' : 'Confirmed pickup at the marked location.',
        createdAt: isoDays(-2 + (b % 3), 10 + b),
        respondedAt: status === 'accepted' ? isoDays(-1, 11 + b) : undefined,
        pickupOtp: String(100000 + ((i + b) * 37) % 900000),
      });
    }

    const rideId = `seed_ride_${String(i + 1).padStart(4, '0')}`;
    const ride = {
      id: rideId,
      driverId: driver.uid,
      route: {
        origin,
        destination,
        waypoints: [],
        distanceKm: Number((4 + (i % 40) * 1.7).toFixed(1)),
        durationMinutes: 18 + (i % 85),
      },
      schedule: {
        departureTime: event?.startsAt ?? isoDays(1 + (i % 45), 6 + (i % 14), (i % 4) * 15),
        arrivalTime: undefined,
        flexibilityMinutes: pick([0, 10, 15, 20, 30], i),
        isRecurring: i % 20 === 0,
        recurringDays: i % 20 === 0 ? [1, 3, 5] : [],
        recurringEndDate: i % 20 === 0 ? isoDays(60, 12) : undefined,
      },
      capacity: { available, booked: acceptedBookings },
      pricing: {
        pricePerSeatInCents: {
          amountInCents: 500 + (i % 26) * 150,
          currency: 'EUR',
        },
      },
      preferences: {
        allowPets: i % 4 === 0,
        allowSmoking: i % 15 === 0,
        allowLuggage: i % 5 !== 0,
        isWomenOnly: i % 7 === 0,
        allowChat: true,
        maxDetourMinutes: pick([0, 10, 15, 20, 30, 45], i) || undefined,
      },
      eventId: event?.id,
      eventName: event?.title,
      status: acceptedBookings >= available ? 'full' : 'active',
      ridePhase: undefined,
      vehicleId: vehicle.id,
      vehicleInfo: `${vehicle.year} ${vehicle.color} ${vehicle.make} ${vehicle.model}`,
      bookingIds,
      bookings: [],
      reviewCount: i % 11,
      averageRating: Number((4 + (i % 10) / 10).toFixed(1)),
      xpReward: 50,
      notes: i % 6 === 0 ? 'Seed ride with strict pickup timing.' : undefined,
      tags,
      createdAt: isoDays(-8 + (i % 6)),
      updatedAt: isoDays(-1),
    };
    seed.rides.push(ride);
    if (event) event.linkedRideIds.push(rideId);
  }
}

function chatParticipant(user, isAdmin = false) {
  return {
    uid: user.uid,
    username: user.username,
    photoUrl: user.photoUrl,
    isAdmin,
    isMuted: false,
    lastSeenAt: isoDays(0, 8),
    joinedAt: isoDays(-20, 8),
  };
}

function addChat(chat, messageAuthors) {
  seed.chats.push(chat);
  const bodies = [
    'I can meet there.',
    'Thanks, see you soon.',
    'Can you share the exact pickup point?',
    'Running a few minutes late but still coming.',
    'Confirmed.',
  ];
  for (let i = 0; i < 5; i += 1) {
    const author = messageAuthors[i % messageAuthors.length];
    seed.messages.push({
      path: `chats/${chat.id}/messages/seed_msg_${String(i + 1).padStart(2, '0')}`,
      data: {
        id: `seed_msg_${String(i + 1).padStart(2, '0')}`,
        chatId: chat.id,
        senderId: author.uid,
        senderName: author.username,
        senderPhotoUrl: author.photoUrl,
        content: bodies[(i + chat.id.length) % bodies.length],
        type: 'text',
        status: 'read',
        reactions: i === 2 ? { '👍': [messageAuthors[0].uid] } : {},
        readBy: chat.participantIds,
        deliveredTo: chat.participantIds,
        isEdited: false,
        isDeleted: false,
        createdAt: isoDays(-1, 9 + i, i * 7),
      },
    });
  }
}

function buildPaymentsAndStats() {
  const now = new Date();
  const todayStart = startOfToday();
  const weekStart = startOfWeek();
  const monthStart = startOfMonth();
  const yesterday = new Date(todayStart.getFullYear(), todayStart.getMonth(), todayStart.getDate() - 1);
  const twoDaysAgo = new Date(todayStart.getFullYear(), todayStart.getMonth(), todayStart.getDate() - 2);
  const safeWeekDayOne = yesterday >= weekStart ? yesterday : todayStart;
  const safeWeekDayTwo = twoDaysAgo >= weekStart ? twoDaysAgo : safeWeekDayOne;
  const safeMonthDayOne = yesterday >= monthStart ? yesterday : todayStart;
  const safeMonthDayTwo = twoDaysAgo >= monthStart ? twoDaysAgo : safeMonthDayOne;
  const paymentDates = [
    new Date(now.getTime() - 2 * 60 * 60 * 1000),
    new Date(now.getTime() - 6 * 60 * 60 * 1000),
    addHours(safeWeekDayOne, 10),
    addHours(safeWeekDayTwo, 14),
    addHours(safeMonthDayOne, 9),
    addHours(safeMonthDayTwo, 16),
    dateAt(-45, 12),
    dateAt(-90, 12),
  ];

  for (let i = 0; i < seed.drivers.length; i += 1) {
    const driver = seed.drivers[i];
    const driverRides = seed.rides.filter((ride) => ride.driverId === driver.uid);
    for (let p = 0; p < paymentDates.length; p += 1) {
      const ride = driverRides[p % driverRides.length] ?? seed.rides[(i + p) % seed.rides.length];
      const rider = seed.riders[(i * 11 + p * 7) % seed.riders.length];
      const seatsBooked = 1 + ((i + p) % 2);
      const amountInCents = ride.pricing.pricePerSeatInCents.amountInCents * seatsBooked;
      const platformFeeInCents = Math.round(amountInCents * 0.12);
      const stripeFeeInCents = Math.round(amountInCents * 0.029) + 30;
      const driverEarningsInCents = Math.max(0, amountInCents - platformFeeInCents - stripeFeeInCents);
      const completedAt = paymentDates[p];
      const id = `seed_payment_${String(seed.payments.length + 1).padStart(5, '0')}`;

      seed.payments.push({
        id,
        rideId: ride.id,
        riderId: rider.uid,
        riderName: rider.username,
        driverId: driver.uid,
        driverName: driver.username,
        amountInCents,
        amount: amountInCents / 100,
        currency: 'EUR',
        status: 'succeeded',
        platformFeeInCents,
        platformFee: platformFeeInCents / 100,
        driverEarningsInCents,
        driverEarnings: driverEarningsInCents / 100,
        stripeFeeInCents,
        stripeFee: stripeFeeInCents / 100,
        paymentMethodType: pick(['card', 'applePay', 'googlePay'], i + p),
        paymentMethodLast4: String(1000 + ((i + p) * 137) % 9000),
        stripePaymentIntentId: `pi_seed_${String(seed.payments.length + 1).padStart(5, '0')}`,
        stripeCustomerId: rider.stripeCustomerId,
        seatsBooked,
        createdAt: new Date(completedAt.getTime() - 20 * 60 * 1000).toISOString(),
        updatedAt: completedAt.toISOString(),
        completedAt: completedAt.toISOString(),
        metadata: {
          seed: true,
          period: p < 2 ? 'today' : p < 4 ? 'this_week' : p < 6 ? 'this_month' : 'older',
        },
      });
    }
  }

  for (let i = 0; i < seed.drivers.length; i += 1) {
    const driver = seed.drivers[i];
    const payments = seed.payments.filter((payment) => payment.driverId === driver.uid);
    const totalEarningsInCents = payments.reduce((sum, payment) => sum + payment.driverEarningsInCents, 0);
    const totalPlatformFeesInCents = payments.reduce((sum, payment) => sum + payment.platformFeeInCents, 0);
    const totalStripeFeesInCents = payments.reduce((sum, payment) => sum + payment.stripeFeeInCents, 0);

    const inPeriod = (payment, start) => new Date(payment.completedAt) >= start;
    const todayPayments = payments.filter((payment) => inPeriod(payment, todayStart));
    const weekPayments = payments.filter((payment) => inPeriod(payment, weekStart));
    const monthPayments = payments.filter((payment) => inPeriod(payment, monthStart));
    const latestPayment = payments
      .map((payment) => new Date(payment.completedAt))
      .sort((a, b) => b.getTime() - a.getTime())[0];

    seed.driverStats.push({
      driverId: driver.uid,
      rating: Number((4.1 + (i % 9) / 10).toFixed(1)),
      totalRides: payments.length,
      ridesToday: todayPayments.length,
      ridesThisWeek: weekPayments.length,
      ridesThisMonth: monthPayments.length,
      pendingRequests: i % 5,
      totalEarningsInCents,
      totalPlatformFeesInCents,
      totalStripeFeesInCents,
      earningsTodayInCents: todayPayments.reduce((sum, payment) => sum + payment.driverEarningsInCents, 0),
      earningsThisWeekInCents: weekPayments.reduce((sum, payment) => sum + payment.driverEarningsInCents, 0),
      earningsThisMonthInCents: monthPayments.reduce((sum, payment) => sum + payment.driverEarningsInCents, 0),
      totalEarnings: totalEarningsInCents / 100,
      totalPlatformFees: totalPlatformFeesInCents / 100,
      totalStripeFees: totalStripeFeesInCents / 100,
      earningsToday: todayPayments.reduce((sum, payment) => sum + payment.driverEarningsInCents, 0) / 100,
      earningsThisWeek: weekPayments.reduce((sum, payment) => sum + payment.driverEarningsInCents, 0) / 100,
      earningsThisMonth: monthPayments.reduce((sum, payment) => sum + payment.driverEarningsInCents, 0) / 100,
      totalSpentInCents: 0,
      totalDistance: Number(payments.reduce((sum, payment) => {
        const ride = seed.rides.find((item) => item.id === payment.rideId);
        return sum + (ride?.route.distanceKm ?? 0);
      }, 0).toFixed(1)),
      lastRideAt: latestPayment?.toISOString(),
      lastUpdatedAt: new Date().toISOString(),
    });
  }
}

function buildChatsReviewsStats() {
  for (let i = 0; i < totals.privateChats; i += 1) {
    const driver = seed.drivers[i % seed.drivers.length];
    const rider = seed.riders[(i * 3) % seed.riders.length];
    addChat(
      {
        id: `seed_private_chat_${String(i + 1).padStart(3, '0')}`,
        type: 'private',
        participants: [chatParticipant(driver), chatParticipant(rider)],
        participantIds: [driver.uid, rider.uid],
        lastMessageContent: 'Confirmed.',
        lastMessageSenderId: rider.uid,
        lastMessageSenderName: rider.username,
        lastMessageType: 'text',
        lastMessageAt: isoDays(0, 9 + (i % 8)),
        unreadCounts: { [driver.uid]: i % 3, [rider.uid]: (i + 1) % 2 },
        mutedBy: {},
        pinnedBy: i % 6 === 0 ? { [rider.uid]: true } : {},
        deletedAtBy: {},
        clearedAtBy: {},
        isActive: true,
        createdAt: isoDays(-20 + (i % 8)),
        updatedAt: isoDays(0, 9 + (i % 8)),
      },
      [driver, rider],
    );
  }

  for (let i = 0; i < 24; i += 1) {
    const event = seed.events[i];
    const participants = event.participantIds
      .slice(0, 12)
      .map((id) => seed.users.find((u) => u.uid === id))
      .filter(Boolean);
    addChat(
      {
        id: event.chatGroupId,
        type: 'eventGroup',
        participants: participants.map((user, index) => chatParticipant(user, index === 0)),
        participantIds: participants.map((user) => user.uid),
        groupName: event.title,
        description: 'Seeded event group chat',
        eventId: event.id,
        lastMessageContent: 'Confirmed.',
        lastMessageSenderId: participants[0]?.uid,
        lastMessageSenderName: participants[0]?.username,
        lastMessageType: 'text',
        lastMessageAt: isoDays(0, 13),
        unreadCounts: {},
        mutedBy: {},
        pinnedBy: {},
        deletedAtBy: {},
        clearedAtBy: {},
        isActive: true,
        createdAt: isoDays(-10),
        updatedAt: isoDays(0, 13),
      },
      participants,
    );
  }

  for (let i = 0; i < 40; i += 1) {
    const ride = seed.rides[i];
    const driver = seed.drivers.find((user) => user.uid === ride.driverId);
    const rider = seed.riders[(i * 5) % seed.riders.length];
    seed.reviews.push({
      id: `seed_review_${String(i + 1).padStart(3, '0')}`,
      rideId: ride.id,
      reviewerId: rider.uid,
      revieweeId: driver.uid,
      rating: 4 + (i % 2),
      comment: pick(
        [
          'Clean vehicle and clear pickup instructions.',
          'Friendly driver and on-time departure.',
          'Good route knowledge and safe driving.',
          'Helpful coordination before the event.',
        ],
        i,
      ),
      createdAt: isoDays(-15 + (i % 12)),
      updatedAt: isoDays(-14 + (i % 12)),
    });
  }

  buildPaymentsAndStats();
}

async function main() {
  console.log(`Seeding Firebase emulators for ${projectId}`);
  console.log(`Firestore: ${firestoreHost}`);
  console.log(`Auth: ${authHost}`);

  if (shouldClean) {
    const deleted = {};
    for (const collection of [
      'vehicles',
      'events',
      'rides',
      'bookings',
      'chats',
      'payments',
      'reviews',
      'driver_stats',
    ]) {
      deleted[collection] = await deleteSeedDocs(collection);
    }
    console.log('Deleted previous seed docs:', deleted);
  } else {
    console.log('Skipping cleanup; deterministic seed IDs will be overwritten.');
  }

  await buildUsers();
  buildVehicles();
  buildEvents();
  buildRidesAndBookings();
  buildChatsReviewsStats();

  await writeMany(seed.users, (user) => upsertDoc(`users/${user.uid}`, user), 'users');
  await writeMany(seed.vehicles, (vehicle) => upsertDoc(`vehicles/${vehicle.id}`, vehicle), 'vehicles');
  await writeMany(seed.events, (event) => upsertDoc(`events/${event.id}`, event), 'events');
  await writeMany(seed.rides, (ride) => upsertDoc(`rides/${ride.id}`, ride), 'rides');
  await writeMany(seed.bookings, (booking) => upsertDoc(`bookings/${booking.id}`, booking), 'bookings');
  await writeMany(seed.chats, (chat) => upsertDoc(`chats/${chat.id}`, chat), 'chats');
  await writeMany(seed.messages, (message) => upsertDoc(message.path, message.data), 'messages');
  await writeMany(seed.payments, (payment) => upsertDoc(`payments/${payment.id}`, payment), 'payments');
  await writeMany(seed.reviews, (review) => upsertDoc(`reviews/${review.id}`, review), 'reviews');
  await writeMany(
    seed.driverStats,
    (stats) => upsertDoc(`driver_stats/${stats.driverId}`, stats),
    'driver_stats',
  );

  console.log('\nSeed complete.');
  console.table({
    authUsers: seed.users.length,
    firestoreUsers: seed.users.length,
    vehicles: seed.vehicles.length,
    events: seed.events.length,
    rides: seed.rides.length,
    bookings: seed.bookings.length,
    chats: seed.chats.length,
    messages: seed.messages.length,
    payments: seed.payments.length,
    reviews: seed.reviews.length,
    driverStats: seed.driverStats.length,
  });
  console.log(`Seed login password for all users: ${password}`);
  console.log('Example accounts:');
  console.log('  seed.driver.01@sportconnect.test');
  console.log('  seed.rider.01@sportconnect.test');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
