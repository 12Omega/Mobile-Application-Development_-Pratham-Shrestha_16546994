abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message, {String? code}) : super(message, code: code);
}

class ServerException extends AppException {
  final int statusCode;
  
  ServerException(String message, this.statusCode, {String? code}) 
      : super(message, code: code);
}

class CacheException extends AppException {
  CacheException(String message, {String? code}) : super(message, code: code);
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  
  ValidationException(String message, {this.fieldErrors, String? code}) 
      : super(message, code: code);
}

class AuthenticationException extends AppException {
  AuthenticationException(String message, {String? code}) : super(message, code: code);
}

class AuthorizationException extends AppException {
  AuthorizationException(String message, {String? code}) : super(message, code: code);
}

class NotFoundException extends AppException {
  NotFoundException(String message, {String? code}) : super(message, code: code);
}

class ConflictException extends AppException {
  ConflictException(String message, {String? code}) : super(message, code: code);
}