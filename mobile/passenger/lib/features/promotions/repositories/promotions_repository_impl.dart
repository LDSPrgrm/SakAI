import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'promotions_repository.dart';

class PromotionsRepositoryImpl implements PromotionsRepository {
  final api.UsersApi _usersApi;

  PromotionsRepositoryImpl(this._usersApi);

  @override
  Future<List<api.Promotion>> getPromotions() async {
    try {
      final response = await _usersApi.promotionsList();
      return response.data?.toList() ?? [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<api.Promotion> validatePromoCode(
    String code, {
    double? rideFare,
  }) async {
    try {
      final request = api.PromotionValidateRequest(
        (b) => b
          ..code = code
          ..rideFare = rideFare,
      );
      final response = await _usersApi.promotionsValidate(
        promotionValidateRequest: request,
      );
      if (response.data == null) {
        throw Exception('Invalid promo code');
      }
      return response.data!;
    } catch (e) {
      rethrow;
    }
  }
}
