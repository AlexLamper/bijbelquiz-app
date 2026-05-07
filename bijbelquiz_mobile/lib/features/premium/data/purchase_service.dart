import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// ─── RevenueCat product identifiers ──────────────────────────────────────────
// These must match EXACTLY what you configure in RevenueCat dashboard
// → App Store Connect product ID / Google Play product ID.
const kRcMonthlyProductId = 'bijbelquiz_premium_monthly';
const kRcLifetimeProductId = 'bijbelquiz_premium_lifetime';

// RevenueCat entitlement identifier (configured in RC dashboard)
const kRcPremiumEntitlement = 'premium';

// SDK is configured once in main.dart (see RevenueCatConfig).

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService();
});

class PurchaseService {
  void _log(String message) {
    assert(() {
      debugPrint('[RevenueCat][PurchaseService] $message');
      return true;
    }());
  }

  /// Returns the current offering packages from RevenueCat.
  ///
  /// Preferred flow for production:
  /// - Configure products in RevenueCat dashboard
  /// - Attach them to an Offering (usually "default")
  /// - Let app fetch offerings dynamically
  Future<List<Package>> getPackages() async {
    if (kIsWeb) return [];
    _log('Fetching offerings...');
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) {
      _log('No current offering found.');
      return [];
    }

    final packages = <Package>[
      ...current.availablePackages,
    ];
    _log(
      'Current offering="${current.identifier}" with ${packages.length} package(s).',
    );
    for (final pkg in packages) {
      _log(
        'Package="${pkg.identifier}" product="${pkg.storeProduct.identifier}" price="${pkg.storeProduct.priceString}"',
      );
    }

    // Keep a stable package order in UI (monthly first, then lifetime).
    packages.sort((a, b) {
      final aId = a.storeProduct.identifier;
      final bId = b.storeProduct.identifier;
      final aRank = aId == kRcMonthlyProductId
          ? 0
          : aId == kRcLifetimeProductId
              ? 1
              : 99;
      final bRank = bId == kRcMonthlyProductId
          ? 0
          : bId == kRcLifetimeProductId
              ? 1
              : 99;
      return aRank.compareTo(bRank);
    });

    return packages;
  }

  /// Purchase a RevenueCat package from current offering.
  /// Returns the updated CustomerInfo on success.
  Future<CustomerInfo> purchasePackage(Package package) async {
    _log(
      'Purchasing package="${package.identifier}" product="${package.storeProduct.identifier}"',
    );
    return Purchases.purchasePackage(package);
  }

  /// Restore previous purchases (required by App Store guidelines).
  Future<CustomerInfo> restorePurchases() async {
    _log('Restoring purchases...');
    return Purchases.restorePurchases();
  }

  /// Check if the user currently has an active premium entitlement.
  Future<bool> hasPremiumAccess() async {
    if (kIsWeb) return false;
    final info = await Purchases.getCustomerInfo();
    final hasPremium = info.entitlements.active.containsKey(kRcPremiumEntitlement);
    _log('hasPremiumAccess=$hasPremium');
    return hasPremium;
  }

  /// Get full CustomerInfo (subscription status, expiry, etc.)
  Future<CustomerInfo> getCustomerInfo() async {
    final info = await Purchases.getCustomerInfo();
    final activeIds = info.entitlements.active.keys.join(', ');
    _log('CustomerInfo active entitlements: ${activeIds.isEmpty ? '(none)' : activeIds}');
    return info;
  }
}
