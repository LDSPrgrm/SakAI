import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passenger/features/saved_places/models/saved_place.dart';
import 'package:passenger/features/saved_places/repositories/saved_places_repository_impl.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:built_value/serializer.dart';

class _TestAdapter implements HttpClientAdapter {
  _TestAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Object data, int statusCode) {
  final serializers = api.standardSerializers;
  Object? serialized;

  if (data is api.SavedPlace) {
    serialized = serializers.serialize(
      data,
      specifiedType: const FullType(api.SavedPlace),
    );
  } else if (data is List<api.SavedPlace>) {
    serialized = data
        .map(
          (e) => serializers.serialize(
            e,
            specifiedType: const FullType(api.SavedPlace),
          ),
        )
        .toList();
  } else if (data is api.ErrorResponse) {
    serialized = serializers.serialize(
      data,
      specifiedType: const FullType(api.ErrorResponse),
    );
  } else {
    serialized = data;
  }

  return ResponseBody.fromString(
    jsonEncode(serialized),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  late api.SakaiApiClient client;
  late SavedPlacesRepositoryImpl repository;

  setUp(() {
    client = api.SakaiApiClient(basePathOverride: 'https://api.test');
    repository = SavedPlacesRepositoryImpl(client.getUsersApi());
  });

  group('SavedPlacesRepositoryImpl.getSavedPlaces', () {
    test('returns list of saved places on success', () async {
      final mockData = [
        api.SavedPlace(
          (b) => b
            ..id = 'place-1'
            ..name = 'Home'
            ..address = '123 Main St'
            ..latitude = 1.0
            ..longitude = 2.0
            ..type = api.SavedPlaceTypeEnum.home,
        ),
      ];

      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/users/me/saved-places') &&
            options.method == 'GET') {
          return _jsonResponse(mockData, 200);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final result = await repository.getSavedPlaces();

      expect(result, isA<List<SavedPlace>>());
      expect(result.length, 1);
      expect(result.first.name, 'Home');
      expect(result.first.type, SavedPlaceType.home);
    });
  });

  group('SavedPlacesRepositoryImpl.addSavedPlace', () {
    test('successfully adds a saved place', () async {
      final mockResponse = api.SavedPlace(
        (b) => b
          ..id = 'place-new'
          ..name = 'Work'
          ..address = '456 Office Rd'
          ..latitude = 3.0
          ..longitude = 4.0
          ..type = api.SavedPlaceTypeEnum.work,
      );

      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.endsWith('/users/me/saved-places') &&
            options.method == 'POST') {
          return _jsonResponse(mockResponse, 201);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      final result = await repository.addSavedPlace(
        name: 'Work',
        address: '456 Office Rd',
        latitude: 3.0,
        longitude: 4.0,
        type: SavedPlaceType.work,
      );

      expect(result.id, 'place-new');
      expect(result.name, 'Work');
      expect(result.type, SavedPlaceType.work);
    });
  });

  group('SavedPlacesRepositoryImpl.deleteSavedPlace', () {
    test('successfully deletes a saved place', () async {
      bool called = false;
      client.dio.httpClientAdapter = _TestAdapter((options) async {
        if (options.path.contains('/users/me/saved-places/place-123') &&
            options.method == 'DELETE') {
          called = true;
          return ResponseBody.fromString('', 204);
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      await repository.deleteSavedPlace('place-123');
      expect(called, isTrue);
    });
  });
}
