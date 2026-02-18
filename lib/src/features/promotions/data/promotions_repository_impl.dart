import '../domain/promotion.dart';
import '../domain/promotions_repository.dart';
import 'promotion_mapper.dart';
import 'promotions_api_service.dart';

class PromotionsRepositoryImpl implements PromotionsRepository {
  const PromotionsRepositoryImpl(this._api);

  final PromotionsApiService _api;

  @override
  Future<List<Promotion>> listPromotions() async {
    final dtos = await _api.listPromotions();
    return dtos.map(promotionFromDto).toList(growable: false);
  }
}
