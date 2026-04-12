import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_model.dart';
import '../data/profile_repository.dart';

final profileProvider = FutureProvider.autoDispose<ProfileModel>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfile();
});
