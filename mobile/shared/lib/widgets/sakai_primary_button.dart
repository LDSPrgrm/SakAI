import 'package:flutter/material.dart';

/// Primary call-to-action; uses [FilledButton] and the app [ThemeData].
class SakaiPrimaryButton extends StatelessWidget {
  const SakaiPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEnabled = onPressed != null;

    final childWidget = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          )
        : Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          );

    final button = FilledButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: isEnabled ? 4 : 0,
        shadowColor: scheme.primary.withValues(alpha: 0.25),
      ),
      onPressed: onPressed,
      child: childWidget,
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
