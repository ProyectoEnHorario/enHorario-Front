import 'package:dio/dio.dart';
import 'package:enhorario/core/config/app_config.dart';
import 'package:enhorario/core/errors/api_exception.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.backendBaseUrl,
        connectTimeout: AppConfig.connectionTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        compact: true,
      ),
    );
  }

  late final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      final options = Options(headers: _headers(token));
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    required dynamic data,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      final options = Options(headers: _headers(token));
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> put<T>(
    String path, {
    required dynamic data,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      final options = Options(headers: _headers(token));
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> delete(String path, {String? token}) async {
    try {
      final options = Options(headers: _headers(token));
      await _dio.delete(path, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, String> _headers(String? token) {
    if (token == null || token.trim().isEmpty) {
      return {};
    }
    return {'Authorization': 'Bearer ${token.trim()}'};
  }

  ApiException _handleError(DioException error) {
    final responseData = error.response?.data;
    String message = error.message ?? 'Error de red';

    if (responseData is Map<String, dynamic>) {
      message =
          responseData['message']?.toString() ??
          responseData['error']?.toString() ??
          message;
    } else if (responseData is String && responseData.isNotEmpty) {
      message = responseData;
    }

    return ApiException(
      message: message,
      statusCode: error.response?.statusCode,
      originalException: error,
    );
  }
}
