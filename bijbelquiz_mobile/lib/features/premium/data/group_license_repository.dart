import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../auth/present/auth_controller.dart';

/// Group licences: one purchase covering a whole church, class or youth club.
///
/// The app only needs the member side of this - redeem a code, see which group
/// you are in. Buying and administering a licence happens on the website,
/// because an App Store purchase cannot be resold to thirty other accounts.

class GroupLicenseMember {
  const GroupLicenseMember({
    required this.id,
    required this.name,
    required this.isOwner,
  });

  final String id;
  final String name;
  final bool isOwner;

  factory GroupLicenseMember.fromJson(Map<String, dynamic> json) {
    return GroupLicenseMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Speler',
      isOwner: json['isOwner'] as bool? ?? false,
    );
  }
}

class GroupLicenseSummary {
  const GroupLicenseSummary({
    required this.id,
    required this.name,
    required this.joinCode,
    required this.seats,
    required this.seatsUsed,
    required this.isOwner,
    required this.expiresAt,
    required this.members,
  });

  final String id;
  final String name;
  final String joinCode;
  final int seats;
  final int seatsUsed;
  final bool isOwner;
  final DateTime? expiresAt;
  final List<GroupLicenseMember> members;

  int get seatsFree => seats - seatsUsed < 0 ? 0 : seats - seatsUsed;

  factory GroupLicenseSummary.fromJson(Map<String, dynamic> json) {
    final rawExpiry = json['expiresAt'];
    final rawMembers = json['members'] as List<dynamic>? ?? const [];

    return GroupLicenseSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Groep',
      joinCode: json['joinCode'] as String? ?? '',
      seats: (json['seats'] as num?)?.toInt() ?? 0,
      seatsUsed: (json['seatsUsed'] as num?)?.toInt() ?? 0,
      isOwner: json['isOwner'] as bool? ?? false,
      expiresAt: rawExpiry is String ? DateTime.tryParse(rawExpiry) : null,
      members: rawMembers
          .whereType<Map>()
          .map((entry) => GroupLicenseMember.fromJson(
                Map<String, dynamic>.from(entry),
              ))
          .toList(),
    );
  }
}

/// Carries the server's own Dutch message (full group, expired, unknown code)
/// straight to the UI.
class GroupLicenseException implements Exception {
  const GroupLicenseException(this.message);
  final String message;

  @override
  String toString() => message;
}

final groupLicenseRepositoryProvider = Provider<GroupLicenseRepository>((ref) {
  return GroupLicenseRepository(ref.watch(apiClientProvider));
});

/// The groups this account owns or belongs to.
final groupLicensesProvider =
    FutureProvider.autoDispose<List<GroupLicenseSummary>>((ref) async {
      return ref.watch(groupLicenseRepositoryProvider).list();
    });

class GroupLicenseRepository {
  GroupLicenseRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<GroupLicenseSummary>> list() async {
    try {
      final response = await _apiClient.dio.get('/group-license');
      final data = response.data;
      final raw = data is Map ? data['licenses'] : null;
      if (raw is! List) return const [];

      return raw
          .whereType<Map>()
          .map((entry) => GroupLicenseSummary.fromJson(
                Map<String, dynamic>.from(entry),
              ))
          .toList();
    } catch (_) {
      // Not being in a group is the common case, and a failed lookup must not
      // block the screen that offers to join one.
      return const [];
    }
  }

  Future<GroupLicenseSummary> join(String joinCode) async {
    try {
      final response = await _apiClient.dio.post(
        '/group-license',
        data: {'joinCode': joinCode.trim().toUpperCase()},
      );

      final data = response.data;
      final license = data is Map ? data['license'] : null;
      if (license is! Map) {
        throw const GroupLicenseException('Deelnemen is niet gelukt.');
      }

      return GroupLicenseSummary.fromJson(Map<String, dynamic>.from(license));
    } on DioException catch (error) {
      throw GroupLicenseException(_serverMessage(error));
    }
  }

  String _serverMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['error'] ?? data['message'];
      final text = message?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }

    return 'Deelnemen is niet gelukt. Controleer je verbinding.';
  }
}
