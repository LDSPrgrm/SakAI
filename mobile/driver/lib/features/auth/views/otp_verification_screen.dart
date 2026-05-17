import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/router.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, required this.destination});
  final String destination;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  String _code = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(otpNotifierProvider.notifier).sendCode(widget.destination);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(otpNotifierProvider);
    final notifier = ref.read(otpNotifierProvider.notifier);
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);

    ref.listen<OtpState>(otpNotifierProvider, (prev, next) {
      if (next.verified && (prev?.verified ?? false) == false) {
        if (mounted) context.go(Routes.home);
      }
    });

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(t.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Verify your number',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(height: t.spaceSm),
              Text(
                'Enter the 6-digit code we sent to ${widget.destination}.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: t.spaceXl),
              SakaiOtpInput(
                length: 6,
                errorText: state.errorMessage,
                enabled: !state.busy,
                onChanged: (v) {
                  _code = v;
                  if (state.errorMessage != null) notifier.clearError();
                },
                onCompleted: (v) {
                  _code = v;
                  notifier.verifyCode(v);
                },
              ),
              SizedBox(height: t.spaceLg),
              SakaiPrimaryButton(
                label: state.busy ? 'Verifying…' : 'Verify',
                onPressed: state.busy || _code.length != 6
                    ? null
                    : () => notifier.verifyCode(_code),
              ),
              SizedBox(height: t.spaceMd),
              Center(
                child: TextButton(
                  onPressed:
                      state.busy || state.resendCooldownSeconds > 0
                          ? null
                          : () => notifier.sendCode(widget.destination),
                  child: Text(
                    state.resendCooldownSeconds > 0
                        ? 'Resend in ${state.resendCooldownSeconds}s'
                        : 'Resend code',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
