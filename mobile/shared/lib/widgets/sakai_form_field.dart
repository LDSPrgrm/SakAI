import 'package:flutter/material.dart';

import '../theme/sakai_design_tokens.dart';
import 'sakai_text_field.dart';

/// Labeled wrapper around [SakaiTextField] with explicit label + helper/error
/// semantics. Renders an external label (so we can decorate required fields
/// with a leading `*`) and an externally rendered helper/error line below
/// the field. `errorText` is consumed by this widget directly (NOT forwarded
/// to the underlying [SakaiTextField]) so Material's built-in error chrome
/// does not double up with the external error text we render.
class SakaiFormField extends StatelessWidget {
  const SakaiFormField({
    super.key,
    required this.label,
    this.controller,
    this.helperText,
    this.errorText,
    this.required = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.hintText,
    this.maxLines = 1,
    this.focusNode,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? helperText;
  final String? errorText;
  final bool required;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final String? hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final tokens = SakaiDesignTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: tokens.spaceXs),
          child: Text.rich(
            TextSpan(
              style: labelStyle,
              children: [
                TextSpan(text: label),
                if (required)
                  TextSpan(
                    text: ' *',
                    style: labelStyle?.copyWith(color: scheme.error),
                  ),
              ],
            ),
          ),
        ),
        SakaiTextField(
          controller: controller,
          focusNode: focusNode,
          hint: hintText,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          enabled: enabled,
          maxLines: maxLines,
          // Pass `null` so Material's built-in helper line doesn't double up
          // with our externally rendered helper/error Text below.
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: tokens.spaceXs),
            child: Text(
              errorText!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.error),
            ),
          )
        else if (helperText != null)
          Padding(
            padding: EdgeInsets.only(top: tokens.spaceXs),
            child: Text(
              helperText!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
