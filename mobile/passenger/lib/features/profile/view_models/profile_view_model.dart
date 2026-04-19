import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../repositories/profile_repository.dart';
import '../../../app/providers.dart';

/// State of the profile loading operation.
class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
  });

  final ProfileStatus status;
  final UserProfileModel? profile;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfileModel? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}

enum ProfileStatus { initial, loading, loaded, error }

/// Riverpod provider for the ProfileRepository.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(apiClientProvider));
});

/// Notifier for the profile display screen.
class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  /// Loads the user profile from the API.
  Future<void> loadProfile() async {
    state = const ProfileState(status: ProfileStatus.loading);

    try {
      final profile = await _repository.getProfile();
      state = ProfileState(status: ProfileStatus.loaded, profile: profile);
    } on ProfileError catch (e) {
      debugPrint('[ProfileNotifier] Error loading profile: ${e.message}');
      state = ProfileState(
        status: ProfileStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      debugPrint('[ProfileNotifier] Unexpected error: $e');
      state = const ProfileState(
        status: ProfileStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  /// Refreshes the profile data.
  Future<void> refresh() async {
    await loadProfile();
  }
}

/// Riverpod provider for the ProfileNotifier.
final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
