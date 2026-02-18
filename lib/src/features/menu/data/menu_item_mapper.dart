import '../domain/menu_item.dart';
import 'menu_item_dto.dart';

MenuItem menuItemFromDto(MenuItemDto dto) {
  return MenuItem(
    id: dto.id,
    name: dto.name,
    description: dto.description,
    price: dto.price,
    currency: dto.currency,
    imageUrl: dto.imageUrl,
    categoryId: dto.categoryId,
    isAvailable: dto.isAvailable,
  );
}
