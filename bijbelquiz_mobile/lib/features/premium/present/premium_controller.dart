import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../profile/present/profile_provider.dart';
import '../data/purchase_service.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum PurchaseStatus { idle, loading, success, error }

class PremiumState {
  const PremiumState({
    this.status = PurchaseStatus.idle,
    this.packages = const [],
    this.customerInfo,
    this.errorMessage,
  });

  final PurchaseStatus status;
  final List<Package> packages;
  final CustomerInfo? customerInfo;
  final String? errorMessage;

  bool get isPremium =>
      customerInfo?.entitlements.active.containsKey(kRcPremiumEntitlement) ??
      false;

  PremiumState copyWith({
    PurchaseStatus? status,
    List<Package>? packages,
    CustomerInfo? customerInfo,
    String? errorMessage,
  }) {
    return PremiumState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      customerInfo: customerInfo ?? this.customerInfo,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─── Provider (Riverpod 3.x Notifier API) ────────────────────────────────────

final premiumControllerProvider =
    NotifierProvider<PremiumController, PremiumState>(PremiumController.new);

// ─── Controller ───────────────────────────────────────────────────────────────

class PremiumController extends Notifier<PremiumState> {
  void _log(String message) {
    assert(() {
      // ignore: avoid_print
      print('[RevenueCat][PremiumController] $message');
      return true;
    }());
  }

  @override
  PremiumState build() {
    _loadProducts();
    return const PremiumState();
  }

  PurchaseService get _svc => ref.read(purchaseServiceProvider);

  Future<void> _loadProducts() async {
    try {
      _log('Loading packages and customer info...');
      final packages = await _svc.getPackages();
      final info = await _svc.getCustomerInfo();
      state = state.copyWith(packages: packages, customerInfo: info);
      _log(
        'Loaded ${packages.length} package(s); isPremium=${info.entitlements.active.containsKey(kRcPremiumEntitlement)}',
      );
    } catch (_) {
      // Graceful degradation on web/simulator.
      _log('Failed to load packages/customer info.');
    }
  }

  Package? _findPackage(String productId) {
    try {
      return state.packages.firstWhere(
        (p) => p.storeProduct.identifier == productId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> purchaseMonthly() => _purchase(kRcMonthlyProductId);
  Future<void> purchaseLifetime() => _purchase(kRcLifetimeProductId);

  Future<void> _purchase(String productId) async {
    _log('Purchase requested for product="$productId"');
    final package = _findPackage(productId);
    if (package == null) {
      state = state.copyWith(
        status: PurchaseStatus.error,
        errorMessage: 'Product niet gevonden. Probeer opnieuw.',
      );
      _log('Product not found in current offering.');
      return;
    }

    state = state.copyWith(status: PurchaseStatus.loading);
    try {
      final info = await _svc.purchasePackage(package);
      state = state.copyWith(
        status: PurchaseStatus.success,
        customerInfo: info,
      );
      _log(
        'Purchase success. Active entitlements: ${info.entitlements.active.keys.join(', ')}',
      );
      ref.invalidate(profileProvider);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        state = state.copyWith(status: PurchaseStatus.idle);
        _log('Purchase cancelled by user.');
        return;
      }
      state = state.copyWith(
        status: PurchaseStatus.error,
        errorMessage: _errorMessage(e),
      );
      _log('Purchase failed with PurchasesErrorCode=$e');
    } catch (e) {
      state = state.copyWith(
        status: PurchaseStatus.error,
        errorMessage: 'Aankoop mislukt: $e',
      );
      _log('Purchase failed with error: $e');
    }
  }

  Future<void> restorePurchases() async {
    _log('Restore purchases requested.');
    state = state.copyWith(status: PurchaseStatus.loading);
    try {
      final info = await _svc.restorePurchases();
      state = state.copyWith(
        status: PurchaseStatus.success,
        customerInfo: info,
      );
      _log(
        'Restore success. Active entitlements: ${info.entitlements.active.keys.join(', ')}',
      );
      ref.invalidate(profileProvider);
    } catch (e) {
      state = state.copyWith(
        status: PurchaseStatus.error,
        errorMessage: 'Herstel mislukt: $e',
      );
      _log('Restore failed: $e');
    }
  }

  void clearStatus() => state = state.copyWith(status: PurchaseStatus.idle);

  String _errorMessage(PurchasesErrorCode code) {
    switch (code) {
      case PurchasesErrorCode.networkError:
        return 'Geen internetverbinding. Controleer je verbinding.';
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return 'Je hebt dit product al aangeschaft.';
      case PurchasesErrorCode.insufficientPermissionsError:
        return 'Geen toestemming om aankopen te doen.';
      default:
        return 'Aankoop mislukt (code: ${code.index}). Probeer opnieuw.';
    }
  }
}
