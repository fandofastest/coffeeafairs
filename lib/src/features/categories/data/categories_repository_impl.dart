import '../domain/category.dart';
import '../domain/categories_repository.dart';
import 'categories_api_service.dart';
import 'category_mapper.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  const CategoriesRepositoryImpl(this._api);

  final CategoriesApiService _api;

  @override
  Future<List<Category>> listCategories() async {
    final dtos = await _api.listCategories();
    return dtos.map(categoryFromDto).toList(growable: false);
  }
}
