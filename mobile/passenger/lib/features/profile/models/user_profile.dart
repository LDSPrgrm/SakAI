/// Domain model for a user profile in the passenger app.
/// Wraps the generated [UserProfile] from the API client with additional
/// fields and validation helpers tailored for the mobile UI.
library;

import 'package:sakai_api_client/sakai_api_client.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.rating,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final double? rating;
  final String role;
  final DateTime createdAt;

  /// Returns the user's initials for avatar display.
  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Creates a copy with the given fields replaced.
  UserProfileModel copyWith({String? name, String? phone, double? rating}) {
    return UserProfileModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      role: role,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          rating == other.rating &&
          role == other.role &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      rating.hashCode ^
      role.hashCode ^
      createdAt.hashCode;

  /// Factory constructor from the generated API UserProfile.
  factory UserProfileModel.fromApiUserProfile(
    UserProfile apiProfile, {
    double? rating,
  }) {
    return UserProfileModel(
      id: apiProfile.id,
      name: apiProfile.name,
      email: apiProfile.email,
      phone: null, // Not in the generated API model yet
      rating: rating,
      role: apiProfile.role.name,
      createdAt: apiProfile.createdAt,
    );
  }
}

/// Validation helpers for profile fields.
class ProfileValidation {
  /// Validates name: must be 1-100 non-whitespace characters.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 100) {
      return 'Name must be between 1 and 100 characters';
    }
    return null;
  }

  /// Validates email format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates phone in E.164 format: +[country code][number], max 15 digits.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    final trimmed = value.trim();
    final phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Phone must be in E.164 format (e.g., +1234567890)';
    }
    return null;
  }
}
