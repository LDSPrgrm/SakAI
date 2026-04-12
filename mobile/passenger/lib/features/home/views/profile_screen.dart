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
    // Trigger load on first build.
    ref.listen<ProfileState>(profileNotifierProvider, (previous, next) {
      if (previous?.status == ProfileStatus.initial &&
          next.status == ProfileStatus.initial) {
        ref.read(profileNotifierProvider.notifier).loadProfile();
      }
    });

    final state = ref.watch(profileNotifierProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(profileNotifierProvider.notifier).refresh(),
      child: _buildContent(context, state, ref),
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
    final warningColor = Colors.amber;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Profile Card
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              // Avatar circle with initials or image
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Text(
                      profile.initials,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                profile.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              // Email
              Text(
                profile.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),

              // Phone (if available)
              if (profile.phone != null && profile.phone!.isNotEmpty)
                Text(
                  profile.phone!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              // Rating Badge (if available)
              if (profile.rating != null) ...[
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.rating!.toStringAsFixed(1),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: warningColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.star, size: 16, color: warningColor),
                      const SizedBox(width: 6),
                      Text(
                        'Rider Rating',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Edit Profile Button
              TextButton(
                onPressed: onEditProfile,
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        const Divider(thickness: 8, height: 8),

        // Payment Methods
        _buildSectionHeader(context, 'Payment Methods'),
        _buildStandardTile(
          context,
          Icons.account_balance_wallet,
          'Payment Methods',
          onTap: () => context.push(Routes.paymentMethods),
        ),

        const Divider(thickness: 8, height: 8),

        // Safety
        _buildSectionHeader(context, 'Safety'),
        _buildStandardTile(
          context,
          Icons.emergency_share,
          'Emergency Contacts',
          onTap: () => context.push(Routes.settingsEmergencyContacts),
        ),
        const Divider(indent: 52, height: 1),
        _buildStandardTile(
          context,
          Icons.notifications_active,
          'Notifications',
          onTap: () => context.push(Routes.settingsNotifications),
        ),

        const Divider(thickness: 8, height: 8),

        // General
        _buildSectionHeader(context, 'General'),
        _buildStandardTile(
          context,
          Icons.language,
          'Language',
          onTap: () => context.push(Routes.settingsLanguage),
        ),
        const Divider(indent: 52, height: 1),
        _buildStandardTile(
          context,
          Icons.settings_outlined,
          'Settings',
          onTap: () => context.push(Routes.settings),
        ),
        const Divider(indent: 52, height: 1),
        _buildStandardTile(
          context,
          Icons.description_outlined,
          'Terms of Service',
          onTap: () => context.push(Routes.settingsTerms),
        ),
        const Divider(indent: 52, height: 1),
        _buildStandardTile(
          context,
          Icons.shield_outlined,
          'Privacy Policy',
          onTap: () => context.push(Routes.settingsPrivacy),
        ),
        const Divider(indent: 52, height: 1),
        _buildStandardTile(
          context,
          Icons.help_outline,
          'Help Center',
          onTap: () => context.push(Routes.settingsHelp),
        ),

        const Divider(thickness: 8, height: 8),

        // Footer / Logout
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: OutlinedButton.icon(
            onPressed: onSignOut,
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
              ),
              backgroundColor: theme.colorScheme.error.withValues(alpha: 0.05),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        Center(
          child: Text(
            'Version 2.4.0 (Build 192)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStandardTile(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return SakaiSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).iconTheme.color),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          if (trailing != null) ...[trailing, const SizedBox(width: 8)],
          Icon(
            Icons.chevron_right,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
