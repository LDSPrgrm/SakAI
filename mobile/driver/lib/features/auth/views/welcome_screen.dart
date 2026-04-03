import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const _slides = [
    SakaiWelcomeSlide(
      icon: Icons.drive_eta_rounded,
      title: 'Drive & Earn',
      description:
          'Set your own schedule. Accept rides that work for you and grow your income.',
    ),
    SakaiWelcomeSlide(
      icon: Icons.navigation_rounded,
      title: 'Smart Navigation',
      description:
          'Get turn-by-turn directions optimised for the fastest, safest routes.',
    ),
    SakaiWelcomeSlide(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Fast Payouts',
      description:
          'Earnings deposited directly to your wallet. Withdraw anytime.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SakaiWelcomeCarousel(
      slides: _slides,
      onComplete: () async {
        final onboarding = ref.read(onboardingServiceProvider);
        await onboarding.markWelcomeComplete();
        if (context.mounted) context.go(Routes.login);
      },
    );
  }
}
