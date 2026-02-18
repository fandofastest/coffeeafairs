import 'category.dart';

abstract class CategoriesRepository {
  Future<List<Category>> listCategories();
}
