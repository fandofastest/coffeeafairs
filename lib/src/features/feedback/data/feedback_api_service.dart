import 'package:dio/dio.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_client.dart';
import 'feedback_create_dto.dart';

class FeedbackApiService {
  const FeedbackApiService(this._dio);

  final Dio _dio;

  Future<String> submitFeedback(FeedbackCreateDto dto) async {
    try {
      final res = await _dio.post('/feedback', data: dto.toJson());
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final id = data['id'];
        if (id != null) return id.toString();
      }
      throw ParsingException('Unexpected response from server.');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
