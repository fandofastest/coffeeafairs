import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import 'category_dto.dart';

class CategoriesApiService {
  const CategoriesApiService(this._dio);

  final Dio _dio;

  Future<List<CategoryDto>> listCategories() async {
    try {
      final res = await _dio.get(
        '/categories',
        options: Options(
          sendTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final list = data['categories'];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => CategoryDto.fromJson(e.cast<String, dynamic>()))
              .toList(growable: false);
        }
      }
      throw ParsingException('Unexpected response from server.');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
