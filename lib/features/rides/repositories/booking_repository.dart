import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';

part 'booking_repository.g.dart';

/// Repository for managing ride bookings
/// Bookings are now stored separately from rides for better scalability
class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository(this._firestore);

  CollectionReference<RideBooking> get _bookingsCollection => _firestore
      .collection('bookings')
      .withConverter<RideBooking>(
        fromFirestore: (snap, _) =>
            RideBooking.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (booking, _) => booking.toJson(),
      );

  /// Raw doc ref used only for writes that need FieldValue (e.g. serverTimestamp).
  DocumentReference<Map<String, dynamic>> _rawBookingDoc(String id) =>
      _firestore.collection('bookings').doc(id);

  /// Create a new booking
  Future<String> createBooking(RideBooking booking) async {
    final docRef = _bookingsCollection.doc(booking.id);
    await docRef.set(booking);
    return booking.id;
  }

  /// Get booking by ID
  Future<RideBooking?> getBookingById(String bookingId) async {
    final doc = await _bookingsCollection.doc(bookingId).get();
    return doc.data();
  }

  /// Stream booking by ID (real-time updates)
  Stream<RideBooking?> streamBookingById(String bookingId) {
    return _bookingsCollection
        .doc(bookingId)
        .snapshots()
        .map((doc) => doc.data());
  }

  /// Get bookings for a specific ride
  Future<List<RideBooking>> getBookingsByRideId(String rideId) async {
    final query = await _bookingsCollection
        .where('rideId', isEqualTo: rideId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  /// Stream bookings for a specific ride (real-time)
  Stream<List<RideBooking>> streamBookingsByRideId(String rideId) {
    return _bookingsCollection
        .where('rideId', isEqualTo: rideId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get bookings for a specific passenger
  Future<List<RideBooking>> getBookingsByPassengerId(String passengerId) async {
    final query = await _bookingsCollection
        .where('passengerId', isEqualTo: passengerId)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  /// Stream bookings for a specific passenger (real-time)
  Stream<List<RideBooking>> streamBookingsByPassengerId(String passengerId) {
    return _bookingsCollection
        .where('passengerId', isEqualTo: passengerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Update booking status
  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    await _rawBookingDoc(
      bookingId,
    ).update({'status': newStatus.name, 'respondedAt': DateTime.now()});
  }

  /// Update booking
  Future<void> updateBooking(RideBooking booking) async {
    await _bookingsCollection
        .doc(booking.id)
        .set(booking, SetOptions(merge: true));
  }

  /// Delete booking
  Future<void> deleteBooking(String bookingId) async {
    await _bookingsCollection.doc(bookingId).delete();
  }

  /// Get active bookings (pending or accepted)
  Stream<List<RideBooking>> streamActiveBookingsByPassengerId(
    String passengerId,
  ) {
    return _bookingsCollection
        .where('passengerId', isEqualTo: passengerId)
        .where('status', whereIn: ['pending', 'accepted'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get pending bookings for a ride
  Stream<List<RideBooking>> streamPendingBookingsByRideId(String rideId) {
    return _bookingsCollection
        .where('rideId', isEqualTo: rideId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}

@Riverpod(keepAlive: true)
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository(FirebaseFirestore.instance);
}
