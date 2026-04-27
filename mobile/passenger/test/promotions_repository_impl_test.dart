import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:dio/dio.dart';
import 'package:passenger/features/promotions/repositories/promotions_repository_impl.dart';
import 'package:built_collection/built_collection.dart';

import 'promotions_repository_impl_test.mocks.dart';

@GenerateMocks([api.UsersApi])
void main() {
  late MockUsersApi mockUsersApi;
  late PromotionsRepositoryImpl repository;

  setUp(() {
    mockUsersApi = MockUsersApi();
    repository = PromotionsRepositoryImpl(mockUsersApi);
  });

  group('PromotionsRepositoryImpl', () {
    final mockPromotion = api.Promotion(
      (b) => b
        ..id = '1'
        ..code = 'SAVE10'
        ..description = 'Save 10% on your next ride'
        ..discountValue = 10.0
        ..discountType = api.PromotionDiscountTypeEnum.percentage
        ..expiresAt = DateTime(2025, 12, 31).toUtc(),
    );

    test('getPromotions returns list of promotions on success', () async {
      when(mockUsersApi.promotionsList()).thenAnswer(
        (_) async => Response(
          data: BuiltList<api.Promotion>([mockPromotion]),
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.getPromotions();

      expect(result.length, 1);
      expect(result[0].code, 'SAVE10');
      expect(result[0].discountType, api.PromotionDiscountTypeEnum.percentage);
    });

    test('validatePromoCode returns promotion on success', () async {
      when(
        mockUsersApi.promotionsValidate(
          promotionValidateRequest: anyNamed('promotionValidateRequest'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: mockPromotion,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.validatePromoCode(
        'SAVE10',
        rideFare: 100.0,
      );

      expect(result.code, 'SAVE10');
      expect(result.discountValue, 10.0);
    });

    test('validatePromoCode throws exception on failure', () async {
      when(
        mockUsersApi.promotionsValidate(
          promotionValidateRequest: anyNamed('promotionValidateRequest'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => repository.validatePromoCode('INVALID'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
