import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/data/profile_repository.dart';
import '../domain/premium_plan.dart';

/// The server's view of Premium, as the premium controller needs it. A seam
/// for tests; the real one is `POST /api/mobile/sync-premium`.
abstract class PremiumServer {
  /// Ask the server to re-check RevenueCat, then return Premium from every
  /// source. Null when the server cannot be reached.
  Future<ServerPremium?> sync();
}

final premiumServerProvider = Provider<PremiumServer>(
  (ref) => _ProfilePremiumServer(ref.watch(profileRepositoryProvider)),
);

class _ProfilePremiumServer implements PremiumServer {
  _ProfilePremiumServer(this._repository);

  final ProfileRepository _repository;

  @override
  Future<ServerPremium?> sync() => _repository.syncPremiumStatus();
}
