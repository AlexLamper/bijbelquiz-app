import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../domain/user.dart';
import 'auth_local_storage.dart';
import '../../../core/api/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final AuthLocalStorage _localStorage;

  AuthRepository(this._apiClient, this._localStorage);

  Future<User?> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      return _processAuthResponse(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response!.data['error'] ?? 'Invalid credentials');
      }
      throw Exception('Failed to login: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<User?> register(String name, String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return _processAuthResponse(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response!.data['error'] ?? 'Registration failed');
      }
      throw Exception('Failed to register: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<User?> loginWithGoogle(String idToken) async {
    try {
      final response = await _apiClient.dio.post(
        '/google-login',
        data: {'idToken': idToken},
      );
      return _processAuthResponse(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        throw Exception(e.response!.data['error'] ?? 'Google login failed');
      }
      throw Exception('Failed to login with Google: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected Google login error: $e');
    }
  }

  Future<void> logout() async {
    await _localStorage.deleteToken();
  }

  Future<User?> _processAuthResponse(Map<String, dynamic> data) async {
    try {
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await _localStorage.saveToken(token);
      }

      final userData = data['user'];
      if (userData != null && userData is Map<String, dynamic>) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      throw Exception('JSON Parsing Error: $e');
    }
  }
}
