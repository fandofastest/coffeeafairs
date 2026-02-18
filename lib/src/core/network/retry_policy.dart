import 'dart:math';

import 'package:dio/dio.dart';

class RetryPolicy {
  const RetryPolicy({
    this.maxRetries = 2,
    this.baseDelayMs = 300,
  });

  final int maxRetries;
  final int baseDelayMs;

  bool shouldRetry(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return true;
    }

    final status = e.response?.statusCode;
    if (status != null && status >= 500) return true;

    return false;
  }

  Duration delayForAttempt(int attempt) {
    final ms = baseDelayMs * pow(2, attempt).toInt();
    return Duration(milliseconds: ms.clamp(baseDelayMs, 4000));
  }
}
