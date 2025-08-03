import 'dart:async';
import 'dart:io';
import 'app_exceptions.dart';

class ErrorHandler {
  static AppException handleError(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is SocketException) {
      return NetworkException(
          'No internet connection. Please check your network settings.');
    }

    if (error is HttpException) {
      return NetworkException('Network error occurred. Please try again.');
    }

    if (error is FormatException) {
      return ServerException('Invalid response format from server.', 500);
    }

    if (error is TimeoutException) {
      return NetworkException('Request timeout. Please try again.');
    }

    // Handle HTTP response errors
    if (error.toString().contains('Failed to load') ||
        error.toString().contains('Failed to update') ||
        error.toString().contains('Failed to add') ||
        error.toString().contains('Failed to delete')) {
      // Extract status code if available
      final statusCodeMatch = RegExp(r'(\d{3})').firstMatch(error.toString());
      if (statusCodeMatch != null) {
        final statusCode = int.parse(statusCodeMatch.group(1)!);
        return _handleHttpStatusCode(statusCode, error.toString());
      }
    }

    // Generic error
    return ServerException(
        'An unexpected error occurred. Please try again.', 500);
  }

  static AppException _handleHttpStatusCode(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        return ValidationException('Invalid request. Please check your input.');
      case 401:
        return AuthenticationException(
            'Authentication failed. Please log in again.');
      case 403:
        return AuthorizationException(
            'You don\'t have permission to perform this action.');
      case 404:
        return NotFoundException('The requested resource was not found.');
      case 409:
        return ConflictException(
            'A conflict occurred. The resource may already exist.');
      case 422:
        return ValidationException(
            'Validation failed. Please check your input.');
      case 429:
        return ServerException(
            'Too many requests. Please try again later.', statusCode);
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
            'Server error. Please try again later.', statusCode);
      default:
        return ServerException(message, statusCode);
    }
  }

  static String getErrorMessage(AppException exception) {
    if (exception is NetworkException) {
      return exception.message;
    }

    if (exception is ValidationException) {
      if (exception.fieldErrors != null && exception.fieldErrors!.isNotEmpty) {
        return exception.fieldErrors!.values.first;
      }
      return exception.message;
    }

    return exception.message;
  }

  static bool isNetworkError(AppException exception) {
    return exception is NetworkException;
  }

  static bool isAuthError(AppException exception) {
    return exception is AuthenticationException ||
        exception is AuthorizationException;
  }
}
