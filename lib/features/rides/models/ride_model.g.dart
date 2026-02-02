// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationPoint _$LocationPointFromJson(Map json) => _LocationPoint(
  address: json['address'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  placeId: json['placeId'] as String?,
  city: json['city'] as String?,
);

Map<String, dynamic> _$LocationPointToJson(_LocationPoint instance) =>
    <String, dynamic>{
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'placeId': instance.placeId,
      'city': instance.city,
    };

_RouteWaypoint _$RouteWaypointFromJson(Map json) => _RouteWaypoint(
  location: LocationPoint.fromJson(
    Map<String, dynamic>.from(json['location'] as Map),
  ),
  order: (json['order'] as num?)?.toInt() ?? 0,
  estimatedArrival: const TimestampConverter().fromJson(
    json['estimatedArrival'],
  ),
);

Map<String, dynamic> _$RouteWaypointToJson(_RouteWaypoint instance) =>
    <String, dynamic>{
      'location': instance.location.toJson(),
      'order': instance.order,
      'estimatedArrival': const TimestampConverter().toJson(
        instance.estimatedArrival,
      ),
    };

_RideBooking _$RideBookingFromJson(Map json) => _RideBooking(
  id: json['id'] as String,
  passengerId: json['passengerId'] as String,
  passengerName: json['passengerName'] as String? ?? 'Unknown Passenger',
  passengerPhotoUrl: json['passengerPhotoUrl'] as String?,
  seatsBooked: (json['seatsBooked'] as num?)?.toInt() ?? 1,
  status:
      $enumDecodeNullable(_$BookingStatusEnumMap, json['status']) ??
      BookingStatus.pending,
  pickupLocation: json['pickupLocation'] == null
      ? null
      : LocationPoint.fromJson(
          Map<String, dynamic>.from(json['pickupLocation'] as Map),
        ),
  dropoffLocation: json['dropoffLocation'] == null
      ? null
      : LocationPoint.fromJson(
          Map<String, dynamic>.from(json['dropoffLocation'] as Map),
        ),
  note: json['note'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  respondedAt: const TimestampConverter().fromJson(json['respondedAt']),
);

Map<String, dynamic> _$RideBookingToJson(_RideBooking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'passengerId': instance.passengerId,
      'passengerName': instance.passengerName,
      'passengerPhotoUrl': instance.passengerPhotoUrl,
      'seatsBooked': instance.seatsBooked,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'pickupLocation': instance.pickupLocation?.toJson(),
      'dropoffLocation': instance.dropoffLocation?.toJson(),
      'note': instance.note,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'respondedAt': const TimestampConverter().toJson(instance.respondedAt),
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.accepted: 'accepted',
  BookingStatus.rejected: 'rejected',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.completed: 'completed',
};

_RideReview _$RideReviewFromJson(Map json) => _RideReview(
  id: json['id'] as String,
  reviewerId: json['reviewerId'] as String,
  reviewerName: json['reviewerName'] as String,
  reviewerPhotoUrl: json['reviewerPhotoUrl'] as String?,
  revieweeId: json['revieweeId'] as String,
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$RideReviewToJson(_RideReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reviewerId': instance.reviewerId,
      'reviewerName': instance.reviewerName,
      'reviewerPhotoUrl': instance.reviewerPhotoUrl,
      'revieweeId': instance.revieweeId,
      'rating': instance.rating,
      'comment': instance.comment,
      'tags': instance.tags,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

_RideModel _$RideModelFromJson(Map json) => _RideModel(
  id: json['id'] as String,
  driverId: json['driverId'] as String,
  driverName: json['driverName'] as String,
  driverPhotoUrl: json['driverPhotoUrl'] as String?,
  driverRating: (json['driverRating'] as num?)?.toDouble(),
  origin: LocationPoint.fromJson(
    Map<String, dynamic>.from(json['origin'] as Map),
  ),
  destination: LocationPoint.fromJson(
    Map<String, dynamic>.from(json['destination'] as Map),
  ),
  waypoints:
      (json['waypoints'] as List<dynamic>?)
          ?.map(
            (e) => RouteWaypoint.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList() ??
      const [],
  distanceKm: (json['distanceKm'] as num?)?.toDouble(),
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  polylineEncoded: json['polylineEncoded'] as String?,
  departureTime: const RequiredTimestampConverter().fromJson(
    json['departureTime'],
  ),
  arrivalTime: const TimestampConverter().fromJson(json['arrivalTime']),
  flexibilityMinutes: (json['flexibilityMinutes'] as num?)?.toInt() ?? 15,
  availableSeats: (json['availableSeats'] as num?)?.toInt() ?? 3,
  bookedSeats: (json['bookedSeats'] as num?)?.toInt() ?? 0,
  pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String?,
  isPriceNegotiable: json['isPriceNegotiable'] as bool? ?? false,
  acceptsOnlinePayment: json['acceptsOnlinePayment'] as bool? ?? false,
  status:
      $enumDecodeNullable(_$RideStatusEnumMap, json['status']) ??
      RideStatus.draft,
  allowPets: json['allowPets'] as bool? ?? false,
  allowSmoking: json['allowSmoking'] as bool? ?? false,
  allowLuggage: json['allowLuggage'] as bool? ?? true,
  isWomenOnly: json['isWomenOnly'] as bool? ?? false,
  allowChat: json['allowChat'] as bool? ?? true,
  maxDetourMinutes: (json['maxDetourMinutes'] as num?)?.toInt(),
  vehicleId: json['vehicleId'] as String?,
  vehicleInfo: json['vehicleInfo'] as String?,
  bookings:
      (json['bookings'] as List<dynamic>?)
          ?.map(
            (e) => RideBooking.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList() ??
      const [],
  reviews:
      (json['reviews'] as List<dynamic>?)
          ?.map((e) => RideReview.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  isRecurring: json['isRecurring'] as bool? ?? false,
  recurringDays:
      (json['recurringDays'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  recurringEndDate: const TimestampConverter().fromJson(
    json['recurringEndDate'],
  ),
  xpReward: (json['xpReward'] as num?)?.toInt() ?? 50,
  notes: json['notes'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$RideModelToJson(_RideModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'driverName': instance.driverName,
      'driverPhotoUrl': instance.driverPhotoUrl,
      'driverRating': instance.driverRating,
      'origin': instance.origin.toJson(),
      'destination': instance.destination.toJson(),
      'waypoints': instance.waypoints.map((e) => e.toJson()).toList(),
      'distanceKm': instance.distanceKm,
      'durationMinutes': instance.durationMinutes,
      'polylineEncoded': instance.polylineEncoded,
      'departureTime': const RequiredTimestampConverter().toJson(
        instance.departureTime,
      ),
      'arrivalTime': const TimestampConverter().toJson(instance.arrivalTime),
      'flexibilityMinutes': instance.flexibilityMinutes,
      'availableSeats': instance.availableSeats,
      'bookedSeats': instance.bookedSeats,
      'pricePerSeat': instance.pricePerSeat,
      'currency': instance.currency,
      'isPriceNegotiable': instance.isPriceNegotiable,
      'acceptsOnlinePayment': instance.acceptsOnlinePayment,
      'status': _$RideStatusEnumMap[instance.status]!,
      'allowPets': instance.allowPets,
      'allowSmoking': instance.allowSmoking,
      'allowLuggage': instance.allowLuggage,
      'isWomenOnly': instance.isWomenOnly,
      'allowChat': instance.allowChat,
      'maxDetourMinutes': instance.maxDetourMinutes,
      'vehicleId': instance.vehicleId,
      'vehicleInfo': instance.vehicleInfo,
      'bookings': instance.bookings.map((e) => e.toJson()).toList(),
      'reviews': instance.reviews.map((e) => e.toJson()).toList(),
      'isRecurring': instance.isRecurring,
      'recurringDays': instance.recurringDays,
      'recurringEndDate': const TimestampConverter().toJson(
        instance.recurringEndDate,
      ),
      'xpReward': instance.xpReward,
      'notes': instance.notes,
      'tags': instance.tags,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$RideStatusEnumMap = {
  RideStatus.draft: 'draft',
  RideStatus.active: 'active',
  RideStatus.full: 'full',
  RideStatus.inProgress: 'inProgress',
  RideStatus.completed: 'completed',
  RideStatus.cancelled: 'cancelled',
};

_RideSearchFilters _$RideSearchFiltersFromJson(Map json) => _RideSearchFilters(
  origin: json['origin'] == null
      ? null
      : LocationPoint.fromJson(
          Map<String, dynamic>.from(json['origin'] as Map),
        ),
  destination: json['destination'] == null
      ? null
      : LocationPoint.fromJson(
          Map<String, dynamic>.from(json['destination'] as Map),
        ),
  departureDate: const TimestampConverter().fromJson(json['departureDate']),
  departureTimeFrom: const TimestampConverter().fromJson(
    json['departureTimeFrom'],
  ),
  departureTimeTo: const TimestampConverter().fromJson(json['departureTimeTo']),
  minSeats: (json['minSeats'] as num?)?.toInt() ?? 1,
  maxPrice: (json['maxPrice'] as num?)?.toDouble(),
  maxRadiusKm: (json['maxRadiusKm'] as num?)?.toDouble(),
  allowPets: json['allowPets'] as bool? ?? false,
  allowSmoking: json['allowSmoking'] as bool? ?? false,
  womenOnly: json['womenOnly'] as bool? ?? false,
  minDriverRating: (json['minDriverRating'] as num?)?.toDouble(),
  sortBy: json['sortBy'] as String? ?? 'departure_time',
  sortAscending: json['sortAscending'] as bool? ?? true,
);

Map<String, dynamic> _$RideSearchFiltersToJson(
  _RideSearchFilters instance,
) => <String, dynamic>{
  'origin': instance.origin?.toJson(),
  'destination': instance.destination?.toJson(),
  'departureDate': const TimestampConverter().toJson(instance.departureDate),
  'departureTimeFrom': const TimestampConverter().toJson(
    instance.departureTimeFrom,
  ),
  'departureTimeTo': const TimestampConverter().toJson(
    instance.departureTimeTo,
  ),
  'minSeats': instance.minSeats,
  'maxPrice': instance.maxPrice,
  'maxRadiusKm': instance.maxRadiusKm,
  'allowPets': instance.allowPets,
  'allowSmoking': instance.allowSmoking,
  'womenOnly': instance.womenOnly,
  'minDriverRating': instance.minDriverRating,
  'sortBy': instance.sortBy,
  'sortAscending': instance.sortAscending,
};
