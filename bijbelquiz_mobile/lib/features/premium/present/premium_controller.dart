import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../profile/data/profile_repository.dart';
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

  Future<void> purchaseMonthly() => _purchase(kRcMonthlyProductId);
  Future<void> purchaseLifetime() => _purchase(kRcLifetimeProductId);

  Future<void> _purchase(String productId) async {
    _log('Purchase requested for product="$productId"');
    final package = productId == kRcMonthlyProductId
        ? _svc.findMonthlyPackage(state.packages)
        : _svc.findLifetimePackage(state.packages);
    state = state.copyWith(status: PurchaseStatus.loading);
    try {
      final info = package != null
          ? await _svc.purchasePackage(package)
          : await _svc.purchaseByProductId(productId);
      state = state.copyWith(
        status: PurchaseStatus.success,
        customerInfo: info,
      );
      _log(
        'Purchase success. Active entitlements: ${info.entitlements.active.keys.join(', ')}',
      );
      await _syncServerPremium();
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        state = state.copyWith(status: PurchaseStatus.idle);
        _log('Purchase cancelled by user.');
        return;
      }
      state = state.copyWith(
        status: PurchaseStatus.error,
        errorMessage: _errorMessage(code),
      );
      _log('Purchase failed: code=$code message="${e.message}"');
    } on StateError catch (e) {
      final availableProducts = state.packages
          .map((p) => p.storeProduct.identifier)
          .toList(growable: false);
      final availablePackages = state.packages
          .map((p) => p.identifier)
          .toList(growable: false);
      state = state.copyWith(
        status: PurchaseStatus.error,
        errorMessage:
            'Product niet gevonden in App Store/RevenueCat. Controleer of je IAP-producten gekoppeld en beschikbaar zijn.',
      );
      _log(
        'Product lookup failed. Requested="$productId", error="$e". '
        'Available package IDs=$availablePackages '
        'Available product IDs=$availableProducts',
      );
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
      await _syncServerPremium();
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        state = state.copyWith(status: PurchaseStatus.idle);
        _log('Restore cancelled by user.');
        return;
      }
      state = state.copyWith(
        status: PurchaseStatus.error,
        errorMessage: _errorMessage(code),
      );
      _log('Restore failed: code=$code message="${e.message}"');
    } catch (e) {
      state = state.copyWith(
        status: PurchaseStatus.error,
        errorMessage: 'Herstel mislukt. Probeer het opnieuw.',
      );
      _log('Restore failed: $e');
    }
  }

  void clearStatus() => state = state.copyWith(status: PurchaseStatus.idle);

  /// Premium content is gated on the server profile, and RevenueCat only fires
  /// a webhook for a NEW transaction — never for an already-owned purchase or a
  /// restore. So we actively ask the server to reconcile against RevenueCat,
  /// then refresh the profile. We retry briefly to ride out store propagation.
  Future<void> _syncServerPremium() async {
    final repo = ref.read(profileRepositoryProvider);
    for (var attempt = 0; attempt < 5; attempt++) {
      final synced = await repo.syncPremium();
      ref.invalidate(profileProvider);
      if (synced == true) return;
      if (synced == null) {
        // Endpoint unreachable/undeployed: fall back to reading the profile in
        // case a webhook already updated it.
        try {
          final profile = await ref.read(profileProvider.future);
          if (profile.isPremium) return;
        } catch (_) {}
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  String _errorMessage(PurchasesErrorCode code) {
    switch (code) {
      case PurchasesErrorCode.networkError:
      case PurchasesErrorCode.offlineConnectionError:
        return 'Geen internetverbinding. Controleer je verbinding en probeer opnieuw.';
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return 'Je hebt dit product al aangeschaft. Gebruik "Aankopen herstellen".';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Aankopen zijn niet toegestaan op dit apparaat. Controleer je App Store-instellingen.';
      case PurchasesErrorCode.paymentPendingError:
        return 'Je betaling wordt nog verwerkt. Premium wordt geactiveerd zodra dit voltooid is.';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'Dit product is momenteel niet beschikbaar in de store. Probeer het later opnieuw.';
      case PurchasesErrorCode.storeProblemError:
        return 'Er is een probleem met de store. Probeer het later opnieuw.';
      case PurchasesErrorCode.insufficientPermissionsError:
        return 'Geen toestemming om aankopen te doen.';
      default:
        return 'Aankoop mislukt. Probeer het opnieuw.';
    }
  }
}
