import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/providers.dart';
import '../view_models/waiting_view_model.dart';

/// Waiting screen shown immediately after a successful POST /rides.
///
/// REQ-3.2.5 will wire up WebSocket events (ride.accepted / offer_expired).
/// For now it shows a loading animation + cancel button.
///
/// All cancel logic lives in [WaitingViewModel]; this widget is pure View.
class WaitingScreen extends ConsumerStatefulWidget {
  const WaitingScreen({super.key, required this.rideId});

  final String rideId;

  @override
  ConsumerState<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen>
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
      rideRepository: ref.read(rideRepositoryProvider),
      rideId: widget.rideId,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_vm.errorMessage!)));
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
              // Radar/Ripple animation
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (int i = 0; i < 3; i++)
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, child) {
                          final progress = (_pulse.value + (i * 0.33)) % 1.0;
                          return Container(
                            width: 120 + (progress * 180),
                            height: 120 + (progress * 180),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: scheme.primary.withValues(
                                  alpha: (1.0 - progress) * 0.4,
                                ),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) => Transform.scale(
                        scale: 0.9 + _pulse.value * 0.1,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: scheme.primaryContainer,
                          child: Icon(
                            Icons.local_taxi,
                            size: 48,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
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
