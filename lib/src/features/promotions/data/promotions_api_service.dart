import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import 'promotion_dto.dart';

class PromotionsApiService {
  const PromotionsApiService(this._dio);

  final Dio _dio;

  Future<List<PromotionDto>> listPromotions() async {
    try {
      final res = await _dio.get('/promotions');
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final list = data['promotions'];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => PromotionDto.fromJson(e.cast<String, dynamic>()))
              .toList(growable: false);
        }
      }
      throw ParsingException('Unexpected response from server.');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
