import '../domain/category.dart';
import 'category_dto.dart';

Category categoryFromDto(CategoryDto dto) {
  return Category(
    id: dto.id,
    name: dto.name,
    isActive: dto.isActive,
  );
}
