import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/e2e_mode_stub.dart'
    if (dart.library.js_interop) '../../../app/e2e_mode_web.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
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
  StreamSubscription<WsEvent>? _wsSub;
  Timer? _e2ePollTimer;

  /// Guards against double-navigation when both the HTTP success callback
  /// and the WebSocket `rideCancelled` event fire in quick succession.
  bool _navigating = false;

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

    _setupWebSocketListener();
    _setupE2EPolling();
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    _pulse.dispose();
    _wsSub?.cancel();
    _e2ePollTimer?.cancel();
    super.dispose();
  }

  void _setupE2EPolling() {
    if (!kIsWeb || !isE2EMode()) return;
    _e2ePollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted || _navigating) return;
      try {
        final active = await ref.read(rideRepositoryProvider).getActiveRide();
        if (!mounted) return;
        if (active == null || active.id != widget.rideId) return;
        if (active.status != RideState.requested) {
          _e2ePollTimer?.cancel();
          _navigating = true;
          context.go(Routes.rideActive, extra: widget.rideId);
        }
      } catch (_) {
        // E2E fallback only; normal WebSocket flow remains authoritative.
      }
    });
  }

  /// React to ViewModel state changes — navigation and snack bars stay here.
  void _onVmChanged() {
    debugPrint(
      '[WaitingScreen] _onVmChanged: cancelled=${_vm.cancelled}, error=${_vm.errorMessage}, mounted=$mounted',
    );
    if (_vm.cancelled && mounted) {
      _goToCancelled();
      return;
    }
    if (_vm.errorMessage != null && mounted) {
      debugPrint('[WaitingScreen] showing SnackBar: ${_vm.errorMessage}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_vm.errorMessage!)));
      _vm.clearError();
    }
  }

  /// Navigate to the cancelled-ride screen exactly once, regardless of whether
  /// the trigger is the HTTP response or the WebSocket `rideCancelled` event.
  void _goToCancelled() {
    if (_navigating || !mounted) return;
    _navigating = true;
    debugPrint('[WaitingScreen] navigating to cancelled screen');
    context.go('/ride/cancelled/${widget.rideId}');
  }

  /// Listen for WebSocket events to navigate when driver accepts.
  void _setupWebSocketListener() {
    final wsClient = ref.read(wsClientProvider);
    _wsSub = wsClient.events.listen((event) {
      if (!mounted) return;

      if (event.type == WsEventNames.rideAccepted) {
        // Driver accepted — navigate to active ride screen.
        context.go(Routes.rideActive, extra: widget.rideId);
      } else if (event.type == WsEventNames.rideOfferExpired) {
        // No drivers available — go back to home.
        if (mounted) {
          SakaiSnackBar.info(context, 'No drivers available. Please try again.');
          context.go(Routes.home);
        }
      } else if (event.type == WsEventNames.rideCancelled) {
        // Server confirmed cancellation via WS.
        debugPrint('[WaitingScreen] WS rideCancelled event received');
        // Update the VM so the button disables immediately if navigation is slow.
        _vm.onRideCancelledByServer();
        // Trigger navigation helper.
        _goToCancelled();
      }
    });
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
                  // Disable while cancelling OR after success (before navigation fires).
                  onPressed: (_vm.cancelling || _vm.cancelled)
                      ? null
                      : _vm.cancel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
