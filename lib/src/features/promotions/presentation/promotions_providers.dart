import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/dio_providers.dart';
import '../data/promotions_api_service.dart';
import '../data/promotions_repository_impl.dart';
import '../domain/promotion.dart';
import '../domain/promotions_repository.dart';

final promotionsApiServiceProvider = Provider<PromotionsApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return PromotionsApiService(dio);
});

final promotionsRepositoryProvider = Provider<PromotionsRepository>((ref) {
  final api = ref.watch(promotionsApiServiceProvider);
  return PromotionsRepositoryImpl(api);
});

final promotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  final repo = ref.watch(promotionsRepositoryProvider);
  return repo.listPromotions();
});
