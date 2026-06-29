import 'package:flutter/material.dart';
import 'package:sakai_shared/sakai_shared.dart';

/// Personalized Explore/Destinations section.
class HomeExploreSection extends StatelessWidget {
  const HomeExploreSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);
    final places = [
      {'label': 'Work', 'icon': Icons.work_rounded},
      {'label': 'Gym', 'icon': Icons.fitness_center_rounded},
      {'label': 'Coffee', 'icon': Icons.local_cafe_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where to next?',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: tokens.spaceMd),
        Row(
          children: places.map((place) => Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spaceXs),
              child: _PlaceButton(label: place['label'] as String, icon: place['icon'] as IconData),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

class _PlaceButton extends StatelessWidget {
  const _PlaceButton({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(tokens.spaceMd),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        SizedBox(height: tokens.spaceXs),
        Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
