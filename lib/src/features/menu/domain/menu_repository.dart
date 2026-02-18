import 'menu_item.dart';

abstract class MenuRepository {
  Future<List<MenuItem>> listMenuItems();
}
