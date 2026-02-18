import '../domain/store.dart';
import '../domain/store_repository.dart';
import 'store_api_service.dart';
import 'store_mapper.dart';

class StoreRepositoryImpl implements StoreRepository {
  const StoreRepositoryImpl(this._api);

  final StoreApiService _api;

  @override
  Future<Store?> getStore() async {
    final dto = await _api.getStore();
    if (dto == null) return null;
    return storeFromDto(dto);
  }
}
