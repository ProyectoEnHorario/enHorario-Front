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
        // No definimos contentType global para que Dio lo maneje dinámicamente
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
      final options = Options(
        headers: _headers(token),
      );
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
      final options = Options(
        headers: _headers(token),
        contentType: 'application/json',
      );
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

  Future<T> patch<T>(
    String path, {
    required dynamic data,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      final headers = _headers(token);

      // Para FormData, Dio debe generar el boundary automáticamente.
      // No fijamos contentType en Options para evitar sobreescribir el
      // header que Dio construye internamente con el boundary correcto.
      final options = data is FormData
          ? Options(headers: headers)
          : Options(headers: headers, contentType: 'application/json');

      final response = await _dio.patch(
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
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }
    return headers;
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
