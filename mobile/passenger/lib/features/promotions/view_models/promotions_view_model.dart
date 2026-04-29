import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
import '../../../app/providers.dart';
import '../repositories/promotions_repository.dart';
import '../repositories/promotions_repository_impl.dart';

/// State for the promotions screen.
class PromotionsState {
  const PromotionsState({
    this.status = PromotionsStatus.initial,
    this.promotions = const [],
    this.validatedPromotion,
    this.errorMessage,
  });

  final PromotionsStatus status;
  final List<api.Promotion> promotions;
  final api.Promotion? validatedPromotion;
  final String? errorMessage;

  bool get isLoading => status == PromotionsStatus.loading;

  PromotionsState copyWith({
    PromotionsStatus? status,
    List<api.Promotion>? promotions,
    api.Promotion? validatedPromotion,
    String? errorMessage,
  }) {
    return PromotionsState(
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
      validatedPromotion: validatedPromotion ?? this.validatedPromotion,
      errorMessage: errorMessage,
    );
  }
}

enum PromotionsStatus { initial, loading, loaded, error }

/// Provider for the PromotionsRepository.
final promotionsRepositoryProvider = Provider<PromotionsRepository>((ref) {
  return PromotionsRepositoryImpl(ref.watch(apiClientProvider).getUsersApi());
});

/// Notifier for the promotions screen.
class PromotionsNotifier extends Notifier<PromotionsState> {
  @override
  PromotionsState build() => const PromotionsState();

  PromotionsRepository get _repository => ref.read(promotionsRepositoryProvider);

  /// Fetches available promotions.
  Future<void> fetchPromotions() async {
    state = state.copyWith(status: PromotionsStatus.loading);

    try {
      final promotions = await _repository.getPromotions();
      state = PromotionsState(status: PromotionsStatus.loaded, promotions: promotions);
    } catch (e) {
      debugPrint('[PromotionsNotifier] Error fetching promotions: $e');
      state = PromotionsState(
        status: PromotionsStatus.error,
        errorMessage: 'Failed to load promotions',
      );
    }
  }

  /// Validates a promo code.
  Future<bool> validatePromo(String code, {double? rideFare}) async {
    state = state.copyWith(status: PromotionsStatus.loading, errorMessage: null);

    try {
      final promo = await _repository.validatePromoCode(code, rideFare: rideFare);
      state = state.copyWith(
        status: PromotionsStatus.loaded,
        validatedPromotion: promo,
      );
      return true;
    } catch (e) {
      debugPrint('[PromotionsNotifier] Error validating promo: $e');
      state = state.copyWith(
        status: PromotionsStatus.error,
        errorMessage: 'Invalid or expired promo code',
      );
      return false;
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null, status: PromotionsStatus.initial);
    }
  }
}

/// Riverpod provider for the PromotionsNotifier.
final promotionsNotifierProvider = NotifierProvider<PromotionsNotifier, PromotionsState>(
  PromotionsNotifier.new,
);
