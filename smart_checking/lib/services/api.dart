import 'dart:io';

import 'package:dio/dio.dart';
import 'package:smart_checking/entities/visitor.dart';
import 'package:smart_checking/models/errors.dart';
import 'package:smart_checking/models/userModel.dart';
import 'package:smart_checking/models/visitorModel.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    // Remplacer par votre vraie URL Laravel en production
    // En local Android émulateur : http://10.0.2.2:8000/api
    // En local iOS simulateur   : http://127.0.0.1:8000/api
    // En production              : https://votre-domaine.com/api
    baseUrl: 'http://10.0.2.2:8000/api',
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
  ));

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<Usermodel> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return Usermodel.fromJson(
        response.data['user']..['token'] = response.data['token'],
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Email ou mot de passe incorrect');
      }
      throw NetworkException('Erreur réseau : ${e.message}');
    }
  }

  Future<void> logout(String token) async {
    try {
      await _dio.post(
        '/logout',
        options: Options(headers: _authHeader(token)),
      );
    } on DioException catch (e) {
      throw NetworkException('Erreur réseau : ${e.message}');
    }
  }

  // ── Visitors ──────────────────────────────────────────────────────────────

  Future<List<Visitor>> getVisitors(String token) async {
    try {
      final response = await _dio.get(
        '/visitors',
        options: Options(headers: _authHeader(token)),
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
      final response = await _dio.post(
        '/visitors',
        data: visitor.toJson(),
        options: Options(headers: _authHeader(token)),
      );
      return VisitorModel.fromJson(response.data);
    } on DioException catch (e) {
      throw NetworkException('Erreur réseau : ${e.message}');
    }
  }

  Future<void> deleteVisitor(String token, visitorId) async {
    try {
      await _dio.delete(
        '/visitors/$visitorId',
        options: Options(headers: _authHeader(token)),
      );
    } on DioException catch (e) {
      throw NetworkException('Erreur réseau : ${e.message}');
    }
  }

  // ── Export ────────────────────────────────────────────────────────────────

  /// Télécharge le CSV et retourne le chemin du fichier sauvegardé
  Future<String> exportCsv(String token, List<String> ids) async {
    try {
      final savePath = '/storage/emulated/0/Download/'
          'visiteurs_${DateTime.now().millisecondsSinceEpoch}.csv';

      await _dio.post(
        '/visitors/export/csv',
        data: {'ids': ids.map(int.parse).toList()},
        options: Options(
          headers: _authHeader(token),
          responseType: ResponseType.bytes,
        ),
        onReceiveProgress: (received, total) {},
      ).then((response) async {
        // Écrire les bytes dans le fichier
        final file = await _writeBytes(savePath, response.data);
        return file;
      });

      return savePath;
    } on DioException catch (e) {
      throw NetworkException('Erreur export CSV : ${e.message}');
    }
  }

  /// Télécharge le PDF et retourne le chemin du fichier sauvegardé
  Future<String> exportPdf(String token, List<String> ids) async {
    try {
      final savePath = '/storage/emulated/0/Download/'
          'visiteurs_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await _dio.post(
        '/visitors/export/pdf',
        data: {'ids': ids.map(int.parse).toList()},
        options: Options(
          headers: _authHeader(token),
          responseType: ResponseType.bytes,
        ),
      ).then((response) async {
        await _writeBytes(savePath, response.data);
      });

      return savePath;
    } on DioException catch (e) {
      throw NetworkException('Erreur export PDF : ${e.message}');
    }
  }

  // ── Helper : header Authorization ─────────────────────────────────────────

  Map<String, String> _authHeader(String token) {
    return {'Authorization': 'Bearer $token'};
  }

  // ── Helper : écrire un fichier en bytes ────────────────────────────────────

  Future<String> _writeBytes(String path, List<int> bytes) async {
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    return path;
  }
}