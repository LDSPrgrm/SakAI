import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../features/auth/views/auth_screen.dart';
import '../features/auth/views/splash_screen.dart';
import '../features/auth/views/welcome_screen.dart';
import '../features/home/views/rider_home_screen.dart';
import '../features/profile/views/edit_profile_screen.dart';
import '../features/ride/views/waiting_screen.dart';
import '../features/active_ride/views/active_ride_screen.dart';
import '../features/ride_complete/views/ride_complete_screen.dart';
import '../features/ride_history/views/ride_history_list_screen.dart';
import '../features/ride_history/views/ride_detail_screen.dart';
import '../features/cancelled_ride/views/cancelled_ride_screen.dart';
import '../features/receipt/views/receipt_screen.dart';
import '../features/payment_methods/views/payment_methods_screen.dart';
import '../features/payment_methods/views/add_payment_method_screen.dart';
import '../features/settings/views/settings_menu_screen.dart';
import '../features/settings/views/notification_settings_screen.dart';
import '../features/settings/views/emergency_contacts_screen.dart';
import '../features/settings/views/help_center_screen.dart';
import '../features/settings/views/terms_screen.dart';
import '../features/settings/views/privacy_policy_screen.dart';
import '../features/settings/views/language_selection_screen.dart';
import 'providers.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = ValueNotifier<AuthStateModel>(ref.read(authStateProvider));
  ref.listen<AuthStateModel>(authStateProvider, (_, next) {
    listenable.value = next;
  });

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: false,
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final onboarding = ref.read(onboardingServiceProvider);
      final hasSeenWelcome = onboarding.hasSeenWelcome();

      final isSplash = state.matchedLocation == Routes.splash;
      final isWelcome = state.matchedLocation == Routes.welcome;
      final isLogin = state.matchedLocation == Routes.login;
      final isRegister = state.matchedLocation == Routes.register;
      final isAuthRoute = isWelcome || isLogin || isRegister;

      if (isSplash) return null;

      if (authState.status == AuthStatus.unknown) {
        return Routes.splash;
      }

      if (authState.status == AuthStatus.authenticated) {
        if (isAuthRoute) return Routes.home;
        return null;
      }

      if (authState.forceLogin) {
        if (isLogin || isRegister) return null;
        return Routes.login;
      }

      final unauthLanding = hasSeenWelcome ? Routes.login : Routes.welcome;
      if (!isAuthRoute) return unauthLanding;
      if (!hasSeenWelcome && !isWelcome) return Routes.welcome;
      if (hasSeenWelcome && isWelcome) return Routes.login;

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) =>
            const AuthScreen(initialMode: AuthMode.login),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) =>
            const AuthScreen(initialMode: AuthMode.register),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const RiderHomeScreen(),
      ),
      GoRoute(
        path: Routes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: Routes.rideWaiting,
        builder: (context, state) {
          final rideId = state.extra as String;
          return WaitingScreen(rideId: rideId);
        },
      ),
      GoRoute(
        path: Routes.rideActive,
        builder: (context, state) {
          final rideId = state.extra as String;
          return ActiveRideScreen(rideId: rideId);
        },
      ),
      GoRoute(
        path: Routes.rideComplete,
        builder: (context, state) {
          final rideId = state.extra as String;
          return RideCompleteScreen(rideId: rideId);
        },
      ),
      GoRoute(
        path: Routes.rideCancelled,
        builder: (context, state) {
          final rideId = state.pathParameters['rideId']!;
          return CancelledRideScreen(rideId: rideId);
        },
      ),
      GoRoute(
        path: Routes.rideHistory,
        builder: (context, state) => const RideHistoryListScreen(),
      ),
      GoRoute(
        path: Routes.rideDetail,
        builder: (context, state) {
          final rideId = state.pathParameters['rideId']!;
          return RideDetailScreen(rideId: rideId);
        },
      ),
      GoRoute(
        path: Routes.receipt,
        builder: (context, state) {
          final rideId = state.pathParameters['rideId']!;
          return ReceiptScreen(rideId: rideId);
        },
      ),
      GoRoute(
        path: Routes.paymentMethods,
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: Routes.paymentMethodAdd,
        builder: (context, state) => const AddPaymentMethodScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsMenuScreen(),
      ),
      GoRoute(
        path: Routes.settingsNotifications,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: Routes.settingsEmergencyContacts,
        builder: (context, state) => const EmergencyContactsScreen(),
      ),
      GoRoute(
        path: Routes.settingsHelp,
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: Routes.settingsTerms,
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: Routes.settingsPrivacy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: Routes.settingsLanguage,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
    ],
  );
});
