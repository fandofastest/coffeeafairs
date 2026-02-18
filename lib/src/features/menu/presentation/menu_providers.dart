import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/dio_providers.dart';
import '../data/menu_api_service.dart';
import '../data/menu_repository_impl.dart';
import '../domain/menu_item.dart';
import '../domain/menu_repository.dart';

final menuApiServiceProvider = Provider<MenuApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return MenuApiService(dio);
});

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final api = ref.watch(menuApiServiceProvider);
  return MenuRepositoryImpl(api);
});

final menuProvider = FutureProvider<List<MenuItem>>((ref) async {
  final repo = ref.watch(menuRepositoryProvider);
  return repo.listMenuItems();
});

final menuSearchQueryProvider = StateProvider<String>((ref) => '');
