import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../domain/premium_plan.dart';

export '../domain/premium_plan.dart';

/// The store, as the premium controller needs it. One implementation talks to
/// RevenueCat ([RevenueCatPurchases]); tests pass a fake.
///
/// Every method that can fail for a store reason throws [PurchaseFailure], so
/// nothing above this layer handles SDK exceptions.
abstract class PurchasesGateway {
  /// The plans in the current offering, in paywall order (yearly, monthly,
  /// lifetime), with the store's prices and only the trials this buyer can
  /// still get.
  Future<List<PlanOffer>> loadOffers();

  Future<StoreCustomer> customer();

  Future<StoreCustomer> purchase(PlanOffer offer);

  /// Fallback when the offering did not load: buy the product by id.
  Future<StoreCustomer> purchasePlan(PremiumPlan plan);

  /// Restore purchases made with this App Store / Google account.
  Future<StoreCustomer> restore();

  /// Attach RevenueCat to the account (`appUserID` = server user id).
  Future<StoreCustomer> logIn(String userId);

  /// Back to an anonymous RevenueCat id.
  Future<StoreCustomer> logOut();

  /// Calls [onChange] whenever RevenueCat has new customer info (renewal,
  /// expiry, an Ask to Buy approval, a purchase on another device). Returns
  /// the unsubscribe function.
  VoidCallback listen(void Function(StoreCustomer customer) onChange);
}

final purchasesGatewayProvider = Provider<PurchasesGateway>(
  (ref) => RevenueCatPurchases(),
);

/// Back-compat name for the gateway provider.
final purchaseServiceProvider = purchasesGatewayProvider;

// ---------------------------------------------------------------------------
// Pure mapping, shared by the RevenueCat gateway and the tests
// ---------------------------------------------------------------------------

/// The free trial on a store product, or null when there is none.
///
/// Read from the store rather than hardcoded: the trial is configured in App
/// Store Connect / Play Console, and a paywall that promises one the store
/// will not honour is a rejected review at best. A discounted intro price is
/// not a free trial and is never sold as one.
TrialOffer? trialOfferFor(StoreProduct product) {
  final intro = product.introductoryPrice;
  if (intro == null || intro.price > 0) return null;
  return TrialOffer(
    periodUnit: intro.periodUnit,
    periodCount: intro.periodNumberOfUnits,
  );
}

/// Turn an offering's packages into the paywall's plans.
///
/// [eligibility] is RevenueCat's trial eligibility per product id (iOS only;
/// Android leaves ineligible offers out of the product already). A buyer who
/// had the trial before is not promised it again.
List<PlanOffer> offersFromPackages(
  List<Package> packages, {
  Map<String, IntroEligibilityStatus> eligibility = const {},
}) {
  final byPlan = <PremiumPlan, PlanOffer>{};
  for (final pkg in packages) {
    final product = pkg.storeProduct;
    final plan = planForPackage(
      packageType: pkg.packageType,
      packageId: pkg.identifier,
      productId: product.identifier,
    );
    if (plan == null || byPlan.containsKey(plan)) continue;

    final status = eligibility[product.identifier];
    final ineligible =
        status == IntroEligibilityStatus.introEligibilityStatusIneligible ||
        status ==
            IntroEligibilityStatus.introEligibilityStatusNoIntroOfferExists;

    byPlan[plan] = PlanOffer(
      plan: plan,
      productId: product.identifier,
      priceString: product.priceString,
      trial: plan.isSubscription && !ineligible ? trialOfferFor(product) : null,
      handle: pkg,
    );
  }

  return [
    for (final plan in PremiumPlan.values)
      if (byPlan[plan] != null) byPlan[plan]!,
  ];
}

/// The Premium entitlement out of RevenueCat's customer info.
StoreCustomer storeCustomerFrom(CustomerInfo info) {
  final entitlement = info.entitlements.active[kRcPremiumEntitlement];
  if (entitlement == null || !entitlement.isActive) {
    return StoreCustomer(managementUrl: info.managementURL);
  }
  return StoreCustomer(
    premiumActive: true,
    isTrial: entitlement.periodType == PeriodType.trial,
    willRenew: entitlement.willRenew,
    expiresAt: entitlement.expirationDate == null
        ? null
        : DateTime.tryParse(entitlement.expirationDate!),
    productId: entitlement.productIdentifier,
    managementUrl: info.managementURL,
    isSandbox: entitlement.isSandbox,
  );
}

/// SDK error -> [PurchaseFailure].
PurchaseFailure purchaseFailureFrom(PlatformException error) {
  final code = PurchasesErrorHelper.getErrorCode(error);
  final kind = switch (code) {
    PurchasesErrorCode.purchaseCancelledError => PurchaseFailureKind.cancelled,
    PurchasesErrorCode.paymentPendingError => PurchaseFailureKind.pending,
    PurchasesErrorCode.productAlreadyPurchasedError =>
      PurchaseFailureKind.alreadyOwned,
    PurchasesErrorCode.receiptAlreadyInUseError =>
      PurchaseFailureKind.ownedByOtherAccount,
    PurchasesErrorCode.networkError ||
    PurchasesErrorCode.offlineConnectionError => PurchaseFailureKind.network,
    PurchasesErrorCode.purchaseNotAllowedError ||
    PurchasesErrorCode.insufficientPermissionsError =>
      PurchaseFailureKind.notAllowed,
    PurchasesErrorCode.productNotAvailableForPurchaseError ||
    PurchasesErrorCode.configurationError => PurchaseFailureKind.notAvailable,
    PurchasesErrorCode.storeProblemError => PurchaseFailureKind.store,
    _ => PurchaseFailureKind.unknown,
  };
  return PurchaseFailure(kind, '${code.name}: ${error.message}');
}

// ---------------------------------------------------------------------------
// RevenueCat
// ---------------------------------------------------------------------------

/// The real gateway. The SDK is configured once in `main.dart`
/// (see `RevenueCatConfig`); without a key every call fails with
/// [PurchaseFailureKind.notConfigured] instead of crashing.
class RevenueCatPurchases implements PurchasesGateway {
  void _log(String message) {
    assert(() {
      debugPrint('[RevenueCat] $message');
      return true;
    }());
  }

  Future<T> _guard<T>(Future<T> Function() body) async {
    if (kIsWeb) {
      throw const PurchaseFailure(PurchaseFailureKind.notConfigured, 'web');
    }
    bool configured;
    try {
      configured = await Purchases.isConfigured;
    } catch (error) {
      throw PurchaseFailure(PurchaseFailureKind.notConfigured, '$error');
    }
    if (!configured) {
      throw const PurchaseFailure(PurchaseFailureKind.notConfigured);
    }
    try {
      return await body();
    } on PlatformException catch (error) {
      final failure = purchaseFailureFrom(error);
      _log('failed: $failure');
      throw failure;
    }
  }

  @override
  Future<List<PlanOffer>> loadOffers() => _guard(() async {
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) {
      _log('No current offering. Mark one as current in RevenueCat.');
      return const <PlanOffer>[];
    }

    final packages = current.availablePackages;
    Map<String, IntroEligibilityStatus> eligibility = const {};
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      try {
        final result = await Purchases.checkTrialOrIntroductoryPriceEligibility(
          [for (final pkg in packages) pkg.storeProduct.identifier],
        );
        eligibility = {
          for (final entry in result.entries) entry.key: entry.value.status,
        };
      } catch (error) {
        // Unknown eligibility: show what the store product says.
        _log('Trial eligibility unavailable: $error');
      }
    }

    final offers = offersFromPackages(packages, eligibility: eligibility);
    _log(
      'Offering "${current.identifier}": '
      '${offers.map((o) => '${o.plan.name}=${o.productId} ${o.priceString}${o.trial == null ? '' : ' (${o.trial!.label})'}').join(', ')}',
    );
    return offers;
  });

  @override
  Future<StoreCustomer> customer() =>
      _guard(() async => storeCustomerFrom(await Purchases.getCustomerInfo()));

  @override
  Future<StoreCustomer> purchase(PlanOffer offer) => _guard(() async {
    final pkg = offer.handle;
    if (pkg is! Package) return purchasePlan(offer.plan);
    _log('Purchasing ${pkg.identifier} (${pkg.storeProduct.identifier})');
    return storeCustomerFrom(await Purchases.purchasePackage(pkg));
  });

  @override
  Future<StoreCustomer> purchasePlan(PremiumPlan plan) => _guard(() async {
    _log('Fallback purchase by product id ${plan.productId}');
    // On Google Play the lifetime product is a one-time product, which
    // getProducts only finds when asked for non-subscriptions.
    final products = await Purchases.getProducts(
      [plan.productId],
      productCategory: plan.isSubscription
          ? ProductCategory.subscription
          : ProductCategory.nonSubscription,
    );
    if (products.isEmpty) {
      throw PurchaseFailure(
        PurchaseFailureKind.notAvailable,
        'product ${plan.productId} not found',
      );
    }
    return storeCustomerFrom(
      await Purchases.purchaseStoreProduct(products.first),
    );
  });

  @override
  Future<StoreCustomer> restore() => _guard(() async {
    _log('Restoring purchases');
    return storeCustomerFrom(await Purchases.restorePurchases());
  });

  @override
  Future<StoreCustomer> logIn(String userId) => _guard(() async {
    final result = await Purchases.logIn(userId);
    _log('logIn($userId) created=${result.created}');
    return storeCustomerFrom(result.customerInfo);
  });

  @override
  Future<StoreCustomer> logOut() => _guard(() async {
    // logOut throws when the current user is already anonymous.
    if (await Purchases.isAnonymous) {
      return storeCustomerFrom(await Purchases.getCustomerInfo());
    }
    return storeCustomerFrom(await Purchases.logOut());
  });

  @override
  VoidCallback listen(void Function(StoreCustomer customer) onChange) {
    if (kIsWeb) return () {};
    void listener(CustomerInfo info) => onChange(storeCustomerFrom(info));
    try {
      Purchases.addCustomerInfoUpdateListener(listener);
    } catch (error) {
      _log('No customer info listener: $error');
      return () {};
    }
    return () {
      try {
        Purchases.removeCustomerInfoUpdateListener(listener);
      } catch (_) {}
    };
  }
}
