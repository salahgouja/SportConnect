import 'package:dio/dio.dart';

class NominatimClient {
  NominatimClient(this._dio, {required this.baseUrl});

  final Dio _dio;
  final String baseUrl;

  Future<List<Map<String, dynamic>>> searchPlaces(
    String query,
    String format,
    int addressDetails,
    int limit,
    String acceptLanguage,
    double? latitude,
    double? longitude,
    String? countryCode,
    String userAgent,
  ) async {
    final response = await _dio.get<List<dynamic>>(
      '$baseUrl/search',
      queryParameters: {
        'q': query,
        'format': format,
        'addressdetails': addressDetails,
        'limit': limit,
        'accept-language': acceptLanguage,
        'lat': ?latitude,
        'lon': ?longitude,
        if (countryCode != null && countryCode.isNotEmpty)
          'countrycodes': countryCode,
      },
      options: Options(
        headers: {
          'User-Agent': userAgent,
        },
      ),
    );

    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Map<String, dynamic>.from)
        .toList();
  }

  Future<Map<String, dynamic>> reverseGeocode(
    double latitude,
    double longitude,
    String format,
    int addressDetails,
    String acceptLanguage,
    String userAgent,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/reverse',
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'format': format,
        'addressdetails': addressDetails,
        'accept-language': acceptLanguage,
      },
      options: Options(
        headers: {
          'User-Agent': userAgent,
        },
      ),
    );

    return response.data ?? <String, dynamic>{};
  }
}
