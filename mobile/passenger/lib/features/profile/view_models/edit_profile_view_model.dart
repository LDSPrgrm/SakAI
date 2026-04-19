import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import 'profile_view_model.dart';

/// State machine for the edit profile screen.
class EditProfileState {
  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.name = '',
    this.phone = '',
    this.nameError,
    this.phoneError,
    this.errorMessage,
  });

  final EditProfileStatus status;
  final String name;
  final String phone;
  final String? nameError;
  final String? phoneError;
  final String? errorMessage;

  bool get isSaving => status == EditProfileStatus.saving;
  bool get isSuccess => status == EditProfileStatus.success;

  EditProfileState copyWith({
    EditProfileStatus? status,
    String? name,
    String? phone,
    String? nameError,
    String? phoneError,
    String? errorMessage,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nameError: nameError,
      phoneError: phoneError,
      errorMessage: errorMessage,
    );
  }
}

enum EditProfileStatus { initial, saving, success, error }

/// Notifier for the edit profile screen.
class EditProfileNotifier extends Notifier<EditProfileState> {
  @override
  EditProfileState build() => const EditProfileState();

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  /// Initializes the form fields from an existing profile.
  void initFromProfile(UserProfileModel profile) {
    state = EditProfileState(name: profile.name, phone: profile.phone ?? '');
  }

  /// Updates the name field and clears any validation error.
  void updateName(String value) {
    state = state.copyWith(name: value, nameError: null);
  }

  /// Updates the phone field and clears any validation error.
  void updatePhone(String value) {
    state = state.copyWith(phone: value, phoneError: null);
  }

  /// Validates the name field. Returns true if valid.
  bool validateName() {
    final error = ProfileValidation.validateName(state.name);
    if (error != null) {
      state = state.copyWith(nameError: error);
    }
    return error == null;
  }

  /// Validates the phone field. Returns true if valid.
  bool validatePhone() {
    final error = ProfileValidation.validatePhone(state.phone);
    if (error != null) {
      state = state.copyWith(phoneError: error);
    }
    return error == null;
  }

  /// Validates all fields. Returns true if all are valid.
  bool validateAll() {
    final nameValid = validateName();
    final phoneValid = validatePhone();
    return nameValid && phoneValid;
  }

  /// Saves the profile changes to the API.
  /// Returns true on success, false on failure.
  Future<bool> saveProfile() async {
    if (!validateAll()) {
      return false;
    }

    state = state.copyWith(
      status: EditProfileStatus.saving,
      errorMessage: null,
    );

    try {
      final trimmedName = state.name.trim();
      final trimmedPhone = state.phone.trim().isEmpty
          ? null
          : state.phone.trim();

      await _repository.updateProfile(name: trimmedName, phone: trimmedPhone);

      state = state.copyWith(status: EditProfileStatus.success);
      return true;
    } on ProfileError catch (e) {
      debugPrint('[EditProfileNotifier] Save error: ${e.message}');
      state = state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      debugPrint('[EditProfileNotifier] Unexpected error: $e');
      state = state.copyWith(
        status: EditProfileStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Clears any error message.
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(
        errorMessage: null,
        status: EditProfileStatus.initial,
      );
    }
  }
}

/// Riverpod provider for the EditProfileNotifier.
final editProfileNotifierProvider =
    NotifierProvider<EditProfileNotifier, EditProfileState>(
      EditProfileNotifier.new,
    );
