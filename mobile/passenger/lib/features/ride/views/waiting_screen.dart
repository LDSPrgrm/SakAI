import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../repositories/ride_repository.dart';
import '../view_models/waiting_view_model.dart';

/// Waiting screen shown immediately after a successful POST /rides.
///
/// REQ-3.2.5 will wire up WebSocket events (ride.accepted / offer_expired).
/// For now it shows a loading animation + cancel button.
///
/// All cancel logic lives in [WaitingViewModel]; this widget is pure View.
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
  late final WaitingViewModel _vm;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _vm = WaitingViewModel(
      rideRepository: widget.rideRepository,
      rideId: widget.ride.id,
    );
    _vm.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    _pulse.dispose();
    super.dispose();
  }

  /// React to ViewModel state changes — navigation and snack bars stay here.
  void _onVmChanged() {
    if (_vm.cancelled && mounted) {
      Navigator.of(context).pop();
      return;
    }
    if (_vm.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_vm.errorMessage!)),
      );
      _vm.clearError();
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
              // Pulse animation — UI-only, stays in View
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
              ListenableBuilder(
                listenable: _vm,
                builder: (context, _) => SakaiSecondaryButton(
                  label: _vm.cancelling ? 'Cancelling…' : 'Cancel Ride',
                  icon: Icons.close,
                  onPressed: _vm.cancelling ? null : _vm.cancel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
