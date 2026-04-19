import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

// tests for AddPaymentMethodRequest
void main() {
  final instance = AddPaymentMethodRequestBuilder();
  // TODO add properties to the builder and call build()

  group(AddPaymentMethodRequest, () {
    // PaymentMethodType type
    test('to test the property `type`', () async {
      // TODO
    });

    // Payment gateway token for card (required if type == \"card\")
    // String cardToken
    test('to test the property `cardToken`', () async {
      // TODO
    });

    // E-wallet provider name (required if type == \"e_wallet\")
    // String provider
    test('to test the property `provider`', () async {
      // TODO
    });

    // E-wallet account ID (required if type == \"e_wallet\")
    // String accountId
    test('to test the property `accountId`', () async {
      // TODO
    });

    // Set as default payment method
    // bool setAsDefault (default value: false)
    test('to test the property `setAsDefault`', () async {
      // TODO
    });

  });
}
