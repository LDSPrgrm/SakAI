import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

void main() {
  group('SakaiDesignTokens.defaults', () {
    const t = SakaiDesignTokens.defaults;

    test('new token values match plan spec', () {
      expect(t.elevationAppBar, 0);
      expect(t.opacityDisabled, 0.38);
      expect(t.iconMd, 24.0);
      expect(t.touchTargetMin, 48.0);
    });

    test('motion curves are non-null', () {
      expect(t.curveStandard, isNotNull);
      expect(t.curveEmphasized, isNotNull);
      expect(t.curveDecelerate, isNotNull);
    });

    test('durationMicro is 80ms', () {
      expect(t.durationMicro, const Duration(milliseconds: 80));
    });
  });
}
