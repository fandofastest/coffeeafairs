import '../domain/menu_item.dart';
import '../domain/menu_repository.dart';
import 'menu_api_service.dart';
import 'menu_item_mapper.dart';

class MenuRepositoryImpl implements MenuRepository {
  const MenuRepositoryImpl(this._api);

  final MenuApiService _api;

  @override
  Future<List<MenuItem>> listMenuItems() async {
    final dtos = await _api.listMenuItems();
    return dtos.map(menuItemFromDto).toList(growable: false);
  }
}
