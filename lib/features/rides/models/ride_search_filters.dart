import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/models/location/location_point.dart';

part 'ride_search_filters.freezed.dart';
part 'ride_search_filters.g.dart';

/// Ride search filters
@freezed
abstract class RideSearchFilters with _$RideSearchFilters {
  const factory RideSearchFilters({
    LocationPoint? origin,
    LocationPoint? destination,
    @TimestampConverter() DateTime? departureDate,
    @TimestampConverter() DateTime? departureTimeFrom,
    @TimestampConverter() DateTime? departureTimeTo,
    @Default(1) int minSeats,
    double? maxPrice,
    double? maxRadiusKm,
    @Default(false) bool allowPets,
    @Default(false) bool allowSmoking,
    @Default(false) bool womenOnly,
    double? minDriverRating,
    @Default('departure_time') String sortBy,
    @Default(true) bool sortAscending,
  }) = _RideSearchFilters;

  factory RideSearchFilters.fromJson(Map<String, dynamic> json) =>
      _$RideSearchFiltersFromJson(json);
}
