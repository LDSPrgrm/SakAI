import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const _slides = [
    SakaiWelcomeSlide(
      icon: Icons.location_on_rounded,
      title: 'Go Anywhere',
      description:
          'Request a ride in seconds. Your driver arrives fast — wherever you need to go.',
    ),
    SakaiWelcomeSlide(
      icon: Icons.shield_rounded,
      title: 'Safe & Reliable',
      description:
          'Every ride is tracked in real time. Your safety is our top priority.',
    ),
    SakaiWelcomeSlide(
      icon: Icons.payments_rounded,
      title: 'Pay with Ease',
      description:
          'Multiple payment options. No surprises — fare is calculated upfront.',
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
