import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/talker_service.dart';

part 'http_service.g.dart';

/// Singleton HTTP client shared across all services.
///
/// Interceptors applied in order:
///   1. TalkerDioLogger               — structured request/response logging
///   2. _RetryInterceptor             — exponential back-off (3 retries) on 5xx/timeouts
///   3. _NominatimRateLimitInterceptor — serialises Nominatim calls to ≤ 1 req/s (OSMF ToS)
class HttpService {
  HttpService._()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: AppConstants.httpConnectTimeout,
          receiveTimeout: AppConstants.httpReceiveTimeout,
        ),
      ) {
    _dio
      ..addTalkerInterceptor()
      ..interceptors.add(_RetryInterceptor(_dio))
      ..interceptors.add(_NominatimRateLimitInterceptor());
  }

  static HttpService? _instance;

  static HttpService get instance {
    _instance ??= HttpService._();
    return _instance!;
  }

  final Dio _dio;

  Dio get dio => _dio;
}

@Riverpod(keepAlive: true)
HttpService httpService(Ref ref) => HttpService.instance;

// ─────────────────────────────────────────────────────────────────────────────
// Retry interceptor — exponential back-off with ±25 % jitter
//
// Retries on: connection errors, send/receive/connect timeouts, 429, 5xx.
// Respects Retry-After response header (seconds only).
// Does NOT retry 4xx (except 429) — those are caller errors.
// ─────────────────────────────────────────────────────────────────────────────

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;

  static const _maxRetries = 3;
  static const _retryKey = '_retryCount';
  // Base back-off: 1 s → 2 s → 4 s
  static const _baseDelaysMs = [1000, 2000, 4000];

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = (err.requestOptions.extra[_retryKey] as int?) ?? 0;

    if (!_shouldRetry(err) || retryCount >= _maxRetries) {
      return handler.next(err);
    }

    final retryAfterMs = _parseRetryAfterMs(err.response?.headers);
    final baseMs =
        retryAfterMs ??
        _baseDelaysMs[retryCount.clamp(0, _baseDelaysMs.length - 1)];
    // Jitter multiplier in [0.75, 1.25] to spread concurrent retries
    final jitter = Random().nextDouble() * 0.5 + 0.75;
    final delayMs = (baseMs * jitter).round();

    TalkerService.warning(
      'HTTP retry ${retryCount + 1}/$_maxRetries in ${delayMs}ms '
      '[${err.type.name}] ${err.requestOptions.path}',
    );

    await Future<void>.delayed(Duration(milliseconds: delayMs));

    final opts = err.requestOptions..extra[_retryKey] = retryCount + 1;

    try {
      final response = await _dio.fetch<dynamic>(opts);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = err.response?.statusCode ?? 0;
        return code == 429 || code >= 500;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  /// Parses `Retry-After: <seconds>` → milliseconds. Returns null if absent.
  int? _parseRetryAfterMs(Headers? headers) {
    final raw = headers?.value('retry-after');
    if (raw == null) return null;
    final seconds = int.tryParse(raw.trim());
    return seconds != null ? seconds * 1000 : null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nominatim rate-limit interceptor
//
// OSMF Nominatim ToS cap: 1 request / second from a single IP.
// All Nominatim requests are serialised with a minimum 1.1 s gap.
// Non-Nominatim requests pass through immediately — no queuing.
// ─────────────────────────────────────────────────────────────────────────────

class _NominatimRateLimitInterceptor extends Interceptor {
  static const _host = 'nominatim.openstreetmap.org';
  static const _minGap = Duration(milliseconds: 1100);

  DateTime? _lastCall;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.uri.host.contains(_host)) {
      handler.next(options);
      return;
    }

    final now = DateTime.now();
    if (_lastCall != null) {
      final elapsed = now.difference(_lastCall!);
      if (elapsed < _minGap) {
        await Future<void>.delayed(_minGap - elapsed);
      }
    }
    _lastCall = DateTime.now();
    handler.next(options);
  }
}
