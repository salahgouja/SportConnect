import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'nominatim_client.g.dart';

@RestApi()
abstract class NominatimClient {
  factory NominatimClient(Dio dio, {String baseUrl}) = _NominatimClient;

  @GET('/search')
  Future<List<NominatimJsonDto>> searchPlaces(
    @Query('q') String query,
    @Query('format') String format,
    @Query('addressdetails') int addressDetails,
    @Query('limit') int limit,
    @Query('accept-language') String acceptLanguage,
    @Query('lat') double? latitude,
    @Query('lon') double? longitude,
    @Query('countrycodes') String? countryCode,
    @Header('User-Agent') String userAgent,
  );

  @GET('/reverse')
  Future<NominatimJsonDto> reverseGeocode(
    @Query('lat') double latitude,
    @Query('lon') double longitude,
    @Query('format') String format,
    @Query('addressdetails') int addressDetails,
    @Query('accept-language') String acceptLanguage,
    @Header('User-Agent') String userAgent,
  );
}

class NominatimJsonDto {
  const NominatimJsonDto(this.json);

  factory NominatimJsonDto.fromJson(Map<String, dynamic> json) =>
      NominatimJsonDto(json);

  final Map<String, dynamic> json;

  Map<String, dynamic> toJson() => json;
}
