import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:sakai_api_client/sakai_api_client.dart';
import 'package:passenger/features/payment_methods/repositories/payment_method_repository.dart';
import 'package:passenger/features/payment_methods/models/payment_method.dart';

import 'payment_method_repository_impl_test.mocks.dart';

@GenerateMocks([SakaiApiClient, UsersApi])
void main() {
  late MockSakaiApiClient mockClient;
  late MockUsersApi mockUsersApi;
  late PaymentMethodRepositoryImpl repository;

  setUp(() {
    mockClient = MockSakaiApiClient();
    mockUsersApi = MockUsersApi();

    when(mockClient.getUsersApi()).thenReturn(mockUsersApi);
    repository = PaymentMethodRepositoryImpl(mockClient);
  });

  group('PaymentMethodRepositoryImpl.getPaymentMethods', () {
    test('successfully fetches payment methods', () async {
      final now = DateTime.now();
      final mockApiResponse = PaymentMethodListResponse((b) => b
        ..data.addAll([
          PaymentMethodDetails((m) => m
            ..id = 'pm-1'
            ..type = PaymentMethodType.card
            ..isDefault = true
            ..createdAt = now
            ..card = CardDetails((c) => c
              ..brand = 'visa'
              ..last4 = '1234'
              ..expiryMonth = 12
              ..expiryYear = 2026).toBuilder()),
        ]));

      when(mockUsersApi.paymentMethodsList()).thenAnswer((_) async => Response(
            data: mockApiResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final methods = await repository.getPaymentMethods();

      expect(methods.length, 1);
      expect(methods.first.id, 'pm-1');
      expect(methods.first.type, DomainPaymentMethodType.card);
      expect(methods.first.displayName, 'Visa .... 1234');
    });

    test('returns empty list when response data is null', () async {
      when(mockUsersApi.paymentMethodsList()).thenAnswer((_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final methods = await repository.getPaymentMethods();
      expect(methods, isEmpty);
    });

    test('maps PAYMENT_METHOD_NOT_FOUND error code correctly', () async {
      final errorResponse = ErrorResponse((b) => b
        ..code = ErrorCode.PAYMENT_METHOD_NOT_FOUND
        ..message = 'Not found');

      final serializedError = standardSerializers.serializeWith(ErrorResponse.serializer, errorResponse);

      when(mockUsersApi.paymentMethodsList()).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          data: serializedError,
          statusCode: 404,
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      expect(
        () => repository.getPaymentMethods(),
        throwsA(isA<PaymentMethodNotFoundError>().having((e) => e.message, 'message', 'Not found')),
      );
    });
  });

  group('PaymentMethodRepositoryImpl.addPaymentMethod', () {
    test('successfully adds a card payment method', () async {
      final now = DateTime.now();
      final mockApiResponse = PaymentMethodDetails((m) => m
        ..id = 'pm-new'
        ..type = PaymentMethodType.card
        ..isDefault = false
        ..createdAt = now
        ..card = CardDetails((c) => c
          ..brand = 'mastercard'
          ..last4 = '5678'
          ..expiryMonth = 10
          ..expiryYear = 2027).toBuilder());

      when(mockUsersApi.paymentMethodsAdd(addPaymentMethodRequest: anyNamed('addPaymentMethodRequest')))
          .thenAnswer((_) async => Response(
                data: mockApiResponse,
                statusCode: 201,
                requestOptions: RequestOptions(path: ''),
              ));

      final method = await repository.addPaymentMethod(
        type: DomainPaymentMethodType.card,
        cardToken: 'tok_visa',
      );

      expect(method.id, 'pm-new');
      expect(method.type, DomainPaymentMethodType.card);
      expect(method.displayName, 'Mastercard .... 5678');
    });
  });

  group('PaymentMethodRepositoryImpl.setAsDefault', () {
    test('successfully sets payment method as default', () async {
      final now = DateTime.now();
      final mockApiResponse = PaymentMethodDetails((m) => m
        ..id = 'pm-1'
        ..type = PaymentMethodType.cash
        ..isDefault = true
        ..createdAt = now);

      when(mockUsersApi.paymentMethodsSetDefault(paymentMethodId: 'pm-1'))
          .thenAnswer((_) async => Response(
                data: mockApiResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final method = await repository.setAsDefault('pm-1');
      expect(method.isDefault, isTrue);
    });
  });
}
