import 'store.dart';

abstract class StoreRepository {
  Future<Store?> getStore();
}
