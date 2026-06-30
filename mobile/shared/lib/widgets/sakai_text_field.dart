import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/sakai_design_tokens.dart';

/// An elevated, modern text field aligned with SakAI design system tokens.
/// Features a hardware-accelerated animated container that projects an ambient
/// primary glow when the field receives focus, keeping the user in full visual context.
class SakaiTextField extends StatefulWidget {
  const SakaiTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.errorText,
    this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final String? errorText;
  final bool autofocus;

  @override
  State<SakaiTextField> createState() => _SakaiTextFieldState();
}

class _SakaiTextFieldState extends State<SakaiTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // Sine wave for shake
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(SakaiTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
    }

    if (widget.errorText != null && oldWidget.errorText == null) {
      _shakeController.forward(from: 0.0);
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    _shakeController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      if (_focusNode.hasFocus) {
        HapticFeedback.selectionClick();
      }
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: t.spaceMd),
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final offset = sin(_shakeAnimation.value * pi * 3) * 8.0;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: t.durationFast,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(t.radiusFull),
            boxShadow: _isFocused && widget.enabled
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.15),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : const [],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            enabled: widget.enabled,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            decoration: InputDecoration(
              hintText: widget.label ?? widget.hint,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              prefixIcon: widget.prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: _isFocused
                            ? scheme.primary
                            : scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      child: widget.prefixIcon!,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: _isFocused
                            ? scheme.primary
                            : scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      child: widget.suffixIcon!,
                    )
                  : null,
              errorText: widget.errorText,
            ),
          ),
        ),
      ),
    );
  }
}
