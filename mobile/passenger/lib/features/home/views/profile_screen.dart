import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/routes.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/view_models/profile_view_model.dart';

export '../../profile/view_models/profile_view_model.dart';

/// Profile screen that displays the authenticated user's real data.
/// Replaces the previous static mock-up implementation.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileNotifierProvider);

    // Trigger load on first build if status is initial.
    if (state.status == ProfileStatus.initial) {
      Future.microtask(() {
        ref.read(profileNotifierProvider.notifier).loadProfile();
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Orbital Organic Blobs Background
          const Positioned.fill(child: SakaiAnimatedBackdrop()),
          RefreshIndicator(
            onRefresh: () =>
                ref.read(profileNotifierProvider.notifier).refresh(),
            child: _buildContent(context, state, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProfileState state,
    WidgetRef ref,
  ) {
    switch (state.status) {
      case ProfileStatus.initial:
      case ProfileStatus.loading:
        return const _LoadingView();
      case ProfileStatus.loaded:
        final profile = state.profile!;
        return _ProfileContent(
          profile: profile,
          onSignOut: onSignOut,
          onEditProfile: () => context.push(Routes.editProfile),
        );
      case ProfileStatus.error:
        return _ErrorView(
          message: state.errorMessage ?? 'Unknown error',
          onRetry: () =>
              ref.read(profileNotifierProvider.notifier).loadProfile(),
        );
    }
  }
}

// ─── Loading State ────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// ─── Error State ──────────────────────────────────────────────────

class _ErrorView extends StatefulWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  State<_ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<_ErrorView> {
  bool _isLoading = false;

  void _handleRetry() {
    if (_isLoading) return;
    // PERFORMANCE: Debounce retry to prevent rapid repeated API calls.
    setState(() => _isLoading = true);
    widget.onRetry();
    // Reset after a short delay to allow another retry attempt.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load profile',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SakaiPrimaryButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: _isLoading ? null : _handleRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loaded Content ───────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    required this.onSignOut,
    required this.onEditProfile,
  });

  final UserProfileModel profile;
  final VoidCallback onSignOut;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sem = SakaiSemanticColors.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + 24),

        // Profile Details Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar circle with neon glow halo
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            scheme.primary,
                            scheme.primary.withValues(alpha: 0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.2),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: SakaiAvatar(
                        initials: profile.initials,
                        size: SakaiAvatarSize.lg,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primary,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Name
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  profile.email,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Phone
                if (profile.phone != null && profile.phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.phone!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                // Rating Badge
                if (profile.rating != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: sem.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: sem.warning.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profile.rating!.toStringAsFixed(1),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: sem.warning,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: sem.warning,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Rider Rating',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant.withValues(
                              alpha: 0.8,
                            ),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Grouped Sleek Glass Cards

        // Section: Payment Methods
        _buildSectionHeader(context, 'Payment Methods'),
        _buildGroupedCard(context, scheme, [
          _buildStandardTile(
            context,
            Icons.account_balance_wallet_rounded,
            'Payment Methods',
            onTap: () => context.push(Routes.paymentMethods),
          ),
        ]),

        // Section: Safety
        _buildSectionHeader(context, 'Safety'),
        _buildGroupedCard(context, scheme, [
          _buildStandardTile(
            context,
            Icons.emergency_share_rounded,
            'Emergency Contacts',
            onTap: () => context.push(Routes.settingsEmergencyContacts),
          ),
          _buildDivider(scheme),
          _buildStandardTile(
            context,
            Icons.notifications_active_rounded,
            'Notifications',
            onTap: () => context.push(Routes.settingsNotifications),
          ),
        ]),

        // Section: General Settings
        _buildSectionHeader(context, 'General'),
        _buildGroupedCard(context, scheme, [
          _buildStandardTile(
            context,
            Icons.language_rounded,
            'Language',
            onTap: () => context.push(Routes.settingsLanguage),
          ),
          _buildDivider(scheme),
          _buildStandardTile(
            context,
            Icons.settings_suggest_rounded,
            'Settings',
            onTap: () => context.push(Routes.settings),
          ),
          _buildDivider(scheme),
          _buildStandardTile(
            context,
            Icons.description_rounded,
            'Terms of Service',
            onTap: () => context.push(Routes.settingsTerms),
          ),
          _buildDivider(scheme),
          _buildStandardTile(
            context,
            Icons.shield_rounded,
            'Privacy Policy',
            onTap: () => context.push(Routes.settingsPrivacy),
          ),
          _buildDivider(scheme),
          _buildStandardTile(
            context,
            Icons.help_center_rounded,
            'Help Center',
            onTap: () => context.push(Routes.settingsHelp),
          ),
        ]),

        // Footer / Logout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: OutlinedButton.icon(
            onPressed: onSignOut,
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              side: BorderSide(
                color: scheme.error.withValues(alpha: 0.2),
                width: 1.2,
              ),
              backgroundColor: scheme.error.withValues(alpha: 0.06),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: Icon(Icons.logout_rounded, color: scheme.error),
            label: Text(
              'Log Out',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        Center(
          child: Text(
            'Version 2.4.0 (Build 192)',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 96), // Extra bottom padding for floating nav bar
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGroupedCard(
    BuildContext context,
    ColorScheme scheme,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDivider(ColorScheme scheme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 64,
      color: scheme.outlineVariant.withValues(alpha: 0.08),
    );
  }

  Widget _buildStandardTile(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: scheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              if (trailing != null) ...[trailing, const SizedBox(width: 8)],
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
