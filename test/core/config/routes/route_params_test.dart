import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sport_connect/core/config/routes/route_params.dart';

import 'route_params_test.mocks.dart';

@GenerateMocks([GoRouterState])
void main() {
  group('RouteParams', () {
    late RouteParams routeParams;
    late MockGoRouterState mockState;

    /// Helper to create a mock GoRouterState with test data
    MockGoRouterState createMockState({
      Map<String, String> pathParameters = const {},
      Map<String, String> queryParameters = const {},
      Object? extra,
    }) {
      final uri = Uri(
        path: '/test',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      final mock = MockGoRouterState();
      when(mock.uri).thenReturn(uri);
      when(mock.matchedLocation).thenReturn('/test');
      when(mock.name).thenReturn('test');
      when(mock.path).thenReturn('/test');
      when(mock.pathParameters).thenReturn(pathParameters);
      when(mock.extra).thenReturn(extra);
      when(mock.pageKey).thenReturn(const ValueKey('test'));
      when(mock.error).thenReturn(null);

      return mock;
    }

    group('String Parameters', () {
      test('getString should return path parameter when it exists', () {
        mockState = createMockState(pathParameters: {'userId': '123'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getString('userId');

        expect(result, equals('123'));
      });

      test('getString should return null when parameter does not exist', () {
        mockState = createMockState(pathParameters: {});
        routeParams = RouteParams(mockState);

        final result = routeParams.getString('missingParam');

        expect(result, isNull);
      });

      test('getStringOrThrow should return parameter when it exists', () {
        mockState = createMockState(pathParameters: {'chatId': 'chat_456'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getStringOrThrow('chatId');

        expect(result, equals('chat_456'));
      });

      test(
        'getStringOrThrow should throw ArgumentError when parameter missing',
        () {
          mockState = createMockState(pathParameters: {});
          routeParams = RouteParams(mockState);

          expect(
            () => routeParams.getStringOrThrow('requiredParam'),
            throwsA(
              isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Missing required parameter: requiredParam'),
              ),
            ),
          );
        },
      );
    });

    group('Query Parameters', () {
      test('getQuery should return query parameter when it exists', () {
        mockState = createMockState(queryParameters: {'search': 'flutter'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getQuery('search');

        expect(result, equals('flutter'));
      });

      test(
        'getQuery should return null when query parameter does not exist',
        () {
          mockState = createMockState(queryParameters: {});
          routeParams = RouteParams(mockState);

          final result = routeParams.getQuery('missingQuery');

          expect(result, isNull);
        },
      );

      test('getQueryOrDefault should return parameter when it exists', () {
        mockState = createMockState(queryParameters: {'page': '2'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getQueryOrDefault('page', '1');

        expect(result, equals('2'));
      });

      test(
        'getQueryOrDefault should return default when parameter missing',
        () {
          mockState = createMockState(queryParameters: {});
          routeParams = RouteParams(mockState);

          final result = routeParams.getQueryOrDefault('page', '1');

          expect(result, equals('1'));
        },
      );
    });

    group('Boolean Parameters', () {
      test('getBool should return true for "true" string', () {
        mockState = createMockState(queryParameters: {'isActive': 'true'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getBool('isActive');

        expect(result, isTrue);
      });

      test('getBool should return false for "false" string', () {
        mockState = createMockState(queryParameters: {'isActive': 'false'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getBool('isActive');

        expect(result, isFalse);
      });

      test('getBool should be case-insensitive', () {
        mockState = createMockState(queryParameters: {'isActive': 'TRUE'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getBool('isActive');

        expect(result, isTrue);
      });

      test('getBool should return default value when parameter missing', () {
        mockState = createMockState(queryParameters: {});
        routeParams = RouteParams(mockState);

        final result = routeParams.getBool('isActive', defaultValue: true);

        expect(result, isTrue);
      });

      test('getBool should return false as default when not specified', () {
        mockState = createMockState(queryParameters: {});
        routeParams = RouteParams(mockState);

        final result = routeParams.getBool('missingParam');

        expect(result, isFalse);
      });
    });

    group('Integer Parameters', () {
      test('getInt should parse integer from path parameter', () {
        mockState = createMockState(pathParameters: {'id': '42'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getInt('id');

        expect(result, equals(42));
      });

      test('getInt should parse integer from query parameter', () {
        mockState = createMockState(queryParameters: {'count': '10'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getInt('count');

        expect(result, equals(10));
      });

      test('getInt should return null for non-numeric value', () {
        mockState = createMockState(pathParameters: {'id': 'invalid'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getInt('id');

        expect(result, isNull);
      });

      test('getInt should return null when parameter missing', () {
        mockState = createMockState(pathParameters: {});
        routeParams = RouteParams(mockState);

        final result = routeParams.getInt('missingParam');

        expect(result, isNull);
      });

      test('getInt should handle negative integers', () {
        mockState = createMockState(pathParameters: {'offset': '-5'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getInt('offset');

        expect(result, equals(-5));
      });
    });

    group('Extra Data', () {
      test('getExtra should return typed extra data', () {
        mockState = createMockState(extra: {'data': 'value'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getExtra<Map<String, String>>();

        expect(result, isA<Map<String, String>>());
        expect(result?['data'], equals('value'));
      });

      test('getExtra should return null when extra data is null', () {
        mockState = createMockState(extra: null);
        routeParams = RouteParams(mockState);

        final result = routeParams.getExtra<String>();

        expect(result, isNull);
      });

      test('getExtra should return null when type does not match', () {
        mockState = createMockState(extra: 'string value');
        routeParams = RouteParams(mockState);

        final result = routeParams.getExtra<int>();

        expect(result, isNull);
      });

      test('getExtraOrThrow should return typed extra data', () {
        const testData = 'test value';
        mockState = createMockState(extra: testData);
        routeParams = RouteParams(mockState);

        final result = routeParams.getExtraOrThrow<String>();

        expect(result, equals(testData));
      });

      test('getExtraOrThrow should throw when type mismatch', () {
        mockState = createMockState(extra: 'string value');
        routeParams = RouteParams(mockState);

        expect(
          () => routeParams.getExtraOrThrow<int>(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Expected extra data of type int'),
            ),
          ),
        );
      });

      test('getExtraOrThrow should throw when extra is null', () {
        mockState = createMockState(extra: null);
        routeParams = RouteParams(mockState);

        expect(
          () => routeParams.getExtraOrThrow<String>(),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Extension Method', () {
      test('GoRouterState extension should provide params property', () {
        mockState = createMockState(pathParameters: {'id': '123'});

        final params = mockState.params;

        expect(params, isA<RouteParams>());
        expect(params.getString('id'), equals('123'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings', () {
        mockState = createMockState(pathParameters: {'empty': ''});
        routeParams = RouteParams(mockState);

        final result = routeParams.getString('empty');

        expect(result, equals(''));
        expect(result, isNotNull);
      });

      test('should handle special characters in parameter values', () {
        mockState = createMockState(
          pathParameters: {'special': 'hello world!@#\$%'},
        );
        routeParams = RouteParams(mockState);

        final result = routeParams.getString('special');

        expect(result, equals('hello world!@#\$%'));
      });

      test('should handle very large integer values', () {
        mockState = createMockState(pathParameters: {'bigInt': '999999999999'});
        routeParams = RouteParams(mockState);

        final result = routeParams.getInt('bigInt');

        expect(result, equals(999999999999));
      });
    });
  });
}
