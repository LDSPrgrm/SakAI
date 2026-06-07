import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart'
    hide LatLng, NearbyDriver, ServiceArea;

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import 'activity_screen.dart';
import 'location_picker_screen.dart';
import 'destination_sheet.dart';
import 'profile_screen.dart';
import '../../wallet/views/wallet_screen.dart';
import '../../inbox/views/inbox_screen.dart';
import '../models/ride_type_option.dart';
import '../view_models/home_notifier.dart';
import 'widgets/booking_map.dart';
import 'widgets/home_dashboard_header.dart';
import 'widgets/home_promo_carousel.dart';
import 'widgets/home_recent_trips.dart';
import 'widgets/home_services_grid.dart';
import 'widgets/home_wallet_cards.dart';

/// Premium Grab-style scrollable dashboard home screen (REQ-3.2.4).
///
/// Layout:
///   [Idle]           → scrollable dashboard (header, grid, wallet, promos, trips)
///   [destinationSet] → booking flow overlay (timeline card, transit cards, CTA)
///
/// Removes GoogleMap + DraggableScrollableSheet entirely for fast startup.
class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  int _currentIndex = 0;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeNotifierProvider.notifier).initLocation();
    });
  }

  // ── Auth / logout ──────────────────────────────────────────────────────────

  Future<void> _logout() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await ref
            .read(authRepositoryProvider)
            .logout(refreshToken: refreshToken);
      } catch (_) {}
    }
    await ref.read(wsConnectionProvider).disconnect();
    await tokenStorage.clear();
    ref.read(authStateProvider.notifier).markUnauthenticated(forceLogin: true);
  }

  // ── State listener ─────────────────────────────────────────────────────────

  void _listenToState() {
    ref.listen<HomeState>(homeNotifierProvider, (previous, next) {
      // Navigate to waiting screen on successful booking.
      if (next.createdRide != null &&
          next.createdRide != previous?.createdRide &&
          mounted) {
        context.push(Routes.rideWaiting, extra: next.createdRide!.id);
      }

      // Show error snackbar.
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        Future(() => ref.read(homeNotifierProvider.notifier).clearError());
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _listenToState();
    final scheme = Theme.of(context).colorScheme;

    Widget body;
    switch (_currentIndex) {
      case 1:
        body = const ActivityScreen();
        break;
      case 2:
        body = const WalletScreen();
        break;
      case 3:
        body = const InboxScreen();
        break;
      case 4:
        body = ProfileScreen(onSignOut: _logout);
        break;
      case 0:
      default:
        body = _buildHomeBody(scheme);
        break;
    }

    final homeState = ref.watch(homeNotifierProvider);
    final isBookingActive = _currentIndex == 0 &&
        (homeState.status == HomeStatus.destinationSet ||
            homeState.status == HomeStatus.requesting);

    return PopScope(
      canPop: !isBookingActive,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isBookingActive) {
          ref.read(homeNotifierProvider.notifier).clearDestination();
        }
      },
      child: Scaffold(
        backgroundColor: scheme.surface,
        extendBody: true,
        body: body,
        bottomNavigationBar: _buildBottomNav(scheme),
      ),
    );
  }

  // ── Home body (idle vs booking) ────────────────────────────────────────────

  Widget _buildHomeBody(ColorScheme scheme) {
    final status = ref.watch(homeNotifierProvider).status;
    final isActive = status == HomeStatus.destinationSet ||
        status == HomeStatus.requesting;

    if (isActive) {
      return _buildBookingFlow(scheme);
    }
    return _buildDashboard(scheme);
  }

  // ── Scrollable Dashboard (idle) ────────────────────────────────────────────

  Widget _buildDashboard(ColorScheme scheme) {
    final tokens = SakaiDesignTokens.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Green header (non-scrolling pinned effect via SliverToBoxAdapter)
        SliverToBoxAdapter(
          child: const HomeDashboardHeader(),
        ),

        // Services Grid
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: tokens.spaceLg, bottom: tokens.spaceMd),
            child: HomeServicesGrid(
              onTransportTap: () => _openLocationSearch(),
            ),
          ),
        ),

        // Section divider
        SliverToBoxAdapter(child: _SectionDivider(scheme: scheme)),

        // Wallet & loyalty cards
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SakaiSectionHeader(title: 'My Wallet'),
              const HomeWalletCards(),
              SizedBox(height: tokens.spaceLg),
            ],
          ),
        ),

        // Promotions carousel
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SakaiSectionHeader(
                title: 'Promotions',
                trailingLabel: 'See all',
                onTrailingTap: () => context.push(Routes.promotions),
              ),
              const HomePromoCarousel(),
              SizedBox(height: tokens.spaceLg),
            ],
          ),
        ),

        // Recent trips
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SakaiSectionHeader(
                title: 'Recent trips',
                trailingLabel: 'See all',
                onTrailingTap: () => context.push(Routes.rideHistory),
              ),
              const HomeRecentTrips(),
            ],
          ),
        ),

        // Bottom padding for floating nav bar
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  // ── Booking flow (destination set / requesting) ────────────────────────────

  Widget _buildBookingFlow(ColorScheme scheme) {
    final tokens = SakaiDesignTokens.of(context);

    return Stack(
      children: [
        // Full-screen map — always visible behind the panel
        const BookingMap(),

        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: scheme.surface,
            child: SafeArea(
              bottom: false,
              child: BookingTopBar(
                scheme: scheme,
                onBack: () {
                  HapticFeedback.lightImpact();
                  ref.read(homeNotifierProvider.notifier).clearDestination();
                },
              ),
            ),
          ),
        ),

        // Fixed bottom panel — no dragging required
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BottomBookingPanel(
            scheme: scheme,
            tokens: tokens,
            timelineCard: _buildTimelineCard(scheme, tokens),
            rideTypeCards: _buildRideTypeCards(scheme, tokens),
            confirmButton: _buildConfirmButton(scheme),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(ColorScheme scheme, SakaiDesignTokens tokens) {
    final pickup = ref.watch(homeNotifierProvider).pickup;
    final destination = ref.watch(homeNotifierProvider).destination;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicators
          Column(
            children: [
              const SizedBox(height: 6),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00DC82), width: 3),
                  color: scheme.surface,
                ),
              ),
              const SizedBox(height: 4),
              CustomPaint(
                size: const Size(2, 32),
                painter: _DottedLinePainter(color: scheme.outlineVariant),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.place, size: 16, color: Color(0xFFEA4335)),
            ],
          ),
          const SizedBox(width: 16),
          // Address fields
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AddressField(
                  label: 'PICKUP',
                  text: pickup?.address ?? 'Tap to set pickup',
                  active: pickup != null,
                  onTap: () => _openLocationSearch(isPickup: true),
                ),
                Divider(
                  height: 16,
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
                _AddressField(
                  label: 'DESTINATION',
                  text: destination?.address ?? 'Select destination',
                  active: destination != null,
                  onTap: () => _openLocationSearch(),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                ref.read(homeNotifierProvider.notifier).clearDestination(),
            icon: const Icon(Icons.close, size: 18),
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildRideTypeCards(ColorScheme scheme, SakaiDesignTokens tokens) {
    final options = ref.watch(homeNotifierProvider).rideTypeOptions;
    final selectedType = ref.watch(homeNotifierProvider).selectedRideType;
    final notifier = ref.read(homeNotifierProvider.notifier);

    if (options.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Checking nearby drivers…',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose ride type',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: options
                .map((opt) => _TransitCard(
                      option: opt,
                      selected: selectedType == opt.type,
                      scheme: scheme,
                      onTap: () => notifier.setSelectedRideType(opt.type),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(ColorScheme scheme) {
    final canBook = _canRequestRide();

    return GestureDetector(
      onTap: canBook
          ? () {
              HapticFeedback.mediumImpact();
              _handleRequestRide();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: canBook
              ? const LinearGradient(
                  colors: [Color(0xFF00DC82), Color(0xFF00B066)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: canBook ? null : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: canBook
              ? [
                  BoxShadow(
                    color: const Color(0xFF00DC82).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bolt,
              color: canBook ? Colors.black : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Confirm Booking',
              style: TextStyle(
                color: canBook ? Colors.black : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _openLocationSearch({bool isPickup = false}) async {
    final mode = isPickup
        ? LocationSearchMode.pickup
        : LocationSearchMode.destination;
    final result = await showLocationPicker(context, mode: mode);
    if (result == null || !mounted) return;
    final notifier = ref.read(homeNotifierProvider.notifier);
    if (isPickup) {
      notifier.setPickup(result);
    } else {
      notifier.setDestination(result);
    }
  }

  bool _canRequestRide() {
    final state = ref.watch(homeNotifierProvider);
    return state.canRequest ||
        (state.destination != null && state.rideTypeOptions.isNotEmpty);
  }

  void _handleRequestRide() {
    final notifier = ref.read(homeNotifierProvider.notifier);
    final state = ref.read(homeNotifierProvider);
    if (state.selectedRideType == null && state.rideTypeOptions.isNotEmpty) {
      final best = state.rideTypeOptions
          .where((o) => o.isAvailable)
          .fold<RideTypeOption?>(
            null,
            (prev, opt) =>
                prev == null || opt.availableDrivers > prev.availableDrivers
                    ? opt
                    : prev,
          );
      if (best != null) notifier.setSelectedRideType(best.type);
    }
    notifier.requestRide();
  }

  // ── Bottom Navigation ──────────────────────────────────────────────────────

  Widget _buildBottomNav(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      color: Colors.transparent,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(0, Icons.explore_rounded, 'Home', _currentIndex, _onNavTap, scheme),
            _NavItem(1, Icons.receipt_long_rounded, 'Activity', _currentIndex, _onNavTap, scheme),
            _NavItem(2, Icons.account_balance_wallet_rounded, 'Payment', _currentIndex, _onNavTap, scheme),
            _NavItem(3, Icons.chat_bubble_rounded, 'Inbox', _currentIndex, _onNavTap, scheme),
            _NavItem(4, Icons.person_rounded, 'Account', _currentIndex, _onNavTap, scheme),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem(
    this.index,
    this.icon,
    this.label,
    this.currentIndex,
    this.onTap,
    this.scheme,
  );

  final int index;
  final IconData icon;
  final String label;
  final int currentIndex;
  final void Function(int) onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final selected = currentIndex == index;
    const active = Color(0xFF00DC82);
    final inactive = scheme.onSurface.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(icon,
                  color: selected ? active : inactive, size: 22),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: selected ? active : inactive,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 10,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingTopBar extends StatelessWidget {
  const BookingTopBar({
    super.key,
    required this.scheme,
    required this.onBack,
  });

  final ColorScheme scheme;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('booking_back_button'),
            onPressed: onBack,
            icon: Icon(Icons.arrow_back, color: scheme.onSurface),
            tooltip: 'Back',
          ),
          const SizedBox(width: 4),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF00C472),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'SakAI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          IconButton(
            key: const Key('booking_help_button'),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showHelpDialog(context);
            },
            icon: Icon(Icons.help_outline, color: scheme.onSurfaceVariant),
            tooltip: 'Help',
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('booking_help_dialog'),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: const Color(0xFF00C472)),
            const SizedBox(width: 8),
            const Text('Booking Help'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to book a ride:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. Set your pickup and destination locations.'),
            Text('2. Select your ride type: Tricycle, Motorcycle, or Car.'),
            Text('3. Review the estimated fare and click "Confirm Booking".'),
            SizedBox(height: 12),
            Text(
              'SakAI offers reliable transportation powered by dynamic routing.',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('booking_help_dialog_close'),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: Color(0xFF00C472), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.label,
    required this.text,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active
                    ? scheme.onSurface
                    : const Color(0xFF00DC82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransitCard extends StatelessWidget {
  const _TransitCard({
    required this.option,
    required this.selected,
    required this.scheme,
    required this.onTap,
  });

  final RideTypeOption option;
  final bool selected;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (label, desc, iconData) = switch (option.type) {
      VehicleType.tricycle => ('Tricycle', 'Budget • 3 wheels', Icons.electric_rickshaw),
      VehicleType.motorcycle => ('Motorcycle', 'Fast • 2 wheels', Icons.two_wheeler),
      VehicleType.car => ('Car', 'Comfort • 4 wheels', Icons.directions_car),
    };

    final available = option.isAvailable;
    final count = option.availableDrivers;

    // Border: green when selected, amber when unavailable (still visible), default otherwise
    final borderColor = selected
        ? const Color(0xFF00DC82)
        : !available
            ? scheme.error.withValues(alpha: 0.4)
            : scheme.outlineVariant.withValues(alpha: 0.6);

    final bgColor = selected
        ? const Color(0xFF00DC82).withValues(alpha: 0.08)
        : !available
            ? scheme.errorContainer.withValues(alpha: 0.08)
            : scheme.surface;

    // Driver count badge
    final badgeColor = available ? const Color(0xFF00DC82) : scheme.error;
    final badgeBg = available
        ? const Color(0xFF00DC82).withValues(alpha: 0.15)
        : scheme.errorContainer.withValues(alpha: 0.6);
    final badgeText = available ? '$count active' : 'No drivers';

    // Bottom-right label
    final driverLabel = available
        ? '$count driver${count == 1 ? '' : 's'}'
        : 'Unavailable';

    return GestureDetector(
      onTap: available ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 140,
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: selected ? 2.0 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00DC82).withValues(alpha: 0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + availability badge row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  iconData,
                  color: selected
                      ? const Color(0xFF00DC82)
                      : available
                          ? scheme.onSurfaceVariant
                          : scheme.error.withValues(alpha: 0.6),
                  size: 28,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: selected
                    ? const Color(0xFF00DC82)
                    : available
                        ? scheme.onSurface
                        : scheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: TextStyle(
                fontSize: 10,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  available ? '₱${option.estimatedFare.toStringAsFixed(0)}' : '—',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: selected
                        ? const Color(0xFF00DC82)
                        : available
                            ? scheme.onSurface
                            : scheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
                Text(
                  driverLabel,
                  style: TextStyle(
                    fontSize: 9,
                    color: available ? scheme.onSurfaceVariant : scheme.error,
                    fontWeight: available ? FontWeight.normal : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painters
// ─────────────────────────────────────────────────────────────────────────────

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({this.color = Colors.grey});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashH = 4.0;
    const dashGap = 4.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, y + dashH),
        paint,
      );
      y += dashH + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Fixed bottom booking panel — no dragging needed
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBookingPanel extends StatelessWidget {
  const _BottomBookingPanel({
    required this.scheme,
    required this.tokens,
    required this.timelineCard,
    required this.rideTypeCards,
    required this.confirmButton,
  });

  final ColorScheme scheme;
  final SakaiDesignTokens tokens;
  final Widget timelineCard;
  final Widget rideTypeCards;
  final Widget confirmButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle (visual only — panel is fixed)
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: scheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Scrollable content area (timeline + ride type cards)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                timelineCard,
                SizedBox(height: tokens.spaceMd),
                rideTypeCards,
                SizedBox(height: tokens.spaceSm),
              ],
            ),
          ),

          // ── Sticky divider
          Divider(
            height: 1,
            thickness: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),

          // ── Sticky confirm button — always visible, never scrolled away
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.spaceLg,
                tokens.spaceMd,
                tokens.spaceLg,
                tokens.spaceMd,
              ),
              child: confirmButton,
            ),
          ),
        ],
      ),
    );
  }
}
