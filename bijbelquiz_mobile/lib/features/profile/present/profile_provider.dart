import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/present/auth_controller.dart';
import '../data/profile_model.dart';
import '../data/profile_repository.dart';

/// Thrown instead of fetching when nobody is signed in.
///
/// Every screen that reads the profile already falls back to its signed-out
/// rendering through `maybeWhen`/`asData`, so failing here - before the
/// network - keeps that behaviour without a round trip that can only be a 401.
class NoSessionException implements Exception {
  const NoSessionException();

  @override
  String toString() => 'Niet ingelogd';
}

final profileProvider = FutureProvider.autoDispose<ProfileModel>((ref) async {
  final hasSession = await ref.watch(hasSessionProvider.future);
  if (!hasSession) {
    throw const NoSessionException();
  }

  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfile();
});
