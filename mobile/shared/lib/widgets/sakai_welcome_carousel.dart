import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/sakai_design_tokens.dart';

class SakaiWelcomeSlide {
  final IconData icon;
  final String title;
  final String description;

  const SakaiWelcomeSlide({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// A reusable welcome carousel for onboarding.
class SakaiWelcomeCarousel extends StatefulWidget {
  final List<SakaiWelcomeSlide> slides;
  final VoidCallback onComplete;

  const SakaiWelcomeCarousel({
    super.key,
    required this.slides,
    required this.onComplete,
  });

  @override
  State<SakaiWelcomeCarousel> createState() => _SakaiWelcomeCarouselState();
}

class _SakaiWelcomeCarouselState extends State<SakaiWelcomeCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == widget.slides.length - 1;
    final scheme = Theme.of(context).colorScheme;
    final tokens = SakaiDesignTokens.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          // Background decoration (subtle gradient blob)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primaryContainer.withValues(alpha: 0.5),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spaceLg),
                    child: TextButton(
                      onPressed: widget.onComplete,
                      child: Text(
                        'Skip',
                        style: textTheme.labelLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),

                // Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: widget.slides.length,
                    itemBuilder: (context, index) {
                      return _SlideContent(slide: widget.slides[index]);
                    },
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    tokens.spaceXl,
                    0,
                    tokens.spaceXl,
                    tokens.spaceXl * 2,
                  ),
                  child: Column(
                    children: [
                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutQuart,
                            margin: EdgeInsets.symmetric(
                              horizontal: tokens.spaceXs,
                            ),
                            width: _currentPage == index ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentPage == index
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: tokens.spaceXl),

                      // CTA Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isLastPage) {
                              widget.onComplete();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutQuart,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 8,
                            shadowColor: scheme.primary.withValues(alpha: 0.3),
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                tokens.radiusLg,
                              ),
                            ),
                          ),
                          child: Text(
                            isLastPage ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  final SakaiWelcomeSlide slide;

  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.surfaceContainerHighest,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(slide.icon, size: 80, color: scheme.primary),
              ],
            ),
          ),
          const SizedBox(height: 64),

          // Title
          Text(
            slide.title,
            style: textTheme.headlineLarge?.copyWith(
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            slide.description,
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
