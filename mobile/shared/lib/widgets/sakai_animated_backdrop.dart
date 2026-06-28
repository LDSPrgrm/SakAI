import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium, hardware-accelerated animated backdrop for SakAI applications.
/// Draws three colored blurred organic spheres that orbit on distinct cyclical curves,
/// creating a living, breathing glassmorphism mesh gradient background.
///
/// **Testing**: Set [SakaiAnimatedBackdrop.debugDisableAnimations] to `true`
/// in your test `setUp()` (and reset in `tearDown()`) to prevent the infinite
/// repeat loop from blocking `tester.pumpAndSettle()`.
class SakaiAnimatedBackdrop extends StatefulWidget {
  const SakaiAnimatedBackdrop({
    super.key,
    this.child,
    this.orbitDuration = const Duration(seconds: 30),
  });

  final Widget? child;
  final Duration orbitDuration;

  /// When `true`, the animation controller will not call `.repeat()`.
  /// Intended only for widget tests where an infinite animation would cause
  /// `pumpAndSettle` to time out. Reset to `false` in `tearDown`.
  // ignore: do_not_use_environment
  static bool debugDisableAnimations = false;

  @override
  State<SakaiAnimatedBackdrop> createState() => _SakaiAnimatedBackdropState();
}

class _SakaiAnimatedBackdropState extends State<SakaiAnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.orbitDuration,
    );
    if (!SakaiAnimatedBackdrop.debugDisableAnimations) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surfaceColor = scheme.surface;

    // Curate highly elegant transparent accent color tints based on the current theme
    final color1 = scheme.primary.withValues(alpha: 0.16);
    final color2 = scheme.secondary.withValues(alpha: 0.12);
    final color3 = scheme.tertiaryContainer.withValues(alpha: 0.10);

    return Stack(
      children: [
        // Base solid background color matching the active theme scaffold or surface color
        Positioned.fill(
          child: Container(
            color: surfaceColor,
          ),
        ),
        // Orbital Organic Blobs Layer
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _MeshGradientPainter(
                  progress: _controller.value,
                  color1: color1,
                  color2: color2,
                  color3: color3,
                ),
              );
            },
          ),
        ),
        // Brand Graphic: translucent ride-hailing visual identity
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _BrandPainter(
                  color: scheme.onPrimary,
                  primaryColor: scheme.primary,
                  pulse: _controller.value,
                ),
              );
            },
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _BrandPainter extends CustomPainter {
  _BrandPainter({
    required this.color,
    required this.primaryColor,
    required this.pulse,
  });

  final Color color;
  final Color primaryColor;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    // Position lotus in the upper section of the screen
    final center = Offset(size.width / 2, size.height * 0.3);

    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    void drawPetal(double angle, double scaleX, double scaleY) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final path = Path();
      path.moveTo(0, 50);
      path.quadraticBezierTo(-60 * scaleX, -40 * scaleY, 0, -120 * scaleY);
      path.quadraticBezierTo(60 * scaleX, -40 * scaleY, 0, 50);

      canvas.drawPath(path, paint);
      canvas.drawPath(path, outlinePaint);

      canvas.restore();
    }

    // Outer lower petals
    drawPetal(1.1, 0.9, 0.7);
    drawPetal(-1.1, 0.9, 0.7);

    // Mid petals
    drawPetal(0.6, 1.0, 1.1);
    drawPetal(-0.6, 1.0, 1.1);

    // Central highest petal
    drawPetal(0, 1.1, 1.5);
  }

  @override
  bool shouldRepaint(covariant _BrandPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.pulse != pulse;
}


class _MeshGradientPainter extends CustomPainter {
  _MeshGradientPainter({
    required this.progress,
    required this.color1,
    required this.color2,
    required this.color3,
  });

  final double progress;
  final Color color1;
  final Color color2;
  final Color color3;

  @override
  void paint(Canvas canvas, Size size) {
    final angle = progress * 2 * math.pi;

    // Organic orbit 1: upper right quadrant
    final dx1 = size.width * 0.75 + math.cos(angle) * (size.width * 0.15);
    final dy1 = size.height * 0.25 + math.sin(angle) * (size.height * 0.12);
    final radius1 = size.width * 0.5;

    // Organic orbit 2: bottom left quadrant
    final dx2 = size.width * 0.20 + math.sin(angle * 0.8) * (size.width * 0.12);
    final dy2 = size.height * 0.75 + math.cos(angle * 0.8) * (size.height * 0.10);
    final radius2 = size.width * 0.55;

    // Organic orbit 3: slow central-left ellipse
    final dx3 = size.width * 0.45 + math.cos(angle * 0.5) * (size.width * 0.20);
    final dy3 = size.height * 0.50 + math.sin(angle * 0.5) * (size.height * 0.15);
    final radius3 = size.width * 0.45;

    // Apply native blur mask filter for high performance and smooth organic blending
    final paint1 = Paint()
      ..color = color1
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
    final paint2 = Paint()
      ..color = color2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    final paint3 = Paint()
      ..color = color3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    canvas.drawCircle(Offset(dx1, dy1), radius1, paint1);
    canvas.drawCircle(Offset(dx2, dy2), radius2, paint2);
    canvas.drawCircle(Offset(dx3, dy3), radius3, paint3);
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2 ||
        oldDelegate.color3 != color3;
  }
}
