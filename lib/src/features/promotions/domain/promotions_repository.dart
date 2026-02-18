import 'promotion.dart';

abstract class PromotionsRepository {
  Future<List<Promotion>> listPromotions();
}
