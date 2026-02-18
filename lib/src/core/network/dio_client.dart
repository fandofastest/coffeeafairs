import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../errors/app_exception.dart';
import 'retry_policy.dart';

Dio createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.transformer = BackgroundTransformer();

  dio.interceptors.add(_RetryInterceptor(dio: dio, policy: const RetryPolicy()));

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (o) => debugPrint(o.toString()),
      ),
    );
  }

  return dio;
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor({required this.dio, required this.policy});

  final Dio dio;
  final RetryPolicy policy;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final attempt = (requestOptions.extra['retry_attempt'] as int?) ?? 0;

    if (attempt >= policy.maxRetries || !policy.shouldRetry(err)) {
      return handler.next(err);
    }

    requestOptions.extra['retry_attempt'] = attempt + 1;

    await Future<void>.delayed(policy.delayForAttempt(attempt));

    try {
      final response = await dio.fetch(requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}

AppException mapDioException(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return NetworkException('Connection timeout. Please try again.');
  }

  if (e.type == DioExceptionType.connectionError) {
    return NetworkException('No internet connection. Please check and retry.');
  }

  final status = e.response?.statusCode;
  if (status != null) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'];
        final code = error['code'];
        if (message is String && message.trim().isNotEmpty) {
          return ServerException(message, code: code is String ? code : null);
        }
      }
    }

    if (status >= 500) {
      return ServerException('Server is having trouble. Please try again later.');
    }

    return ServerException('Request failed. Please try again.');
  }

  return NetworkException('Network error. Please try again.');
}
