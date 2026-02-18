import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import 'menu_item_dto.dart';

class MenuApiService {
  const MenuApiService(this._dio);

  final Dio _dio;

  Future<List<MenuItemDto>> listMenuItems() async {
    try {
      final res = await _dio.get(
        '/menu',
        options: Options(
          sendTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final list = data['menu'];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => MenuItemDto.fromJson(e.cast<String, dynamic>()))
              .toList(growable: false);
        }
      }
      throw ParsingException('Unexpected response from server.');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
