import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/semantics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sakai_shared/sakai_shared.dart';

import 'app/passenger_app.dart';
import 'app/providers.dart';
import 'features/auth/repositories/otp_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final prefs = await SharedPreferences.getInstance();

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
      child: const PassengerApp(),
    ),
  );
}
