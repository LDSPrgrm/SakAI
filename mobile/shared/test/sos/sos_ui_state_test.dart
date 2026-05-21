import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sos/sos_ui_state.dart';

void main() {
  group('SosUiState privacy', () {
    test('withAssignee keeps first name only', () {
      final s = SosUiState.idle
          .withTrigger(triggeredBy: 'rider')
          .withAssignee('Maria Santos-Cruz');
      expect(s.assigneeDisplay, 'Maria');
    });

    test('withAssignee handles null / blank gracefully', () {
      expect(SosUiState.idle.withAssignee(null).assigneeDisplay, isNull);
      expect(SosUiState.idle.withAssignee('   ').assigneeDisplay, isNull);
    });

    test('single-token name passes through untouched', () {
      expect(SosUiState.idle.withAssignee('Mononymous').assigneeDisplay,
          'Mononymous');
    });
  });

  group('SosUiState lifecycle', () {
    test('withTrigger marks active and stores fields', () {
      final s = SosUiState.idle
          .withTrigger(triggeredBy: 'driver', reason: 'erratic passenger');
      expect(s.active, isTrue);
      expect(s.triggeredBy, 'driver');
      expect(s.reason, 'erratic passenger');
      expect(s.assigneeDisplay, isNull);
    });

    test('withResolved reverts to idle (resolution_notes never stored)', () {
      final s = SosUiState.idle
          .withTrigger(triggeredBy: 'rider')
          .withAssignee('Jane Doe')
          .withResolved();
      expect(s, SosUiState.idle);
      expect(s.active, isFalse);
      expect(s.assigneeDisplay, isNull);
    });

    test('repeated trigger does not clobber assignee', () {
      final s = SosUiState.idle
          .withTrigger(triggeredBy: 'rider')
          .withAssignee('Maria Santos')
          .withTrigger(triggeredBy: 'rider', reason: 'still ongoing');
      expect(s.assigneeDisplay, 'Maria');
      expect(s.reason, 'still ongoing');
    });
  });
}
