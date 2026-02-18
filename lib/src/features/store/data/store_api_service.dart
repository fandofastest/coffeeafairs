import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import 'store_dto.dart';

class StoreApiService {
  const StoreApiService(this._dio);

  final Dio _dio;

  Future<StoreDto?> getStore() async {
    try {
      final res = await _dio.get('/store');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final store = data['store'];
        if (store == null) return null;
        if (store is Map<String, dynamic>) {
          return StoreDto.fromJson(store);
        }
      }
      throw ParsingException('Unexpected response from server.');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
