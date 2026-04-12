import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../auth/present/auth_controller.dart';
import 'profile_model.dart';
import 'package:dio/dio.dart';

final profileRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<ProfileModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/profile');
      
      if (response.statusCode == 200 && response.data != null) {
        // Assume API sends `{ data: { ... } }` or just `{ ... }`
        final data = response.data['data'] ?? response.data;
        return ProfileModel.fromJson(data);
      } else {
        throw Exception('Geen profieldata gevonden');
      }
    } on DioException catch (e) {
      throw Exception('Fout bij ophalen profiel: ${e.message}');
    } catch (_) {
      throw Exception('Onbekende fout bij ophalen profiel');
    }
  }
}
