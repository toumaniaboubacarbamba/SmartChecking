import 'package:dio/dio.dart';
import 'package:smart_checking/entities/visitor.dart';
import 'package:smart_checking/models/errors.dart';
import 'package:smart_checking/models/userModel.dart';
import 'package:smart_checking/models/visitorModel.dart';

class ApiService{
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://ton-api-laravel.com/api',
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
  ));


  // &&-Auth-&&
  Future<Usermodel> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return Usermodel.fromJson(response.data['user']
        ..['token'] = response.data['token']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Email ou mot de passe incorrect');
      }
      throw NetworkException('Erreur réseau : ${e.message}');
    }
  }

  Future<void> logout(String token) async {
    try{
      await _dio.post('/logout',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
      );
          } on DioException catch (e) {
            throw NetworkException('Erreur réseau : ${e.message}');
    }
  }

  // &&--VISITOR--&&

  Future<List<Visitor>> getVisitors(String token) async {
    try {
      final response = await _dio.get('/visitors',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data as List)
          .map((v) => VisitorModel.fromJson(v))
          .toList();
    } on DioException catch (e) {
      throw NetworkException('Erreur réseau : ${e.message}');
    }
  }

  Future<Visitor> createVisitor(String token, VisitorModel visitor) async {
    try {
      final response = await _dio.post('/visitors',
        data: visitor.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return VisitorModel.fromJson(response.data);
    } on DioException catch (e) {
      throw NetworkException('Erreur réseau : ${e.message}');
    }
  }


  Future<void> deleteVisitor(String token, visitorId) async {
    try{
      await _dio.delete('/visitors/$visitorId',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
      );
    } on DioException catch (e) {
      throw NetworkException('Erreur réseau : ${e.message}');
    }
  }


}