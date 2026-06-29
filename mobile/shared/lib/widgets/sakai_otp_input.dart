import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/sakai_design_tokens.dart';

/// Multi-cell OTP / PIN entry. Each cell holds one digit; auto-advances on
/// input and steps back on delete. Calls [onCompleted] when [length] digits
/// are filled and [onChanged] on every edit with the current concatenated
/// value.
class SakaiOtpInput extends StatefulWidget {
  const SakaiOtpInput({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.errorText,
    this.autofocus = true,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final String? errorText;
  final bool autofocus;

  @override
  State<SakaiOtpInput> createState() => _SakaiOtpInputState();
}

class _SakaiOtpInputState extends State<SakaiOtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _onDigit(int index, String value) {
    if (value.length > 1) {
      // Paste — distribute across cells.
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final next = digits.length >= widget.length
          ? widget.length - 1
          : digits.length;
      _focusNodes[next].requestFocus();
    } else if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final current = _value;
    widget.onChanged?.call(current);
    if (current.length == widget.length && !current.contains('')) {
      widget.onCompleted?.call(current);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(widget.length, (i) {
            return SizedBox(
              width: 48,
              height: 56,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                enabled: widget.enabled,
                autofocus: widget.autofocus && i == 0,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: Theme.of(context).textTheme.headlineSmall,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(t.radiusSm),
                    borderSide: BorderSide(
                      color: hasError ? scheme.error : Colors.transparent,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(t.radiusSm),
                    borderSide: BorderSide(
                      color: hasError ? scheme.error : scheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (v) => _onDigit(i, v),
              ),
            );
          }),
        ),
        if (hasError) ...[
          SizedBox(height: t.spaceXs),
          Text(
            widget.errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.error,
                ),
          ),
        ],
      ],
    );
  }
}
