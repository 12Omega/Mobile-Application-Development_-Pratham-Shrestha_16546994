import 'package:dio/dio.dart';
import 'package:parkease/core/services/storage_service.dart';
import 'package:parkease/core/utils/app_config.dart';
import 'package:get_it/get_it.dart';

class ApiService {
  late Dio _dio;
  late final StorageService _storageService;

  ApiService() {
    _storageService = GetIt.instance<StorageService>();
    _initDio();
  }

  void _initDio() {
    final baseOptions = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(baseOptions);

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _storageService.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (AppConfig.isDebug) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  // Generic GET request
  Future<dynamic> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Generic POST request
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Generic PUT request
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return _processResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Process API response
  dynamic _processResponse(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response.data;
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
      case 403:
        throw UnauthorizedException(response.data.toString());
      case 404:
        throw NotFoundException(response.data.toString());
      case 500:
      default:
        throw ServerException(
          'Error occurred with status code: ${response.statusCode}',
        );
    }
  }

  // Handle Dio errors
  dynamic _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException(error.message ?? 'Connection timeout');
      case DioExceptionType.badResponse:
        return _processResponse(error.response!);
      case DioExceptionType.cancel:
        throw RequestCancelledException(error.message ?? 'Request cancelled');
      case DioExceptionType.connectionError:
        throw NoInternetException(error.message ?? 'No internet connection');
      default:
        throw UnknownException(error.message ?? 'Unknown error occurred');
    }
  }

  // Get user stats
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await get('/users/stats');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get user stats',
      };
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}

class NoInternetException extends ApiException {
  NoInternetException(String message) : super(message);
}

class RequestCancelledException extends ApiException {
  RequestCancelledException(String message) : super(message);
}

class UnknownException extends ApiException {
  UnknownException(String message) : super(message);
}
