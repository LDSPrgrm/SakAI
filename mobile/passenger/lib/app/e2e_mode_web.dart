// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web show window;

bool isE2EMode() {
  try {
    final href = web.window.location.href;
    return Uri.parse(href).queryParameters['sakai-e2e'] == 'true';
  } catch (_) {
    return false;
  }
}
