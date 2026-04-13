import 'package:test/test.dart';
import 'package:sakai_api_client/sakai_api_client.dart';

// tests for PaymentMethodDetails
void main() {
  final instance = PaymentMethodDetailsBuilder();
  // TODO add properties to the builder and call build()

  group(PaymentMethodDetails, () {
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // PaymentMethodType type
    test('to test the property `type`', () async {
      // TODO
    });

    // Whether this is the default payment method
    // bool isDefault
    test('to test the property `isDefault`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

    // Present only if type == \"card\"
    // CardDetails card
    test('to test the property `card`', () async {
      // TODO
    });

    // Present only if type == \"e_wallet\"
    // EWalletDetails eWallet
    test('to test the property `eWallet`', () async {
      // TODO
    });

  });
}
