import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/dio_providers.dart';
import '../data/store_api_service.dart';
import '../data/store_repository_impl.dart';
import '../domain/store.dart';
import '../domain/store_repository.dart';

final storeApiServiceProvider = Provider<StoreApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return StoreApiService(dio);
});

final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  final api = ref.watch(storeApiServiceProvider);
  return StoreRepositoryImpl(api);
});

final storeProvider = FutureProvider<Store?>((ref) async {
  final repo = ref.watch(storeRepositoryProvider);
  return repo.getStore();
});
