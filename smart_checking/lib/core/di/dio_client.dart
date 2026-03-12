import 'package:dio/dio.dart';

class DioClient {
  static const String _baseUrl = 'http://localhost:laravel-smart-checking/api';
  final Dio dio;

  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Accept': 'application/json'},
        ),
      );

  void clearToken() {
    dio.options.headers.remove('Authorization');
  }
}
