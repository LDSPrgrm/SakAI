import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../domain/ride_repository.dart';

/// Waiting screen shown immediately after a successful POST /rides.
///
/// REQ-3.2.5 will wire up WebSocket events (ride.accepted / offer_expired).
/// For now it shows a loading animation + cancel button.
class WaitingScreen extends StatefulWidget {
  const WaitingScreen({
    super.key,
    required this.ride,
    required this.rideRepository,
  });

  final RideEntity ride;
  final RideRepository rideRepository;

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _cancelRide() async {
    setState(() => _cancelling = true);
    try {
      await widget.rideRepository.cancelRide(widget.ride.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not cancel. Try again.')),
        );
        setState(() => _cancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = SakaiDesignTokens.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pulse animation
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) => Transform.scale(
                  scale: 0.85 + _pulse.value * 0.15,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        scheme.primaryContainer.withValues(alpha: 0.6 + _pulse.value * 0.4),
                    child: Icon(
                      Icons.local_taxi,
                      size: 56,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              SizedBox(height: tokens.spaceXl),
              Text(
                'Finding your driver…',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: tokens.spaceSm),
              Text(
                'We\'re matching you with the nearest available driver.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
              SizedBox(height: tokens.spaceXl),
              SakaiSecondaryButton(
                label: _cancelling ? 'Cancelling…' : 'Cancel Ride',
                icon: Icons.close,
                onPressed: _cancelling ? null : _cancelRide,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
