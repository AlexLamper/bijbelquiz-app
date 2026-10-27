import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/present/auth_controller.dart' show hasSessionProvider;
import '../../profile/present/profile_provider.dart';
import '../data/premium_server.dart';
import '../data/purchase_service.dart';
import '../data/trial_reminder.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum PurchaseStatus {
  idle,
  loading,

  /// The purchase or restore went through and Premium is on.
  success,

  /// Ask to Buy / a pending payment: the store finishes it later.
  pending,

  /// Signed out: Premium belongs to an account, so sign in first.
  needsAccount,

  /// The account already has Premium (store, website, group, lifetime).
  alreadyPremium,

  /// Restore found nothing on this App Store / Google account.
  nothingToRestore,
  error,
}

enum PremiumAction { purchase, restore }

enum OffersStatus { loading, ready, unavailable }

class PremiumState {
  const PremiumState({
    this.status = PurchaseStatus.idle,
    this.action,
    this.offers = const [],
    this.offersStatus = OffersStatus.loading,
    this.customer = StoreCustomer.none,
    this.serverPremium,
    this.message,
  });

  final PurchaseStatus status;

  /// What [status] is the outcome of.
  final PremiumAction? action;
  final List<PlanOffer> offers;
  final OffersStatus offersStatus;

  /// RevenueCat's view of this customer.
  final StoreCustomer customer;

  /// The server's view (all sources), once asked. Null: not known yet.
  final ServerPremium? serverPremium;

  /// Dutch text for [status] (errors, pending, nothing to restore).
  final String? message;

  /// Premium from the store or from any source the server knows.
  bool get isPremium =>
      customer.premiumActive || (serverPremium?.isPremium ?? false);

  bool get isBusy => status == PurchaseStatus.loading;

  PlanOffer? offerFor(PremiumPlan plan) {
    for (final offer in offers) {
      if (offer.plan == plan) return offer;
    }
    return null;
  }

  PremiumState copyWith({
    PurchaseStatus? status,
    PremiumAction? action,
    List<PlanOffer>? offers,
    OffersStatus? offersStatus,
    StoreCustomer? customer,
    ServerPremium? serverPremium,
    bool clearServerPremium = false,
    String? message,
  }) {
    final nextStatus = status ?? this.status;
    return PremiumState(
      status: nextStatus,
      action: action ?? this.action,
      offers: offers ?? this.offers,
      offersStatus: offersStatus ?? this.offersStatus,
      customer: customer ?? this.customer,
      serverPremium: clearServerPremium
          ? null
          : serverPremium ?? this.serverPremium,
      // A message belongs to the status it was set with.
      message: status == null ? (message ?? this.message) : message,
    );
  }
}

// ─── Provider (Riverpod 3.x Notifier API) ────────────────────────────────────

final premiumControllerProvider =
    NotifierProvider<PremiumController, PremiumState>(PremiumController.new);

/// Whether the signed-in player already has Premium, by the server profile or
/// by RevenueCat - whichever has loaded and says yes. Used to keep the paywall
/// away from people who have nothing left to buy.
bool hasPremiumAccess(WidgetRef ref) =>
    (ref.read(profileProvider).asData?.value.isPremium ?? false) ||
    ref.read(premiumControllerProvider).isPremium;

// ─── Controller ───────────────────────────────────────────────────────────────

/// Purchases, restores and the Premium state the app shows.
///
/// Premium belongs to the account, so the server decides in the end: after a
/// purchase or restore the controller asks the server to re-read RevenueCat
/// (`/api/mobile/sync-premium`) and refreshes the profile, so Premium shows at
/// once on every screen and on the website. Before selling anything it asks
/// the server whether the account already has Premium - from the website, a
/// group licence or a lifetime purchase - so nobody pays twice.
class PremiumController extends Notifier<PremiumState> {
  /// Pause between server checks while a fresh purchase propagates. Tests set
  /// it to zero.
  static Duration retryDelay = const Duration(seconds: 2);
  static const int _confirmAttempts = 5;

  void _log(String message) {
    assert(() {
      debugPrint('[RevenueCat][PremiumController] $message');
      return true;
    }());
  }

  PurchasesGateway get _store => ref.read(purchasesGatewayProvider);
  PremiumServer get _server => ref.read(premiumServerProvider);

  bool _disposed = false;

  @override
  PremiumState build() {
    _disposed = false;
    final unsubscribe = _store.listen(_onStoreUpdate);

    // Entitlements change while the app is in the background: a renewal, an
    // expiry, an Ask to Buy approval, a purchase on another device.
    AppLifecycleListener? lifecycle;
    try {
      lifecycle = AppLifecycleListener(onResume: () => unawaited(refresh()));
    } catch (_) {
      // No binding (pure Dart tests).
    }

    ref.onDispose(() {
      _disposed = true;
      unsubscribe();
      lifecycle?.dispose();
    });

    Future.microtask(_load);
    return const PremiumState();
  }

  void _set(PremiumState next) {
    if (_disposed) return;
    state = next;
  }

  Future<void> _load() async {
    await Future.wait([loadOffers(), _loadCustomer()]);
  }

  /// (Re)load the plans and prices from the store.
  Future<void> loadOffers() async {
    _set(state.copyWith(offersStatus: OffersStatus.loading));
    try {
      final offers = await _store.loadOffers();
      _set(
        state.copyWith(
          offers: offers,
          offersStatus: offers.isEmpty
              ? OffersStatus.unavailable
              : OffersStatus.ready,
        ),
      );
    } catch (error) {
      _log('Offers failed: $error');
      _set(state.copyWith(offersStatus: OffersStatus.unavailable));
    }
  }

  Future<void> _loadCustomer() async {
    try {
      _applyCustomer(await _store.customer());
    } catch (error) {
      _log('Customer info failed: $error');
    }
  }

  void _onStoreUpdate(StoreCustomer customer) {
    final wasActive = state.customer.premiumActive;
    _applyCustomer(customer);
    // The store turned Premium on outside a purchase flow (Ask to Buy
    // approved, a pending payment cleared): tell the server.
    if (customer.premiumActive && !wasActive && !state.isBusy) {
      unawaited(_confirmWithServer(storeActive: true));
    }
  }

  void _applyCustomer(StoreCustomer customer, {bool afterPurchase = false}) {
    _set(state.copyWith(customer: customer));
    unawaited(
      ref
          .read(trialReminderProvider)
          .sync(customer, requestPermission: afterPurchase),
    );
  }

  /// On app start and resume: re-read the store and the server.
  Future<void> refresh() async {
    await _loadCustomer();
    if (await _hasSession()) {
      await _askServer();
    }
  }

  Future<bool> _hasSession() async {
    try {
      return await ref.read(hasSessionProvider.future);
    } catch (_) {
      return false;
    }
  }

  Future<ServerPremium?> _askServer() async {
    final result = await _server.sync();
    if (result != null) {
      _set(state.copyWith(serverPremium: result));
    }
    try {
      ref.invalidate(profileProvider);
    } catch (_) {}
    return result;
  }

  /// Tell the server about a store change and wait (briefly) until it shows.
  ///
  /// Only retries while the store says Premium and the server does not yet:
  /// that gap is store propagation and closes within seconds. With nothing
  /// in the store, one answer is the answer.
  Future<bool> _confirmWithServer({required bool storeActive}) async {
    for (var attempt = 0; attempt < _confirmAttempts; attempt++) {
      final result = await _askServer();
      if (result?.isPremium == true) return true;
      if (!storeActive) return false;
      if (attempt < _confirmAttempts - 1) await Future.delayed(retryDelay);
    }
    return false;
  }

  Future<void> purchaseMonthly() => purchase(PremiumPlan.monthly);
  Future<void> purchaseYearly() => purchase(PremiumPlan.yearly);
  Future<void> purchaseLifetime() => purchase(PremiumPlan.lifetime);

  /// Set synchronously, so a second tap before the first `await` cannot
  /// start a second purchase.
  bool _inFlight = false;

  Future<void> purchase(PremiumPlan plan) async {
    if (_inFlight || state.isBusy) return;
    _inFlight = true;
    try {
      await _purchase(plan);
    } finally {
      _inFlight = false;
    }
  }

  Future<void> _purchase(PremiumPlan plan) async {
    _log('Purchase requested: ${plan.name}');

    // A purchase has to land on an account: RevenueCat is logged in with the
    // user id at sign-in, and the server grants Premium to that id. Bought
    // signed out, it would hang off an anonymous RevenueCat id.
    if (!await _hasSession()) {
      _set(
        state.copyWith(
          status: PurchaseStatus.needsAccount,
          action: PremiumAction.purchase,
        ),
      );
      return;
    }

    _set(
      state.copyWith(
        status: PurchaseStatus.loading,
        action: PremiumAction.purchase,
      ),
    );

    // Never sell Premium to an account that already has it, wherever from.
    final server = await _askServer();
    if (server?.isPremium == true || state.customer.premiumActive) {
      _set(
        state.copyWith(
          status: PurchaseStatus.alreadyPremium,
          action: PremiumAction.purchase,
        ),
      );
      if (state.customer.premiumActive && server?.isPremium != true) {
        unawaited(_confirmWithServer(storeActive: true));
      }
      return;
    }

    try {
      final offer = state.offerFor(plan);
      final customer = offer != null
          ? await _store.purchase(offer)
          : await _store.purchasePlan(plan);
      _applyCustomer(customer, afterPurchase: true);

      final confirmed = await _confirmWithServer(
        storeActive: customer.premiumActive,
      );
      if (customer.premiumActive || confirmed) {
        _set(
          state.copyWith(
            status: PurchaseStatus.success,
            action: PremiumAction.purchase,
          ),
        );
      } else {
        // Paid, but the entitlement is not on: a product not attached to
        // the entitlement in RevenueCat, or the store is slow.
        _set(
          state.copyWith(
            status: PurchaseStatus.error,
            action: PremiumAction.purchase,
            message:
                'Je aankoop is ontvangen, maar Premium staat nog niet aan. '
                'Tik over een minuut op "Herstellen".',
          ),
        );
      }
    } on PurchaseFailure catch (failure) {
      _log('Purchase failed: $failure');
      _onFailure(failure, PremiumAction.purchase);
    } catch (error) {
      _log('Purchase failed: $error');
      _onFailure(
        const PurchaseFailure(PurchaseFailureKind.unknown),
        PremiumAction.purchase,
      );
    }
  }

  /// "Aankopen herstellen": required by Apple, on the paywall and in
  /// Instellingen.
  Future<void> restorePurchases() async {
    if (_inFlight || state.isBusy) return;
    _inFlight = true;
    try {
      await _restore();
    } finally {
      _inFlight = false;
    }
  }

  Future<void> _restore() async {
    _log('Restore requested');

    if (!await _hasSession()) {
      _set(
        state.copyWith(
          status: PurchaseStatus.needsAccount,
          action: PremiumAction.restore,
        ),
      );
      return;
    }

    _set(
      state.copyWith(
        status: PurchaseStatus.loading,
        action: PremiumAction.restore,
      ),
    );

    try {
      final customer = await _store.restore();
      _applyCustomer(customer);
      final confirmed = await _confirmWithServer(
        storeActive: customer.premiumActive,
      );
      if (customer.premiumActive || confirmed) {
        _set(
          state.copyWith(
            status: PurchaseStatus.success,
            action: PremiumAction.restore,
          ),
        );
      } else {
        _set(
          state.copyWith(
            status: PurchaseStatus.nothingToRestore,
            action: PremiumAction.restore,
            message:
                'We vonden geen Premium-aankoop op dit '
                '${_storeName()}-account.',
          ),
        );
      }
    } on PurchaseFailure catch (failure) {
      _log('Restore failed: $failure');
      _onFailure(failure, PremiumAction.restore);
    } catch (error) {
      _log('Restore failed: $error');
      _onFailure(
        const PurchaseFailure(PurchaseFailureKind.unknown),
        PremiumAction.restore,
      );
    }
  }

  void _onFailure(PurchaseFailure failure, PremiumAction action) {
    switch (failure.kind) {
      case PurchaseFailureKind.cancelled:
        _set(state.copyWith(status: PurchaseStatus.idle, action: action));
      case PurchaseFailureKind.pending:
        _set(
          state.copyWith(
            status: PurchaseStatus.pending,
            action: action,
            message:
                'Je aankoop wacht nog op goedkeuring of betaling. Premium '
                'gaat vanzelf aan zodra de ${_storeName()} die afrondt.',
          ),
        );
      default:
        _set(
          state.copyWith(
            status: PurchaseStatus.error,
            action: action,
            message: purchaseErrorMessage(failure.kind, action),
          ),
        );
    }
  }

  /// Signed in: attach RevenueCat to the account (aliasing any anonymous
  /// purchases into it), then reconcile with the server.
  Future<void> onSignedIn(String userId) async {
    _set(state.copyWith(clearServerPremium: true));
    try {
      _applyCustomer(await _store.logIn(userId));
    } catch (error) {
      _log('logIn failed: $error');
    }
    // Not awaited: signing in must not wait for store propagation.
    unawaited(_confirmWithServer(storeActive: state.customer.premiumActive));
  }

  /// Signed out: back to an anonymous RevenueCat id, and forget the previous
  /// account's Premium.
  Future<void> onSignedOut() async {
    StoreCustomer customer = StoreCustomer.none;
    try {
      customer = await _store.logOut();
    } catch (error) {
      _log('logOut failed: $error');
    }
    _set(
      PremiumState(
        offers: state.offers,
        offersStatus: state.offersStatus,
        customer: customer,
      ),
    );
    unawaited(ref.read(trialReminderProvider).sync(customer));
  }

  void clearStatus() => _set(state.copyWith(status: PurchaseStatus.idle));
}

String _storeName() {
  final apple =
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
  return apple ? 'App Store' : 'Google Play';
}

/// Dutch message for a failed purchase or restore.
String purchaseErrorMessage(PurchaseFailureKind kind, PremiumAction action) {
  final store = _storeName();
  switch (kind) {
    case PurchaseFailureKind.network:
      return 'Geen internetverbinding. Controleer je verbinding en probeer '
          'het opnieuw.';
    case PurchaseFailureKind.alreadyOwned:
      return 'Je hebt dit al gekocht. Tik op "Herstellen" om het terug te '
          'zetten.';
    case PurchaseFailureKind.ownedByOtherAccount:
      return 'Deze aankoop hoort al bij een ander BijbelQuiz-account. Log in '
          'met dat account om je Premium te gebruiken.';
    case PurchaseFailureKind.notAllowed:
      return 'Aankopen zijn niet toegestaan op dit apparaat. Controleer de '
          'instellingen van je $store-account.';
    case PurchaseFailureKind.notAvailable:
      return 'Dit abonnement is nu niet beschikbaar in de $store. Probeer '
          'het later opnieuw.';
    case PurchaseFailureKind.store:
      return 'De $store geeft een fout. Probeer het later opnieuw.';
    case PurchaseFailureKind.notConfigured:
      return 'Aankopen zijn in deze versie van de app niet beschikbaar.';
    case PurchaseFailureKind.cancelled:
    case PurchaseFailureKind.pending:
    case PurchaseFailureKind.unknown:
      return action == PremiumAction.restore
          ? 'Herstellen is niet gelukt. Probeer het opnieuw.'
          : 'De aankoop is niet afgerond. Er is niets in rekening gebracht.';
  }
}
