class AppException implements Exception {
  AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

class ServerException extends AppException {
  ServerException(super.message, {super.code});
}

class ParsingException extends AppException {
  ParsingException(super.message, {super.code});
}
