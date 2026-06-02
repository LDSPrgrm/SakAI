import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes.dart';
import '../../../notifications/view_models/notifications_notifier.dart';
import '../../../profile/view_models/profile_view_model.dart';
import '../../view_models/home_notifier.dart';
import '../location_picker_screen.dart';
import '../destination_sheet.dart';

/// Premium Grab-style green header with branding, greeting, notifications,
/// and the "Where to?" search bar that triggers the location picker.
class HomeDashboardHeader extends ConsumerWidget {
  const HomeDashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider).profile;
    final unread = ref.watch(notificationsNotifierProvider).unreadCount;
    final firstName = profile?.name.split(' ').first ?? 'there';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00C472), Color(0xFF00A85A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: Greeting + Avatar + Bell ─────────────────────────
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (profile?.initials ?? 'U').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          firstName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Notification Bell
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(Routes.notifications);
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.notifications_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        if (unread > 0)
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ── Search Bar ────────────────────────────────────────────────
              _SearchBar(ref: ref),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 18) return 'Good afternoon,';
    return 'Good evening,';
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final dest = ref.watch(homeNotifierProvider).destination;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final result = await showLocationPicker(
          context,
          mode: LocationSearchMode.destination,
        );
        if (result == null) return;
        ref.read(homeNotifierProvider.notifier).setDestination(result);
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded, color: Color(0xFF00C472), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dest?.address ?? 'Where to? e.g. Starbucks',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: dest != null ? FontWeight.w600 : FontWeight.w500,
                  color: dest != null
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            const Icon(
              Icons.qr_code_scanner_rounded,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
