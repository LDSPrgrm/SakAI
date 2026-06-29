import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

void main() {
  group('SakaiValidators.required', () {
    test('rejects empty / whitespace, accepts non-empty', () {
      expect(SakaiValidators.required(''), isNotNull);
      expect(SakaiValidators.required('   '), isNotNull);
      expect(SakaiValidators.required(null), isNotNull);
      expect(SakaiValidators.required('x'), isNull);
    });
  });

  group('SakaiValidators.email', () {
    test('rejects malformed, accepts well-formed', () {
      expect(SakaiValidators.email('foo'), isNotNull);
      expect(SakaiValidators.email('foo@bar'), isNotNull);
      expect(SakaiValidators.email('foo@bar.com'), isNull);
      // Empty is allowed (compose with `required`).
      expect(SakaiValidators.email(''), isNull);
    });
  });

  group('SakaiValidators.phone', () {
    test('accepts PH-formatted numbers, rejects letters', () {
      expect(SakaiValidators.phone('09171234567'), isNull);
      expect(SakaiValidators.phone('+639171234567'), isNull);
      expect(SakaiValidators.phone('0917-123-4567'), isNull);
      expect(SakaiValidators.phone('abc'), isNotNull);
      expect(SakaiValidators.phone('123'), isNotNull);
    });
  });

  group('SakaiValidators.combine', () {
    test('returns first non-null error and null when all pass', () {
      final v = SakaiValidators.combine([
        SakaiValidators.required,
        SakaiValidators.email,
      ]);
      // Empty fails required first.
      expect(v(''), 'Required');
      // Valid email passes both.
      expect(v('foo@bar.com'), isNull);
    });
  });
}
