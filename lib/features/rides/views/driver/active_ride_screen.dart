import 'package:flutter/widgets.dart';
import 'package:sport_connect/features/rides/views/driver/driver_view_ride_screen.dart';

class DriverActiveRideScreen extends StatelessWidget {
  const DriverActiveRideScreen({required this.rideId, super.key});

  final String rideId;

  @override
  Widget build(BuildContext context) {
    return DriverViewRideScreen(rideId: rideId);
  }
}
