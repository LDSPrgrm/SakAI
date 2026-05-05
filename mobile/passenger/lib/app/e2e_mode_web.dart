// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web show window;

const _integrationTest = bool.fromEnvironment('INTEGRATION_TEST');

/// True for any test environment where the GoogleMap / WebSocket bypasses
/// should kick in (Playwright via URL flag, integration_test via dart-define).
bool isE2EMode() {
  if (_integrationTest) return true;
  return _hasE2EUrlFlag();
}

/// Narrower check used by Splash to skip the real backend session check.
/// Only true under Playwright (URL flag), so integration_test specs can still
/// exercise the real splash flow with fake repositories.
bool isPlaywrightMode() => _hasE2EUrlFlag();

bool _hasE2EUrlFlag() {
  try {
    final href = web.window.location.href;
    return Uri.parse(href).queryParameters['sakai-e2e'] == 'true';
  } catch (_) {
    return false;
  }
}
