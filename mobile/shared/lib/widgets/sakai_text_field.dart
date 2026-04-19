import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';

/// Text field aligned with shared [InputDecorationTheme] and spacing tokens.
class SakaiTextField extends StatelessWidget {
  const SakaiTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.errorText,
    this.focusNode,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int maxLines;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: t.spaceSm),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        enabled: enabled,
        maxLines: obscureText ? 1 : maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          errorText: errorText,
        ),
      ),
    );
  }
}
