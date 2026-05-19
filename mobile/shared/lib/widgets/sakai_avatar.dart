import 'package:flutter/material.dart';

/// Discrete size buckets for [SakaiAvatar]. Mapped to fixed diameters so
/// the avatar reads consistently across lists, headers, and hero contexts.
enum SakaiAvatarSize { sm, md, lg }

/// Circular avatar with image, initials, or icon fallback. Optionally
/// stamps a status [badge] in the bottom-right corner (e.g. presence dot,
/// verification check).
///
/// Fallback chain:
/// 1. [imageUrl] (non-empty) — renders as a `NetworkImage` cover.
/// 2. [initials] (non-empty) — uppercased, max 2 chars.
/// 3. `Icons.person` — neutral placeholder.
class SakaiAvatar extends StatelessWidget {
  const SakaiAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = SakaiAvatarSize.md,
    this.badge,
  });

  final String? imageUrl;
  final String? initials;
  final SakaiAvatarSize size;
  final Widget? badge;

  double get _diameter => switch (size) {
        SakaiAvatarSize.sm => 24.0,
        SakaiAvatarSize.md => 40.0,
        SakaiAvatarSize.lg => 64.0,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final hasInitials = initials != null && initials!.isNotEmpty;

    Widget? inner;
    if (!hasImage && hasInitials) {
      final raw = initials!;
      final display = (raw.length > 2 ? raw.substring(0, 2) : raw).toUpperCase();
      inner = Text(
        display,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: scheme.onPrimaryContainer),
      );
    } else if (!hasImage && !hasInitials) {
      inner = Icon(
        Icons.person,
        size: _diameter * 0.55,
        color: scheme.onPrimaryContainer,
      );
    }

    final core = Container(
      width: _diameter,
      height: _diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primaryContainer,
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: inner,
    );

    if (badge == null) return core;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        core,
        Positioned(right: -2, bottom: -2, child: badge!),
      ],
    );
  }
}
