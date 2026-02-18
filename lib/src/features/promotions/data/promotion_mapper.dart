import '../domain/promotion.dart';
import 'promotion_dto.dart';

Promotion promotionFromDto(PromotionDto dto) {
  return Promotion(
    id: dto.id,
    title: dto.title,
    description: dto.description,
    imageUrl: dto.imageUrl,
    startDate: dto.startsAt,
    endDate: dto.endsAt,
  );
}
