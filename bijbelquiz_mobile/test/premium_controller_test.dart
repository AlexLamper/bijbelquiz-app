import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:bijbelquiz_mobile/features/auth/present/auth_controller.dart';
import 'package:bijbelquiz_mobile/features/premium/data/premium_server.dart';
import 'package:bijbelquiz_mobile/features/premium/data/purchase_service.dart';
import 'package:bijbelquiz_mobile/features/premium/data/trial_reminder.dart';
import 'package:bijbelquiz_mobile/features/premium/present/premium_controller.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

const _trialCustomer = StoreCustomer(
  premiumActive: true,
  isTrial: true,
  willRenew: true,
  productId: kRcYearlyProductId,
);

PlanOffer _offer(PremiumPlan plan, String price, {TrialOffer? trial}) =>
    PlanOffer(
      plan: plan,
      productId: plan.productId,
      priceString: price,
      trial: trial,
    );

final _offers = [
  _offer(
    PremiumPlan.yearly,
    '€39,99',
    trial: const TrialOffer(periodUnit: PeriodUnit.day, periodCount: 7),
  ),
  _offer(PremiumPlan.monthly, '€5,99'),
  _offer(PremiumPlan.lifetime, '€74,99'),
];

class FakeGateway implements PurchasesGateway {
  List<PlanOffer> offers = _offers;
  Object? offersError;
  StoreCustomer current = StoreCustomer.none;

  /// What a purchase returns, or throws.
  StoreCustomer purchaseResult = _trialCustomer;
  PurchaseFailure? purchaseFailure;
  StoreCustomer restoreResult = StoreCustomer.none;
  PurchaseFailure? restoreFailure;

  final purchased = <PremiumPlan>[];
  final purchasedByProductId = <PremiumPlan>[];
  final loggedIn = <String>[];
  int restores = 0;
  int logOuts = 0;
  void Function(StoreCustomer)? listener;

  @override
  Future<List<PlanOffer>> loadOffers() async {
    if (offersError != null) throw offersError!;
    return offers;
  }

  @override
  Future<StoreCustomer> customer() async => current;

  @override
  Future<StoreCustomer> purchase(PlanOffer offer) async {
    purchased.add(offer.plan);
    if (purchaseFailure != null) throw purchaseFailure!;
    return current = purchaseResult;
  }

  @override
  Future<StoreCustomer> purchasePlan(PremiumPlan plan) async {
    purchasedByProductId.add(plan);
    if (purchaseFailure != null) throw purchaseFailure!;
    return current = purchaseResult;
  }

  @override
  Future<StoreCustomer> restore() async {
    restores++;
    if (restoreFailure != null) throw restoreFailure!;
    return current = restoreResult;
  }

  @override
  Future<StoreCustomer> logIn(String userId) async {
    loggedIn.add(userId);
    return current;
  }

  @override
  Future<StoreCustomer> logOut() async {
    logOuts++;
    return current = StoreCustomer.none;
  }

  @override
  VoidCallback listen(void Function(StoreCustomer customer) onChange) {
    listener = onChange;
    return () => listener = null;
  }
}

class FakeServer implements PremiumServer {
  /// Answers in order; the last one repeats.
  List<ServerPremium?> answers = [const ServerPremium(isPremium: false)];
  int calls = 0;

  @override
  Future<ServerPremium?> sync() async {
    final answer = answers[calls < answers.length ? calls : answers.length - 1];
    calls++;
    return answer;
  }
}

class FakeReminder implements TrialReminderScheduler {
  final synced = <(StoreCustomer, bool)>[];

  @override
  Future<void> sync(
    StoreCustomer customer, {
    bool requestPermission = false,
  }) async {
    synced.add((customer, requestPermission));
  }
}

class Harness {
  Harness({bool signedIn = true}) {
    container = ProviderContainer(
      overrides: [
        purchasesGatewayProvider.overrideWithValue(gateway),
        premiumServerProvider.overrideWithValue(server),
        trialReminderProvider.overrideWithValue(reminder),
        hasSessionProvider.overrideWith((ref) async => signedIn),
      ],
    );
  }

  final gateway = FakeGateway();
  final server = FakeServer();
  final reminder = FakeReminder();
  late final ProviderContainer container;

  PremiumController get controller =>
      container.read(premiumControllerProvider.notifier);
  PremiumState get state => container.read(premiumControllerProvider);

  /// Build the controller and let its first load finish.
  Future<void> start() async {
    container.listen(premiumControllerProvider, (previous, next) {});
    await pump();
  }

  Future<void> pump() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => PremiumController.retryDelay = Duration.zero);

  group('plan mapping', () {
    StoreProduct product(String id, {IntroductoryPrice? intro}) => StoreProduct(
      id,
      'desc',
      'title',
      39.99,
      '€39,99',
      'EUR',
      introductoryPrice: intro,
    );
    const context = PresentedOfferingContext('default', null, null);
    Package package(String id, PackageType type, StoreProduct p) =>
        Package(id, type, p, context);
    const freeWeek = IntroductoryPrice(
      0,
      '€0,00',
      'P1W',
      1,
      PeriodUnit.week,
      1,
    );
    const freeSevenDays = IntroductoryPrice(
      0,
      '€0,00',
      'P7D',
      1,
      PeriodUnit.day,
      7,
    );
    const discounted = IntroductoryPrice(
      1.99,
      '€1,99',
      'P1M',
      1,
      PeriodUnit.month,
      1,
    );

    test('package type, package id and product id all map to a plan', () {
      expect(
        planForPackage(packageType: PackageType.annual, productId: 'anything'),
        PremiumPlan.yearly,
      );
      expect(
        planForPackage(packageId: r'$rc_monthly', productId: 'x'),
        PremiumPlan.monthly,
      );
      expect(
        planForPackage(
          packageType: PackageType.custom,
          productId: 'bijbelquiz_premium_lifetime',
        ),
        PremiumPlan.lifetime,
      );
      // Google Play subscription ids carry the base plan.
      expect(
        planForPackage(productId: 'bijbelquiz_premium_yearly:yearly'),
        PremiumPlan.yearly,
      );
      expect(planForPackage(productId: 'some_other_product'), isNull);
    });

    test('plan labels match the server', () {
      expect(planLabelForProduct('bijbelquiz_premium_yearly'), 'yearly');
      expect(planLabelForProduct('bijbelquiz_premium_monthly:m'), 'monthly');
      expect(planLabelForProduct('bijbelquiz_premium_lifetime'), 'lifetime');
      expect(PremiumPlan.lifetime.isSubscription, isFalse);
    });

    test('offers keep store prices, paywall order and only free trials', () {
      final offers = offersFromPackages([
        package(
          r'$rc_lifetime',
          PackageType.lifetime,
          product('bijbelquiz_premium_lifetime', intro: freeWeek),
        ),
        package(
          r'$rc_monthly',
          PackageType.monthly,
          product('bijbelquiz_premium_monthly', intro: discounted),
        ),
        package(
          r'$rc_annual',
          PackageType.annual,
          product('bijbelquiz_premium_yearly', intro: freeSevenDays),
        ),
        package('extra', PackageType.custom, product('unrelated')),
      ]);

      expect(offers.map((o) => o.plan), [
        PremiumPlan.yearly,
        PremiumPlan.monthly,
        PremiumPlan.lifetime,
      ]);
      expect(offers.first.priceString, '€39,99');
      expect(offers.first.trial?.label, '7 dagen gratis');
      // A discounted intro price is not a free trial.
      expect(offers[1].trial, isNull);
      // A one-off purchase never has a trial.
      expect(offers[2].trial, isNull);
      expect(offers.first.handle, isA<Package>());
    });

    test('no trial is promised to someone who already had one', () {
      final offers = offersFromPackages(
        [
          package(
            r'$rc_annual',
            PackageType.annual,
            product('bijbelquiz_premium_yearly', intro: freeSevenDays),
          ),
        ],
        eligibility: {
          'bijbelquiz_premium_yearly':
              IntroEligibilityStatus.introEligibilityStatusIneligible,
        },
      );
      expect(offers.single.trial, isNull);
    });

    test('SDK errors map to failure kinds', () {
      PurchaseFailureKind kind(PurchasesErrorCode code) => purchaseFailureFrom(
        PlatformException(code: '${code.index}', message: code.name),
      ).kind;
      expect(
        kind(PurchasesErrorCode.purchaseCancelledError),
        PurchaseFailureKind.cancelled,
      );
      expect(
        kind(PurchasesErrorCode.paymentPendingError),
        PurchaseFailureKind.pending,
      );
      expect(
        kind(PurchasesErrorCode.networkError),
        PurchaseFailureKind.network,
      );
      expect(
        kind(PurchasesErrorCode.productAlreadyPurchasedError),
        PurchaseFailureKind.alreadyOwned,
      );
      expect(
        kind(PurchasesErrorCode.receiptAlreadyInUseError),
        PurchaseFailureKind.ownedByOtherAccount,
      );
    });
  });

  group('trial reminder timing', () {
    final now = DateTime(2026, 10, 27, 12);

    test('fires two days before a renewing trial ends', () {
      final customer = StoreCustomer(
        premiumActive: true,
        isTrial: true,
        willRenew: true,
        expiresAt: now.add(const Duration(days: 7)),
      );
      expect(
        trialReminderFireAt(customer, now),
        now.add(const Duration(days: 5)),
      );
    });

    test('no reminder after cancelling, outside a trial, or too late', () {
      final end = now.add(const Duration(days: 7));
      expect(
        trialReminderFireAt(
          StoreCustomer(premiumActive: true, isTrial: true, expiresAt: end),
          now,
        ),
        isNull,
      );
      expect(
        trialReminderFireAt(
          StoreCustomer(premiumActive: true, willRenew: true, expiresAt: end),
          now,
        ),
        isNull,
      );
      expect(
        trialReminderFireAt(
          StoreCustomer(
            premiumActive: true,
            isTrial: true,
            willRenew: true,
            expiresAt: now.add(const Duration(days: 1)),
          ),
          now,
        ),
        isNull,
      );
    });
  });

  group('PremiumController', () {
    test('loads store offers and the entitlement on start', () async {
      final h = Harness();
      await h.start();
      expect(h.state.offersStatus, OffersStatus.ready);
      expect(h.state.offerFor(PremiumPlan.yearly)?.priceString, '€39,99');
      expect(h.state.isPremium, isFalse);
    });

    test(
      'offers that fail to load are marked unavailable, and reload',
      () async {
        final h = Harness();
        h.gateway.offersError = const PurchaseFailure(
          PurchaseFailureKind.network,
        );
        await h.start();
        expect(h.state.offersStatus, OffersStatus.unavailable);

        h.gateway.offersError = null;
        await h.controller.loadOffers();
        expect(h.state.offersStatus, OffersStatus.ready);
      },
    );

    test(
      'buying the yearly trial: Premium, server synced, reminder asked',
      () async {
        final h = Harness();
        await h.start();
        h.server.answers = [
          const ServerPremium(isPremium: false),
          const ServerPremium(isPremium: true, source: 'store'),
        ];

        await h.controller.purchase(PremiumPlan.yearly);

        expect(h.gateway.purchased, [PremiumPlan.yearly]);
        expect(h.state.status, PurchaseStatus.success);
        expect(h.state.action, PremiumAction.purchase);
        expect(h.state.isPremium, isTrue);
        expect(h.server.calls, 2);
        expect(
          h.reminder.synced.any((entry) => entry.$1.isTrial && entry.$2),
          isTrue,
          reason: 'the reminder may ask for permission right after a purchase',
        );
      },
    );

    test('signed out: no purchase, sign in first', () async {
      final h = Harness(signedIn: false);
      await h.start();
      await h.controller.purchase(PremiumPlan.monthly);
      expect(h.state.status, PurchaseStatus.needsAccount);
      expect(h.gateway.purchased, isEmpty);

      await h.controller.restorePurchases();
      expect(h.state.status, PurchaseStatus.needsAccount);
      expect(h.gateway.restores, 0);
    });

    test('Premium from the website or a group: never asked to pay', () async {
      final h = Harness();
      await h.start();
      h.server.answers = [
        const ServerPremium(isPremium: true, source: 'stripe'),
      ];

      await h.controller.purchase(PremiumPlan.yearly);

      expect(h.state.status, PurchaseStatus.alreadyPremium);
      expect(h.gateway.purchased, isEmpty);
      expect(h.state.isPremium, isTrue);
    });

    test('cancelling the store sheet is not an error', () async {
      final h = Harness();
      await h.start();
      h.gateway.purchaseFailure = const PurchaseFailure(
        PurchaseFailureKind.cancelled,
      );
      await h.controller.purchase(PremiumPlan.monthly);
      expect(h.state.status, PurchaseStatus.idle);
      expect(h.state.message, isNull);
    });

    test('Ask to Buy / pending payment is reported as pending', () async {
      final h = Harness();
      await h.start();
      h.gateway.purchaseFailure = const PurchaseFailure(
        PurchaseFailureKind.pending,
      );
      await h.controller.purchase(PremiumPlan.yearly);
      expect(h.state.status, PurchaseStatus.pending);
      expect(h.state.message, contains('goedkeuring'));

      // Approved later: RevenueCat pushes new customer info, the server is
      // told without the player doing anything.
      final callsBefore = h.server.calls;
      h.server.answers = [const ServerPremium(isPremium: true)];
      h.controller.clearStatus();
      h.gateway.listener!(_trialCustomer);
      await h.pump();
      expect(h.state.customer.premiumActive, isTrue);
      expect(h.server.calls, greaterThan(callsBefore));
    });

    test('store errors become a Dutch message', () async {
      final h = Harness();
      await h.start();
      h.gateway.purchaseFailure = const PurchaseFailure(
        PurchaseFailureKind.network,
      );
      await h.controller.purchase(PremiumPlan.monthly);
      expect(h.state.status, PurchaseStatus.error);
      expect(h.state.message, contains('internetverbinding'));
    });

    test('paid but no entitlement: error that points at Herstellen', () async {
      final h = Harness();
      await h.start();
      h.gateway.purchaseResult = StoreCustomer.none;
      await h.controller.purchase(PremiumPlan.lifetime);
      expect(h.state.status, PurchaseStatus.error);
      expect(h.state.message, contains('Herstellen'));
      // Nothing in the store, so the server is asked once, not polled.
      expect(h.server.calls, 2);
    });

    test('without loaded offers the plan is bought by product id', () async {
      final h = Harness();
      h.gateway.offers = const [];
      await h.start();
      expect(h.state.offersStatus, OffersStatus.unavailable);
      await h.controller.purchase(PremiumPlan.lifetime);
      expect(h.gateway.purchasedByProductId, [PremiumPlan.lifetime]);
    });

    test('restore: found, and nothing to restore', () async {
      final h = Harness();
      await h.start();

      await h.controller.restorePurchases();
      expect(h.state.status, PurchaseStatus.nothingToRestore);
      expect(h.state.message, isNotNull);

      h.gateway.restoreResult = const StoreCustomer(
        premiumActive: true,
        willRenew: true,
        productId: kRcMonthlyProductId,
      );
      h.server.answers = [const ServerPremium(isPremium: true)];
      await h.controller.restorePurchases();
      expect(h.state.status, PurchaseStatus.success);
      expect(h.state.action, PremiumAction.restore);
    });

    test('restore picks up Premium the server already has', () async {
      final h = Harness();
      await h.start();
      h.server.answers = [
        const ServerPremium(isPremium: true, source: 'group'),
      ];
      await h.controller.restorePurchases();
      expect(h.state.status, PurchaseStatus.success);
    });

    test(
      'sign-in logs RevenueCat in with the account id; sign-out forgets',
      () async {
        final h = Harness();
        await h.start();
        h.gateway.current = _trialCustomer;
        h.server.answers = [const ServerPremium(isPremium: true)];

        await h.controller.onSignedIn('64b7f0c2a1b2c3d4e5f60718');
        await h.pump();
        expect(h.gateway.loggedIn, ['64b7f0c2a1b2c3d4e5f60718']);
        expect(h.state.isPremium, isTrue);

        await h.controller.onSignedOut();
        expect(h.gateway.logOuts, 1);
        expect(h.state.isPremium, isFalse);
        expect(h.state.serverPremium, isNull);
        // Prices stay; they do not depend on the account.
        expect(h.state.offersStatus, OffersStatus.ready);
      },
    );

    test('refresh (app resume) re-reads the store and the server', () async {
      final h = Harness();
      await h.start();
      final before = h.server.calls;
      h.gateway.current = const StoreCustomer(premiumActive: true);
      await h.controller.refresh();
      expect(h.state.customer.premiumActive, isTrue);
      expect(h.server.calls, before + 1);
    });

    test('a second tap while busy does not start a second purchase', () async {
      final h = Harness();
      await h.start();
      final slow = Completer<void>();
      h.server.answers = [const ServerPremium(isPremium: false)];
      final first = h.controller.purchase(PremiumPlan.yearly);
      final second = h.controller.purchase(PremiumPlan.yearly);
      slow.complete();
      await Future.wait([first, second]);
      expect(h.gateway.purchased.length, 1);
    });
  });
}
