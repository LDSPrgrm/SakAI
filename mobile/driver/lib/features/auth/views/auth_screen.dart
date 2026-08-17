

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';
import '../view_models/login_notifier.dart';
import '../view_models/register_notifier.dart';
import 'widgets/login_form.dart';
import 'widgets/register_form.dart';

enum AuthMode { login, register }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.login});

  final AuthMode initialMode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AuthMode _mode;
  late final AnimationController _staggerController;

  late final Animation<double> _formFade;
  late final Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );


    _formFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
      ),
    );

    _formSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.4, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == AuthMode.login ? AuthMode.register : AuthMode.login;
    });
    // Clear errors when switching
    ref.read(loginNotifierProvider.notifier).clearError();
    ref.read(registerNotifierProvider.notifier).clearError();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for success in both notifiers
    ref.listen<LoginState>(loginNotifierProvider, (_, next) {
      if (next.succeeded && context.mounted) {
        context.go(Routes.home);
      }
    });

    ref.listen<RegisterState>(registerNotifierProvider, (_, next) {
      if (next.succeeded && context.mounted) {
        context.go(Routes.home);
      }
    });

    final scheme = Theme.of(context).colorScheme;

    final tokens = SakaiDesignTokens.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Orbital Organic Blobs Background
          const Positioned.fill(
            child: SakaiAnimatedBackdrop(),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SafeArea(
                          bottom: false,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25,
                          ),
                        ),
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _staggerController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _formFade,
                                child: SlideTransition(
                                  position: _formSlide,
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: scheme.surface,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                                boxShadow: [
                                  BoxShadow(
                                    color: scheme.shadow.withValues(
                                      alpha: 0.05,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: SafeArea(
                                top: false,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      tokens.spaceLg, tokens.spaceXl, tokens.spaceLg, tokens.spaceLg),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 400),
                                        switchInCurve: Curves.easeOutCubic,
                                        switchOutCurve: Curves.easeInCubic,
                                        transitionBuilder:
                                            (Widget child, Animation<double> animation) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0.0, 0.05),
                                                end: Offset.zero,
                                              ).animate(animation),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: _mode == AuthMode.login
                                            ? LoginForm(
                                                key: const ValueKey('login_form'),
                                                onRegisterTap: _toggleMode,
                                              )
                                            : RegisterForm(
                                                key: const ValueKey('register_form'),
                                                onLoginTap: _toggleMode,
                                              ),
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

