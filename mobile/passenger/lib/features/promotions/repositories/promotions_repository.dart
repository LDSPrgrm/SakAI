import 'package:sakai_shared/sakai_shared.dart';

abstract class PromotionsRepository {
  Future<List<Promotion>> getPromotions();
  Future<Promotion> validatePromoCode(String code, {double? rideFare});
}
