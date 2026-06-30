import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'app/driver_app.dart';
import 'app/providers.dart';
import 'features/auth/repositories/otp_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  final apiUrl = dotenv.env['API_URL'] ?? '';
  final hasMapsKey = (dotenv.env['MAPS_API_KEY'] ?? '').isNotEmpty;
  debugPrint('[BOOT] .env loaded. API_URL=$apiUrl, MAPS_API_KEY=$hasMapsKey');

  final prefs = await SharedPreferences.getInstance();
  debugPrint('[BOOT] SharedPreferences initialized');

  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        otpRepositoryProvider.overrideWith(
          (ref) => OtpRepositoryImpl(ref.watch(apiClientProvider)),
        ),
      ],
      child: const DriverApp(),
    ),
  );
}
