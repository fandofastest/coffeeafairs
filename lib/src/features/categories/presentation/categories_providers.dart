import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/dio_providers.dart';
import '../data/categories_api_service.dart';
import '../data/categories_repository_impl.dart';
import '../domain/categories_repository.dart';
import '../domain/category.dart';

final categoriesApiServiceProvider = Provider<CategoriesApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return CategoriesApiService(dio);
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final api = ref.watch(categoriesApiServiceProvider);
  return CategoriesRepositoryImpl(api);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(categoriesRepositoryProvider);
  final all = await repo.listCategories();
  return all.where((c) => c.isActive).toList(growable: false);
});

final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);
