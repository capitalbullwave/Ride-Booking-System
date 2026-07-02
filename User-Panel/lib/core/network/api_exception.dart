class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([
    String message =
        'No internet connection. Check your network or enable mock mode for local testing.',
  ]) : super(message: message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([String message = 'Session expired. Please login again.'])
      : super(message: message, statusCode: 401);
}

class ServerException extends ApiException {
  const ServerException([String message = 'Server error. Please try again later.'])
      : super(message: message, statusCode: 500);
}

class ValidationException extends ApiException {
  const ValidationException(String message) : super(message: message, statusCode: 422);
}
