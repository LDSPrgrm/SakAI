import 'package:flutter/widgets.dart';

/// Reusable form-field validators returning `null` on success or a localized
/// error message on failure. Designed to compose with [SakaiFormField] and
/// any [FormField]-style API.
class SakaiValidators {
  SakaiValidators._();

  /// Non-empty (after trimming whitespace).
  static String? required(String? value, {String message = 'Required'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  /// RFC-5322-lite email shape. Returns `null` for empty input so callers may
  /// compose with [required] when the field is mandatory.
  static String? email(
    String? value, {
    String message = 'Enter a valid email',
  }) {
    if (value == null || value.isEmpty) return null;
    final pattern = RegExp(
      r"^[\w!#$%&'*+/=?^_`{|}~.-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$",
    );
    return pattern.hasMatch(value.trim()) ? null : message;
  }

  /// PH-friendly phone: 10-13 digits, optional leading `+`. Strips common
  /// formatting (spaces, dashes, parens) before matching. Returns `null` for
  /// empty input; pair with [required] for mandatory fields.
  static String? phone(
    String? value, {
    String message = 'Enter a valid phone number',
  }) {
    if (value == null || value.isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'[\s\-()]'), '');
    final pattern = RegExp(r'^\+?\d{10,13}$');
    return pattern.hasMatch(digits) ? null : message;
  }

  /// Length floor. Treats `null` as length 0.
  static String? minLength(String? value, int min, {String? message}) {
    final length = value?.length ?? 0;
    if (length < min) return message ?? 'Minimum $min characters';
    return null;
  }

  /// Run [validators] left-to-right; return the first non-null error.
  static FormFieldValidator<String> combine(
    List<FormFieldValidator<String>> validators,
  ) {
    return (value) {
      for (final v in validators) {
        final result = v(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
