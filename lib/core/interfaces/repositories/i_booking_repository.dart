import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';

/// Booking operations repository interface.
abstract class IBookingRepository {
  Future<String> createBooking(RideBooking booking);
  Future<RideBooking?> getBookingById(String bookingId);
  Stream<RideBooking?> streamBookingById(String bookingId);
  Future<List<RideBooking>> getBookingsByRideId(String rideId);
  Stream<List<RideBooking>> streamBookingsByRideId(String rideId);
  Future<List<RideBooking>> getBookingsByPassengerId(String passengerId);
  Stream<List<RideBooking>> streamBookingsByPassengerId(String passengerId);

  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
  });

  Future<void> updateBooking(RideBooking booking);
  Future<void> deleteBooking(String bookingId);
  Stream<List<RideBooking>> streamActiveBookingsByPassengerId(
    String passengerId,
  );
  Stream<List<RideBooking>> streamPendingBookingsByRideId(String rideId);
}
