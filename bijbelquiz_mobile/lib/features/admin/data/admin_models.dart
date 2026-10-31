import 'admin_json.dart';

/// Models for the admin API (`/api/mobile/admin/**`), as described in
/// `docs/setup/admin-api.md` in the website repository.
///
/// Every `fromJson` is forgiving: a field an older server does not send yet
/// reads as zero / empty, never as a crash.

// ---------------------------------------------------------------------------
// Errors
// ---------------------------------------------------------------------------

/// The server answered with an error (`{ "error": "..." }`).
class AdminApiException implements Exception {
  const AdminApiException(this.statusCode, this.message, {this.field});

  final int? statusCode;

  /// Dutch message from the server, ready to show.
  final String message;

  /// The input that was wrong, on a 400.
  final String? field;

  @override
  String toString() => message;
}

/// The endpoint does not exist on this server (an older deployment).
class AdminEndpointMissing implements Exception {
  const AdminEndpointMissing(this.what);

  /// What the endpoint is for, e.g. "de gebruikerslijst".
  final String what;

  @override
  String toString() => 'Werk de server bij: $what ontbreekt.';
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

/// The platform keys the server uses, in display order.
const List<String> kAdminPlatformKeys = [
  'web-desktop',
  'web-mobile',
  'web',
  'ios',
  'android',
  'app',
  'onbekend',
];

const List<String> kAdminPremiumSources = [
  'stripe',
  'store',
  'lifetime',
  'group',
  'manual',
];

/// A count for one period, split per platform. Missing keys mean 0.
class AdminPeriodCount {
  const AdminPeriodCount({this.total = 0, this.byPlatform = const {}});

  final int total;
  final Map<String, int> byPlatform;

  int of(String platform) => byPlatform[platform] ?? 0;

  factory AdminPeriodCount.fromJson(Object? json) {
    if (json is num) return AdminPeriodCount(total: json.round());
    final m = jMap(json);
    return AdminPeriodCount(
      total: jInt(m['total']),
      byPlatform: jCounts(m['byPlatform']),
    );
  }
}

/// One week bar in the registrations chart.
class AdminWeek {
  const AdminWeek({
    required this.weekStart,
    required this.label,
    required this.total,
    required this.byPlatform,
  });

  final String weekStart;
  final String label;
  final int total;
  final Map<String, int> byPlatform;

  factory AdminWeek.fromJson(Map<String, dynamic> m) => AdminWeek(
    weekStart: jString(m['weekStart']),
    label: jString(m['label'], jString(m['weekStart'])),
    total: jInt(m['total']),
    byPlatform: jCounts(m['byPlatform']),
  );
}

/// "x of y, z%" - used for retention (cohort/retained) and conversion
/// (accounts/premium).
class AdminRate {
  const AdminRate({this.base = 0, this.part = 0, this.rate = 0});

  /// Cohort size or number of accounts.
  final int base;

  /// Retained or premium.
  final int part;

  /// Percent 0-100, one decimal.
  final double rate;

  factory AdminRate.fromJson(Object? json) {
    final m = jMap(json);
    return AdminRate(
      base: jInt(m['cohort'] ?? m['accounts']),
      part: jInt(m['retained'] ?? m['premium']),
      rate: jDouble(m['rate']),
    );
  }

  static Map<String, AdminRate> mapFromJson(Object? json) => {
    for (final e in jMap(json).entries) e.key: AdminRate.fromJson(e.value),
  };
}

/// Who did something (grant, revoke).
class AdminActor {
  const AdminActor({this.id = '', this.name = '', this.email = ''});

  final String id;
  final String name;
  final String email;

  String get display =>
      name.isNotEmpty ? name : (email.isNotEmpty ? email : '-');

  factory AdminActor.fromJson(Object? json) {
    if (json is String) return AdminActor(name: json);
    final m = jMap(json);
    return AdminActor(
      id: jString(m['id']),
      name: jString(m['name']),
      email: jString(m['email']),
    );
  }
}

/// `{ active, source, sources, until }` - Premium as one line.
class AdminPremiumState {
  const AdminPremiumState({
    this.active = false,
    this.source,
    this.sources = const [],
    this.until,
  });

  final bool active;

  /// The single source shown (lifetime > stripe > store > group > manual).
  final String? source;
  final List<String> sources;

  /// When [source] ends; null for lifetime / no end date.
  final DateTime? until;

  bool get hasManual => sources.contains('manual');

  factory AdminPremiumState.fromJson(Object? json) {
    if (json is bool) return AdminPremiumState(active: json);
    final m = jMap(json);
    final sources = jStringList(m['sources']);
    final source = jStringOrNull(m['source']);
    return AdminPremiumState(
      active: jBool(m['active']),
      source: source,
      sources: sources.isEmpty && source != null ? [source] : sources,
      until: jDate(m['until']),
    );
  }
}

// ---------------------------------------------------------------------------
// Health (shared with the legacy /admin/stats screen)
// ---------------------------------------------------------------------------

/// One non-OK check from the betaal-pijplijn report.
class AdminHealthIssue {
  const AdminHealthIssue({
    required this.label,
    required this.status,
    required this.detail,
    this.action,
  });

  final String label;

  /// `"warn"` or `"fail"`.
  final String status;
  final String detail;
  final String? action;

  factory AdminHealthIssue.fromJson(Map<String, dynamic> json) {
    return AdminHealthIssue(
      label: json['label']?.toString() ?? '',
      status: json['status']?.toString() ?? 'warn',
      detail: json['detail']?.toString() ?? '',
      action: jStringOrNull(json['action']),
    );
  }
}

/// An account that paid but has no Premium.
class AdminAccessGap {
  const AdminAccessGap({
    required this.userId,
    required this.name,
    required this.email,
    required this.reason,
    this.when,
  });

  final String userId;
  final String name;
  final String email;
  final String reason;
  final DateTime? when;

  factory AdminAccessGap.fromJson(Map<String, dynamic> m) => AdminAccessGap(
    userId: jString(m['userId']),
    name: jString(m['name']),
    email: jString(m['email']),
    reason: jString(m['reason']),
    when: jDate(m['when']),
  );
}

/// Trimmed `getPaymentsHealth()` output - "did paying work end to end".
class AdminHealth {
  const AdminHealth({
    required this.overall,
    required this.issues,
    required this.okCount,
    required this.accessGapCount,
    required this.paywallShown,
    required this.checkoutStarted,
    required this.purchaseCompleted,
    required this.stripeKeyMode,
    required this.revenuecatConfigured,
    this.checkedAt,
    this.accessGaps = const [],
    this.hasFunnel = false,
  });

  /// `"ok"` / `"warn"` / `"fail"`.
  final String overall;
  final List<AdminHealthIssue> issues;
  final int okCount;
  final int accessGapCount;
  final int paywallShown;
  final int checkoutStarted;
  final int purchaseCompleted;
  final String stripeKeyMode;
  final bool revenuecatConfigured;
  final DateTime? checkedAt;

  /// Only from `payments/health`.
  final List<AdminAccessGap> accessGaps;

  /// Whether the response carried `funnel30d` (the overview does not).
  final bool hasFunnel;

  factory AdminHealth.fromJson(Map<String, dynamic> json) {
    final funnel = jMap(json['funnel30d']);
    return AdminHealth(
      overall: json['overall']?.toString() ?? 'warn',
      issues: jMapList(json['issues']).map(AdminHealthIssue.fromJson).toList(),
      okCount: jInt(json['okCount']),
      accessGapCount: jInt(
        json['accessGapCount'],
        json['accessGaps'] is List ? (json['accessGaps'] as List).length : 0,
      ),
      paywallShown: jInt(funnel['paywallShown']),
      checkoutStarted: jInt(funnel['checkoutStarted']),
      purchaseCompleted: jInt(funnel['purchaseCompleted']),
      stripeKeyMode: json['stripeKeyMode']?.toString() ?? 'missing',
      revenuecatConfigured: json['revenuecatConfigured'] == true,
      checkedAt: jDate(json['checkedAt']),
      accessGaps: jMapList(
        json['accessGaps'],
      ).map(AdminAccessGap.fromJson).toList(),
      hasFunnel: json['funnel30d'] is Map,
    );
  }
}

// ---------------------------------------------------------------------------
// Revenue
// ---------------------------------------------------------------------------

class AdminRevenueSource {
  const AdminRevenueSource({
    this.netCentsAllTime = 0,
    this.netCentsLast30d = 0,
    this.payments = 0,
  });

  final int netCentsAllTime;
  final int netCentsLast30d;
  final int payments;

  factory AdminRevenueSource.fromJson(Object? json) {
    final m = jMap(json);
    return AdminRevenueSource(
      netCentsAllTime: jInt(m['netCentsAllTime']),
      netCentsLast30d: jInt(m['netCentsLast30d']),
      payments: jInt(m['payments']),
    );
  }
}

class AdminCurrencyAmount {
  const AdminCurrencyAmount(this.currency, this.netCents);

  final String currency;
  final int netCents;

  static List<AdminCurrencyAmount> listFromJson(Object? json) => [
    for (final m in jMapList(json))
      AdminCurrencyAmount(
        jString(m['currency'], '?'),
        jInt(m['netCents'] ?? m['amountCents'] ?? m['cents']),
      ),
  ];
}

class AdminRevenue {
  const AdminRevenue({
    this.currency = 'eur',
    this.netCentsLast30d = 0,
    this.netCentsAllTime = 0,
    this.refundedCentsAllTime = 0,
    this.paymentsCompleted = 0,
    this.renewalsAllTime = 0,
    this.bySource = const {},
    this.otherCurrenciesAllTime = const [],
    this.otherCurrenciesLast30d = const [],
  });

  final String currency;
  final int netCentsLast30d;
  final int netCentsAllTime;
  final int refundedCentsAllTime;
  final int paymentsCompleted;
  final int renewalsAllTime;
  final Map<String, AdminRevenueSource> bySource;
  final List<AdminCurrencyAmount> otherCurrenciesAllTime;
  final List<AdminCurrencyAmount> otherCurrenciesLast30d;

  AdminRevenueSource source(String key) =>
      bySource[key] ?? const AdminRevenueSource();

  factory AdminRevenue.fromJson(Object? json) {
    final m = jMap(json);
    return AdminRevenue(
      currency: jString(m['currency'], 'eur'),
      netCentsLast30d: jInt(m['netCentsLast30d'] ?? m['grossCentsLast30d']),
      netCentsAllTime: jInt(m['netCentsAllTime'] ?? m['grossCentsAllTime']),
      refundedCentsAllTime: jInt(m['refundedCentsAllTime']),
      paymentsCompleted: jInt(m['paymentsCompleted']),
      renewalsAllTime: jInt(m['renewalsAllTime']),
      bySource: {
        for (final e in jMap(m['bySource']).entries)
          e.key: AdminRevenueSource.fromJson(e.value),
      },
      otherCurrenciesAllTime: AdminCurrencyAmount.listFromJson(
        m['otherCurrenciesAllTime'],
      ),
      otherCurrenciesLast30d: AdminCurrencyAmount.listFromJson(
        m['otherCurrenciesLast30d'],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rows
// ---------------------------------------------------------------------------

/// One account in the users list (`UserRow`).
class AdminUserRow {
  const AdminUserRow({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
    this.signupPlatform = 'onbekend',
    this.signupPlatformDerived = false,
    this.signupMethod = 'onbekend',
    this.lastActiveAt,
    this.lastSeenPlatform,
    this.premium = const AdminPremiumState(),
    this.quizzesPlayed = 0,
    this.xp = 0,
    this.level = 0,
    this.role = 'user',
    this.isInternal = false,
  });

  final String id;
  final String name;
  final String email;
  final DateTime? createdAt;
  final String signupPlatform;
  final bool signupPlatformDerived;
  final String signupMethod;
  final DateTime? lastActiveAt;
  final String? lastSeenPlatform;
  final AdminPremiumState premium;
  final int quizzesPlayed;
  final int xp;
  final int level;
  final String role;
  final bool isInternal;

  bool get isAdmin => role == 'admin';
  String get displayName => name.isNotEmpty ? name : 'Naamloos';

  factory AdminUserRow.fromJson(Map<String, dynamic> m) {
    // The older overview `recentUsers` row carries `isPremium` only.
    final premium = m['premium'] != null
        ? AdminPremiumState.fromJson(m['premium'])
        : AdminPremiumState(active: jBool(m['isPremium']));
    return AdminUserRow(
      id: jString(m['id'] ?? m['_id']),
      name: jString(m['name']),
      email: jString(m['email']),
      createdAt: jDate(m['createdAt']),
      signupPlatform: jString(m['signupPlatform'], 'onbekend'),
      signupPlatformDerived: jBool(m['signupPlatformDerived']),
      signupMethod: jString(m['signupMethod'], 'onbekend'),
      lastActiveAt: jDate(m['lastActiveAt']),
      lastSeenPlatform: jStringOrNull(m['lastSeenPlatform']),
      premium: premium,
      quizzesPlayed: jInt(m['quizzesPlayed']),
      xp: jInt(m['xp']),
      level: jInt(m['level']),
      role: jString(m['role'], 'user'),
      isInternal: jBool(m['isInternal']),
    );
  }
}

/// One row from the Payment collection (`PaymentRow`).
class AdminPaymentRow {
  const AdminPaymentRow({
    required this.id,
    this.userId,
    required this.userName,
    this.userEmail = '',
    this.userDeleted = false,
    this.provider = 'stripe',
    this.store,
    this.planType = '',
    this.amountCents = 0,
    this.currency = 'eur',
    this.status = '',
    this.refundedCents = 0,
    this.isTest = false,
    this.isInternal = false,
    this.isRenewal = false,
    this.counted = true,
    this.createdAt,
  });

  final String id;
  final String? userId;
  final String userName;
  final String userEmail;
  final bool userDeleted;

  /// `stripe` or `revenuecat`.
  final String provider;

  /// `app_store`, `play_store` or null (Stripe).
  final String? store;
  final String planType;
  final int amountCents;
  final String currency;
  final String status;
  final int refundedCents;
  final bool isTest;
  final bool isInternal;
  final bool isRenewal;

  /// Whether it counts as revenue.
  final bool counted;
  final DateTime? createdAt;

  /// Where the money came from, for display: Stripe / App Store / Google Play.
  String get channel => store ?? provider;

  factory AdminPaymentRow.fromJson(Map<String, dynamic> m) => AdminPaymentRow(
    id: jString(m['id'] ?? m['_id']),
    userId: jStringOrNull(m['userId']),
    userName: jString(m['userName'], 'Onbekend'),
    userEmail: jString(m['userEmail']),
    userDeleted: jBool(m['userDeleted']),
    provider: jString(m['provider'], 'stripe'),
    store: jStringOrNull(m['store']),
    planType: jString(m['planType']),
    amountCents: jInt(m['amountCents']),
    currency: jString(m['currency'], 'eur'),
    status: jString(m['status']),
    refundedCents: jInt(m['refundedCents']),
    isTest: jBool(m['isTest']),
    isInternal: jBool(m['isInternal']),
    isRenewal: jBool(m['isRenewal']),
    counted: jBool(m['counted'], true),
    createdAt: jDate(m['createdAt']),
  );
}

// ---------------------------------------------------------------------------
// 1. Overview
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Free trials
// ---------------------------------------------------------------------------

/// What became of a free trial: `running` (turns into a paid subscription at
/// its end), `cancelled` (renewal turned off, stops at its end), `converted`
/// (paid since), `ended` (over without paying).
enum AdminTrialStatus { running, cancelled, converted, ended }

AdminTrialStatus _trialStatus(Object? raw) => switch (jStringOrNull(raw)) {
  'cancelled' => AdminTrialStatus.cancelled,
  'converted' => AdminTrialStatus.converted,
  'ended' => AdminTrialStatus.ended,
  _ => AdminTrialStatus.running,
};

/// One free trial (`trials.trials[]` on the overview, `premium.trial` on a user).
class AdminTrial {
  const AdminTrial({
    this.userId = '',
    this.name,
    this.email,
    this.provider = 'revenuecat',
    this.platform = 'ios',
    this.plan,
    this.startedAt,
    this.endsAt,
    this.status = AdminTrialStatus.running,
    this.daysLeft,
  });

  final String userId;
  final String? name;
  final String? email;

  /// `stripe` (website) or `revenuecat` (App Store / Google Play).
  final String provider;
  final String platform;

  /// `yearly`, `monthly` or `lifetime`.
  final String? plan;
  final DateTime? startedAt;
  final DateTime? endsAt;
  final AdminTrialStatus status;

  /// Whole days left while running; null once over.
  final int? daysLeft;

  bool get isOpen =>
      status == AdminTrialStatus.running ||
      status == AdminTrialStatus.cancelled;

  static AdminTrial? fromJsonOrNull(Object? json) =>
      json is Map ? AdminTrial.fromJson(jMap(json)) : null;

  factory AdminTrial.fromJson(Map<String, dynamic> m) => AdminTrial(
    userId: jString(m['userId']),
    name: jStringOrNull(m['name']),
    email: jStringOrNull(m['email']),
    provider: jString(m['provider'], 'revenuecat'),
    platform: jString(m['platform'], 'ios'),
    plan: jStringOrNull(m['plan']),
    startedAt: jDate(m['startedAt']),
    endsAt: jDate(m['endsAt']),
    status: _trialStatus(m['status']),
    daysLeft: m['daysLeft'] is num ? (m['daysLeft'] as num).toInt() : null,
  );
}

/// The overview's `trials` block.
class AdminTrials {
  const AdminTrials({
    this.windowDays = 60,
    this.running = 0,
    this.cancelled = 0,
    this.converted = 0,
    this.ended = 0,
    this.conversionRate,
    this.trials = const [],
  });

  final int windowDays;
  final int running;
  final int cancelled;
  final int converted;
  final int ended;

  /// Whole percentage of finished trials that turned into a payment.
  final int? conversionRate;
  final List<AdminTrial> trials;

  factory AdminTrials.fromJson(Object? json) {
    final m = jMap(json);
    return AdminTrials(
      windowDays: jInt(m['windowDays'], 60),
      running: jInt(m['running']),
      cancelled: jInt(m['cancelled']),
      converted: jInt(m['converted']),
      ended: jInt(m['ended']),
      conversionRate: m['conversionRate'] is num
          ? (m['conversionRate'] as num).toInt()
          : null,
      trials: jMapList(m['trials']).map(AdminTrial.fromJson).toList(),
    );
  }
}

class AdminOverview {
  const AdminOverview({
    this.generatedAt,
    this.internalExcluded = 0,
    this.usersTotal = 0,
    this.registrationsToday = const AdminPeriodCount(),
    this.registrations7d = const AdminPeriodCount(),
    this.registrations30d = const AdminPeriodCount(),
    this.registrationsAllTime = const AdminPeriodCount(),
    this.weekly = const [],
    this.byMethod = const {},
    this.activeToday = const AdminPeriodCount(),
    this.active7d = const AdminPeriodCount(),
    this.active30d = const AdminPeriodCount(),
    this.retentionDescription,
    this.retention = const AdminRate(),
    this.retentionByPlatform = const {},
    this.premiumTotal = 0,
    this.premiumShare = 0,
    this.premiumBySource = const {},
    this.premiumBySignupPlatform = const {},
    this.conversionDescription,
    this.conversion = const AdminRate(),
    this.paidConversion = const AdminRate(),
    this.conversionByPlatform = const {},
    this.conversionNew30d = const AdminRate(),
    this.grantsActive = 0,
    this.grantsExpiringIn7d = 0,
    this.revenue = const AdminRevenue(),
    this.quizzesTotal = 0,
    this.quizzesPending = 0,
    this.playsDescription,
    this.plays7d = const AdminPeriodCount(),
    this.plays30d = const AdminPeriodCount(),
    this.health,
    this.recentUsers = const [],
    this.recentPayments = const [],
    this.trials = const AdminTrials(),
  });

  final DateTime? generatedAt;
  final int internalExcluded;

  final int usersTotal;
  final AdminPeriodCount registrationsToday;
  final AdminPeriodCount registrations7d;
  final AdminPeriodCount registrations30d;
  final AdminPeriodCount registrationsAllTime;
  final List<AdminWeek> weekly;
  final Map<String, int> byMethod;
  final AdminPeriodCount activeToday;
  final AdminPeriodCount active7d;
  final AdminPeriodCount active30d;
  final String? retentionDescription;
  final AdminRate retention;
  final Map<String, AdminRate> retentionByPlatform;

  final int premiumTotal;
  final double premiumShare;
  final Map<String, int> premiumBySource;
  final Map<String, int> premiumBySignupPlatform;
  final String? conversionDescription;
  final AdminRate conversion;
  final AdminRate paidConversion;
  final Map<String, AdminRate> conversionByPlatform;
  final AdminRate conversionNew30d;
  final int grantsActive;
  final int grantsExpiringIn7d;

  final AdminRevenue revenue;

  final int quizzesTotal;
  final int quizzesPending;
  final String? playsDescription;
  final AdminPeriodCount plays7d;
  final AdminPeriodCount plays30d;

  final AdminHealth? health;
  final List<AdminUserRow> recentUsers;
  final List<AdminPaymentRow> recentPayments;

  /// Free trials of the last [AdminTrials.windowDays] days.
  final AdminTrials trials;

  factory AdminOverview.fromJson(Map<String, dynamic> json) {
    final users = jMap(json['users']);
    final reg = jMap(users['registrations']);
    final active = jMap(users['active']);
    final retention = jMap(users['retention']);
    final premium = jMap(json['premium']);
    final conversion = jMap(premium['conversion']);
    final quizzes = jMap(json['quizzes']);
    final plays = jMap(quizzes['plays']);
    final paid = jMap(conversion['paid']);
    final total = jMap(conversion['total']);

    return AdminOverview(
      generatedAt: jDate(json['generatedAt']),
      internalExcluded: jInt(json['internalExcluded']),
      usersTotal: jInt(users['total'], jInt(jMap(reg['allTime'])['total'])),
      registrationsToday: AdminPeriodCount.fromJson(reg['today']),
      registrations7d: AdminPeriodCount.fromJson(reg['days7']),
      registrations30d: AdminPeriodCount.fromJson(reg['days30']),
      registrationsAllTime: AdminPeriodCount.fromJson(reg['allTime']),
      weekly: jMapList(reg['weekly']).map(AdminWeek.fromJson).toList(),
      byMethod: jCounts(users['byMethod']),
      activeToday: AdminPeriodCount.fromJson(active['today']),
      active7d: AdminPeriodCount.fromJson(active['days7']),
      active30d: AdminPeriodCount.fromJson(active['days30']),
      retentionDescription: jStringOrNull(retention['description']),
      retention: AdminRate.fromJson(retention['total']),
      retentionByPlatform: AdminRate.mapFromJson(retention['byPlatform']),
      premiumTotal: jInt(premium['total']),
      premiumShare: jDouble(premium['share']),
      premiumBySource: jCounts(premium['bySource']),
      premiumBySignupPlatform: jCounts(premium['bySignupPlatform']),
      conversionDescription: jStringOrNull(conversion['description']),
      conversion: AdminRate.fromJson(total),
      // `paid` has no `accounts` of its own: it shares the total's base.
      paidConversion: AdminRate(
        base: jInt(paid['accounts'], jInt(total['accounts'])),
        part: jInt(paid['premium']),
        rate: jDouble(paid['rate']),
      ),
      conversionByPlatform: AdminRate.mapFromJson(conversion['byPlatform']),
      conversionNew30d: AdminRate.fromJson(conversion['newLast30d']),
      grantsActive: jInt(premium['grantsActive']),
      grantsExpiringIn7d: jInt(premium['grantsExpiringIn7d']),
      revenue: AdminRevenue.fromJson(json['revenue']),
      quizzesTotal: jInt(quizzes['total']),
      quizzesPending: jInt(quizzes['pending']),
      playsDescription: jStringOrNull(plays['description']),
      plays7d: AdminPeriodCount.fromJson(plays['days7']),
      plays30d: AdminPeriodCount.fromJson(plays['days30']),
      health: json['health'] is Map
          ? AdminHealth.fromJson(jMap(json['health']))
          : null,
      recentUsers: jMapList(
        json['recentUsers'],
      ).map(AdminUserRow.fromJson).toList(),
      recentPayments: jMapList(
        json['recentPayments'],
      ).map(AdminPaymentRow.fromJson).toList(),
      trials: AdminTrials.fromJson(json['trials']),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Users list
// ---------------------------------------------------------------------------

class AdminUserQuery {
  const AdminUserQuery({
    this.q = '',
    this.platform,
    this.premium,
    this.source,
    this.test = 'include',
    this.sort = 'createdAt',
    this.order = 'desc',
    this.page = 1,
    this.pageSize = 25,
  });

  final String q;
  final String? platform;

  /// `yes` / `no` / null (all).
  final String? premium;
  final String? source;

  /// `include` / `exclude` / `only`.
  final String test;
  final String sort;
  final String order;
  final int page;
  final int pageSize;

  Map<String, dynamic> toQuery() => {
    if (q.trim().isNotEmpty) 'q': q.trim(),
    'platform': ?platform,
    'premium': ?premium,
    'source': ?source,
    if (test != 'include') 'test': test,
    'sort': sort,
    'order': order,
    'page': page,
    'pageSize': pageSize,
  };

  AdminUserQuery copyWith({
    String? q,
    Object? platform = _keep,
    Object? premium = _keep,
    Object? source = _keep,
    String? test,
    String? sort,
    String? order,
    int? page,
  }) {
    return AdminUserQuery(
      q: q ?? this.q,
      platform: platform == _keep ? this.platform : platform as String?,
      premium: premium == _keep ? this.premium : premium as String?,
      source: source == _keep ? this.source : source as String?,
      test: test ?? this.test,
      sort: sort ?? this.sort,
      order: order ?? this.order,
      page: page ?? this.page,
      pageSize: pageSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AdminUserQuery &&
      other.q == q &&
      other.platform == platform &&
      other.premium == premium &&
      other.source == source &&
      other.test == test &&
      other.sort == sort &&
      other.order == order &&
      other.page == page &&
      other.pageSize == pageSize;

  @override
  int get hashCode => Object.hash(
    q,
    platform,
    premium,
    source,
    test,
    sort,
    order,
    page,
    pageSize,
  );
}

const Object _keep = Object();

class AdminUserPage {
  const AdminUserPage({
    this.page = 1,
    this.pageSize = 25,
    this.total = 0,
    this.pages = 1,
    this.users = const [],
  });

  final int page;
  final int pageSize;
  final int total;
  final int pages;
  final List<AdminUserRow> users;

  bool get hasMore => page < pages;

  factory AdminUserPage.fromJson(Map<String, dynamic> m) {
    final users = jMapList(m['users']).map(AdminUserRow.fromJson).toList();
    final pageSize = jInt(m['pageSize'], 25);
    final total = jInt(m['total'], users.length);
    return AdminUserPage(
      page: jInt(m['page'], 1),
      pageSize: pageSize,
      total: total,
      pages: jInt(
        m['pages'],
        pageSize > 0
            ? ((total + pageSize - 1) ~/ pageSize).clamp(1, 1 << 30)
            : 1,
      ),
      users: users,
    );
  }
}

// ---------------------------------------------------------------------------
// 3. User detail
// ---------------------------------------------------------------------------

class AdminUserProfile {
  const AdminUserProfile({
    required this.row,
    this.image,
    this.updatedAt,
    this.lastPlayedAt,
    this.authPassword = false,
    this.authGoogle = false,
    this.authApple = false,
    this.levelTitle = '',
    this.streak = 0,
    this.bestStreak = 0,
    this.averageScore = 0,
    this.badges = const [],
    this.multiplayerGamesHosted = 0,
    this.onboarding = const {},
  });

  /// The list-row fields (name, e-mail, platform, ...).
  final AdminUserRow row;
  final String? image;
  final DateTime? updatedAt;
  final DateTime? lastPlayedAt;
  final bool authPassword;
  final bool authGoogle;
  final bool authApple;
  final String levelTitle;
  final int streak;
  final int bestStreak;
  final int averageScore;
  final List<String> badges;
  final int multiplayerGamesHosted;
  final Map<String, dynamic> onboarding;

  factory AdminUserProfile.fromJson(Map<String, dynamic> m) {
    final auth = jMap(m['auth']);
    return AdminUserProfile(
      row: AdminUserRow.fromJson(m),
      image: jStringOrNull(m['image']),
      updatedAt: jDate(m['updatedAt']),
      lastPlayedAt: jDate(m['lastPlayedAt']),
      authPassword: jBool(auth['password']),
      authGoogle: jBool(auth['google']),
      authApple: jBool(auth['apple']),
      levelTitle: jString(m['levelTitle']),
      streak: jInt(m['streak']),
      bestStreak: jInt(m['bestStreak']),
      averageScore: jInt(m['averageScore']),
      badges: jStringList(m['badges']),
      multiplayerGamesHosted: jInt(m['multiplayerGamesHosted']),
      onboarding: jMap(m['onboarding']),
    );
  }
}

class AdminStripeInfo {
  const AdminStripeInfo({
    this.active = false,
    this.status,
    this.plan,
    this.currentPeriodEnd,
    this.cancelAtPeriodEnd = false,
    this.trialEnd,
    this.customerId,
    this.subscriptionId,
  });

  final bool active;
  final String? status;
  final String? plan;
  final DateTime? currentPeriodEnd;
  final bool cancelAtPeriodEnd;
  final DateTime? trialEnd;
  final String? customerId;
  final String? subscriptionId;

  bool get isKnown => active || status != null || customerId != null;

  factory AdminStripeInfo.fromJson(Object? json) {
    final m = jMap(json);
    return AdminStripeInfo(
      active: jBool(m['active']),
      status: jStringOrNull(m['status']),
      plan: jStringOrNull(m['plan']),
      currentPeriodEnd: jDate(m['currentPeriodEnd']),
      cancelAtPeriodEnd: jBool(m['cancelAtPeriodEnd']),
      trialEnd: jDate(m['trialEnd']),
      customerId: jStringOrNull(m['customerId']),
      subscriptionId: jStringOrNull(m['subscriptionId']),
    );
  }
}

class AdminGroupLicenseRef {
  const AdminGroupLicenseRef({
    required this.id,
    required this.name,
    this.role = 'member',
    this.status = '',
    this.expiresAt,
  });

  final String id;
  final String name;
  final String role;
  final String status;
  final DateTime? expiresAt;

  factory AdminGroupLicenseRef.fromJson(Map<String, dynamic> m) =>
      AdminGroupLicenseRef(
        id: jString(m['id']),
        name: jString(m['name'], 'Groepslicentie'),
        role: jString(m['role'], 'member'),
        status: jString(m['status']),
        expiresAt: jDate(m['expiresAt']),
      );
}

class AdminManualGrant {
  const AdminManualGrant({
    this.active = false,
    this.until,
    this.grantedAt,
    this.grantedBy,
    this.note,
    this.legacy = false,
  });

  final bool active;
  final DateTime? until;
  final DateTime? grantedAt;
  final AdminActor? grantedBy;
  final String? note;

  /// Set by hand before grants were dated: no end date, no audit entry.
  final bool legacy;

  factory AdminManualGrant.fromJson(Object? json) {
    final m = jMap(json);
    return AdminManualGrant(
      active: jBool(m['active']),
      until: jDate(m['until']),
      grantedAt: jDate(m['grantedAt']),
      grantedBy: m['grantedBy'] == null
          ? null
          : AdminActor.fromJson(m['grantedBy']),
      note: jStringOrNull(m['note']),
      legacy: jBool(m['legacy']),
    );
  }
}

class AdminPremiumDetail {
  const AdminPremiumDetail({
    this.state = const AdminPremiumState(),
    this.stripe = const AdminStripeInfo(),
    this.storeActive = false,
    this.storeExpiresAt,
    this.storeWillRenew,
    this.trial,
    this.lifetime = false,
    this.groupActive = false,
    this.groupUntil,
    this.groupLicenses = const [],
    this.manual = const AdminManualGrant(),
  });

  final AdminPremiumState state;
  final AdminStripeInfo stripe;
  final bool storeActive;
  final DateTime? storeExpiresAt;

  /// false once the player turned renewal off in the store; null when unknown.
  final bool? storeWillRenew;

  /// The latest free trial (store or website), null when there never was one.
  final AdminTrial? trial;
  final bool lifetime;
  final bool groupActive;
  final DateTime? groupUntil;
  final List<AdminGroupLicenseRef> groupLicenses;
  final AdminManualGrant manual;

  factory AdminPremiumDetail.fromJson(Object? json) {
    final m = jMap(json);
    final store = jMap(m['store']);
    final group = jMap(m['group']);
    return AdminPremiumDetail(
      state: AdminPremiumState.fromJson(m),
      stripe: AdminStripeInfo.fromJson(m['stripe']),
      storeActive: jBool(store['active']),
      storeExpiresAt: jDate(store['expiresAt']),
      storeWillRenew: store['willRenew'] is bool
          ? store['willRenew'] as bool
          : null,
      trial: AdminTrial.fromJsonOrNull(m['trial']),
      lifetime: jBool(jMap(m['lifetime'])['active'], jBool(m['lifetime'])),
      groupActive: jBool(group['active']),
      groupUntil: jDate(group['until']),
      groupLicenses: jMapList(
        group['licenses'],
      ).map(AdminGroupLicenseRef.fromJson).toList(),
      manual: AdminManualGrant.fromJson(m['manual']),
    );
  }
}

class AdminGrantEntry {
  const AdminGrantEntry({
    required this.action,
    this.duration,
    this.until,
    this.note,
    this.at,
    this.by,
  });

  /// `grant` or `revoke`.
  final String action;
  final String? duration;
  final DateTime? until;
  final String? note;
  final DateTime? at;
  final AdminActor? by;

  bool get isRevoke => action == 'revoke';

  factory AdminGrantEntry.fromJson(Map<String, dynamic> m) => AdminGrantEntry(
    action: jString(m['action'], 'grant'),
    duration: jStringOrNull(m['duration']),
    until: jDate(m['until']),
    note: jStringOrNull(m['note']),
    at: jDate(m['at']),
    by: m['by'] == null ? null : AdminActor.fromJson(m['by']),
  );
}

class AdminPlatformHistory {
  const AdminPlatformHistory({
    required this.platform,
    this.firstAt,
    this.lastAt,
    this.events = 0,
    this.sessions = 0,
  });

  final String platform;
  final DateTime? firstAt;
  final DateTime? lastAt;
  final int events;
  final int sessions;

  factory AdminPlatformHistory.fromJson(Map<String, dynamic> m) =>
      AdminPlatformHistory(
        platform: jString(m['platform'], 'onbekend'),
        firstAt: jDate(m['firstAt']),
        lastAt: jDate(m['lastAt']),
        events: jInt(m['events']),
        sessions: jInt(m['sessions']),
      );
}

class AdminAttempt {
  const AdminAttempt({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    this.score = 0,
    this.totalQuestions = 0,
    this.xpEarned = 0,
    this.completedAt,
  });

  final String id;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final DateTime? completedAt;

  factory AdminAttempt.fromJson(Map<String, dynamic> m) => AdminAttempt(
    id: jString(m['id']),
    quizId: jString(m['quizId']),
    quizTitle: jString(m['quizTitle'], 'Quiz'),
    score: jInt(m['score']),
    totalQuestions: jInt(m['totalQuestions']),
    xpEarned: jInt(m['xpEarned']),
    completedAt: jDate(m['completedAt']),
  );
}

class AdminUserCounts {
  const AdminUserCounts({
    this.attempts = 0,
    this.duelsTotal = 0,
    this.duelsFinished = 0,
    this.duelsWon = 0,
    this.playerGroupsOwned = 0,
    this.playerGroupsMember = 0,
    this.groupLicensesOwned = 0,
    this.groupLicensesMember = 0,
  });

  final int attempts;
  final int duelsTotal;
  final int duelsFinished;
  final int duelsWon;
  final int playerGroupsOwned;
  final int playerGroupsMember;
  final int groupLicensesOwned;
  final int groupLicensesMember;

  factory AdminUserCounts.fromJson(Object? json) {
    final m = jMap(json);
    final duels = jMap(m['duels']);
    final groups = jMap(m['playerGroups']);
    final licenses = jMap(m['groupLicenses']);
    return AdminUserCounts(
      attempts: jInt(m['attempts']),
      duelsTotal: jInt(duels['total']),
      duelsFinished: jInt(duels['finished']),
      duelsWon: jInt(duels['won']),
      playerGroupsOwned: jInt(groups['owned']),
      playerGroupsMember: jInt(groups['member']),
      groupLicensesOwned: jInt(licenses['owned']),
      groupLicensesMember: jInt(licenses['member']),
    );
  }
}

class AdminUserDetail {
  const AdminUserDetail({
    required this.user,
    this.premium = const AdminPremiumDetail(),
    this.grantLog = const [],
    this.platformHistory = const [],
    this.payments = const [],
    this.recentAttempts = const [],
    this.counts = const AdminUserCounts(),
  });

  final AdminUserProfile user;
  final AdminPremiumDetail premium;
  final List<AdminGrantEntry> grantLog;
  final List<AdminPlatformHistory> platformHistory;
  final List<AdminPaymentRow> payments;
  final List<AdminAttempt> recentAttempts;
  final AdminUserCounts counts;

  /// A manual grant exists that "Premium intrekken" can end.
  bool get canRevoke => premium.manual.active || premium.state.hasManual;

  AdminUserDetail withPremium(
    AdminPremiumState state, {
    AdminGrantEntry? entry,
  }) {
    return AdminUserDetail(
      user: user,
      premium: AdminPremiumDetail(
        state: state,
        stripe: premium.stripe,
        storeActive: premium.storeActive,
        storeExpiresAt: premium.storeExpiresAt,
        lifetime: premium.lifetime,
        groupActive: premium.groupActive,
        groupUntil: premium.groupUntil,
        groupLicenses: premium.groupLicenses,
        manual: _manualAfter(state, entry),
      ),
      grantLog: entry == null ? grantLog : [entry, ...grantLog],
      platformHistory: platformHistory,
      payments: payments,
      recentAttempts: recentAttempts,
      counts: counts,
    );
  }

  /// The manual grant as a grant / revoke response leaves it.
  AdminManualGrant _manualAfter(
    AdminPremiumState state,
    AdminGrantEntry? entry,
  ) {
    if (!state.hasManual || entry?.isRevoke == true) {
      return const AdminManualGrant();
    }
    if (entry == null) return premium.manual;
    return AdminManualGrant(
      active: true,
      until: entry.until,
      grantedAt: entry.at,
      grantedBy: entry.by,
      note: entry.note,
    );
  }

  factory AdminUserDetail.fromJson(Map<String, dynamic> m) {
    // Tolerate a flat user object without the `user` wrapper.
    final userJson = m['user'] is Map ? jMap(m['user']) : m;
    return AdminUserDetail(
      user: AdminUserProfile.fromJson(userJson),
      premium: AdminPremiumDetail.fromJson(m['premium'] ?? userJson['premium']),
      grantLog: jMapList(m['grantLog']).map(AdminGrantEntry.fromJson).toList(),
      platformHistory: jMapList(
        m['platformHistory'],
      ).map(AdminPlatformHistory.fromJson).toList(),
      payments: jMapList(m['payments']).map(AdminPaymentRow.fromJson).toList(),
      recentAttempts: jMapList(
        m['recentAttempts'],
      ).map(AdminAttempt.fromJson).toList(),
      counts: AdminUserCounts.fromJson(m['counts']),
    );
  }
}

// ---------------------------------------------------------------------------
// 4/5. Grant & revoke
// ---------------------------------------------------------------------------

/// The duration presets the server accepts.
enum AdminGrantDuration {
  days7('7d', '7 dagen'),
  month1('1m', '1 maand'),
  months3('3m', '3 maanden'),
  year1('1y', '1 jaar'),
  lifetime('lifetime', 'Levenslang'),
  custom('custom', 'Kies een datum');

  const AdminGrantDuration(this.key, this.label);

  final String key;
  final String label;

  static AdminGrantDuration? fromKey(String? key) {
    for (final d in values) {
      if (d.key == key) return d;
    }
    return null;
  }

  /// Rough end date for the confirmation text. The server decides the exact
  /// moment; this only previews it.
  DateTime? previewEnd(DateTime now, {DateTime? custom}) => switch (this) {
    days7 => now.add(const Duration(days: 7)),
    month1 => DateTime(now.year, now.month + 1, now.day),
    months3 => DateTime(now.year, now.month + 3, now.day),
    year1 => DateTime(now.year + 1, now.month, now.day),
    lifetime => null,
    AdminGrantDuration.custom => custom,
  };
}

class AdminGrantRequest {
  const AdminGrantRequest({required this.duration, this.until, this.note});

  final AdminGrantDuration duration;

  /// Only for [AdminGrantDuration.custom]: the last day of the grant.
  final DateTime? until;
  final String? note;

  Map<String, dynamic> toJson() => {
    'duration': duration.key,
    'until': duration == AdminGrantDuration.custom && until != null
        ? _isoDate(until!)
        : null,
    if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
  };

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// Response of a grant or revoke.
class AdminGrantResult {
  const AdminGrantResult({required this.premium, this.grant, this.user});

  final AdminPremiumState premium;
  final AdminGrantEntry? grant;

  /// Only from the by-e-mail endpoint.
  final AdminUserRow? user;

  factory AdminGrantResult.fromJson(Map<String, dynamic> m) => AdminGrantResult(
    premium: AdminPremiumState.fromJson(m['premium']),
    grant: m['grant'] is Map
        ? AdminGrantEntry.fromJson(jMap(m['grant']))
        : null,
    user: m['user'] is Map ? AdminUserRow.fromJson(jMap(m['user'])) : null,
  );
}

// ---------------------------------------------------------------------------
// 6. Quizzes
// ---------------------------------------------------------------------------

class AdminQuizRow {
  const AdminQuizRow({
    required this.id,
    required this.title,
    this.slug = '',
    this.status = 'approved',
    this.isPremium = false,
    this.category,
    this.questionCount = 0,
    this.createdBy,
    this.createdAt,
    this.plays30d,
  });

  final String id;
  final String title;
  final String slug;
  final String status;
  final bool isPremium;
  final String? category;
  final int questionCount;
  final String? createdBy;
  final DateTime? createdAt;
  final int? plays30d;

  AdminQuizRow copyWith({String? status, bool? isPremium}) => AdminQuizRow(
    id: id,
    title: title,
    slug: slug,
    status: status ?? this.status,
    isPremium: isPremium ?? this.isPremium,
    category: category,
    questionCount: questionCount,
    createdBy: createdBy,
    createdAt: createdAt,
    plays30d: plays30d,
  );

  factory AdminQuizRow.fromJson(Map<String, dynamic> m) => AdminQuizRow(
    id: jString(m['id'] ?? m['_id']),
    title: jString(m['title'], 'Zonder titel'),
    slug: jString(m['slug']),
    status: jString(m['status'], 'approved'),
    isPremium: jBool(m['isPremium']),
    category: jStringOrNull(m['category']),
    questionCount: jInt(m['questionCount']),
    createdBy: jStringOrNull(m['createdBy']),
    createdAt: jDate(m['createdAt']),
    plays30d: jIntOrNull(m['plays30d']),
  );
}

class AdminQuizList {
  const AdminQuizList({this.counts = const {}, this.quizzes = const []});

  final Map<String, int> counts;
  final List<AdminQuizRow> quizzes;

  factory AdminQuizList.fromJson(Map<String, dynamic> m) => AdminQuizList(
    counts: jCounts(m['counts']),
    quizzes: jMapList(m['quizzes']).map(AdminQuizRow.fromJson).toList(),
  );
}

/// Moderation actions on a quiz.
enum AdminQuizAction { approve, reject, publish, unpublish, premium }

// ---------------------------------------------------------------------------
// 7. Payments
// ---------------------------------------------------------------------------

class AdminPaymentQuery {
  const AdminPaymentQuery({
    this.page = 1,
    this.pageSize = 25,
    this.provider,
    this.status,
    this.q = '',
  });

  final int page;
  final int pageSize;
  final String? provider;
  final String? status;
  final String q;

  Map<String, dynamic> toQuery() => {
    'page': page,
    'pageSize': pageSize,
    'provider': ?provider,
    'status': ?status,
    if (q.trim().isNotEmpty) 'q': q.trim(),
  };

  @override
  bool operator ==(Object other) =>
      other is AdminPaymentQuery &&
      other.page == page &&
      other.pageSize == pageSize &&
      other.provider == provider &&
      other.status == status &&
      other.q == q;

  @override
  int get hashCode => Object.hash(page, pageSize, provider, status, q);
}

class AdminPaymentPage {
  const AdminPaymentPage({
    this.page = 1,
    this.pageSize = 25,
    this.total = 0,
    this.pages = 1,
    this.revenue,
    this.payments = const [],
  });

  final int page;
  final int pageSize;
  final int total;
  final int pages;
  final AdminRevenue? revenue;
  final List<AdminPaymentRow> payments;

  bool get hasMore => page < pages;

  factory AdminPaymentPage.fromJson(Map<String, dynamic> m) {
    final payments = jMapList(
      m['payments'],
    ).map(AdminPaymentRow.fromJson).toList();
    return AdminPaymentPage(
      page: jInt(m['page'], 1),
      pageSize: jInt(m['pageSize'], 25),
      total: jInt(m['total'], payments.length),
      pages: jInt(m['pages'], 1),
      revenue: m['revenue'] is Map ? AdminRevenue.fromJson(m['revenue']) : null,
      payments: payments,
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Funnel
// ---------------------------------------------------------------------------

class AdminFunnelTrigger {
  const AdminFunnelTrigger({
    required this.trigger,
    this.shown = 0,
    this.purchases = 0,
    this.conversionRate = 0,
  });

  final String trigger;
  final int shown;
  final int purchases;
  final double conversionRate;

  factory AdminFunnelTrigger.fromJson(Map<String, dynamic> m) =>
      AdminFunnelTrigger(
        trigger: jString(m['trigger'], 'geen'),
        shown: jInt(m['shown']),
        purchases: jInt(m['purchases']),
        conversionRate: jDouble(m['conversionRate']),
      );
}

class AdminFunnel {
  const AdminFunnel({
    this.windowDays = 30,
    this.hostsStartedOne = 0,
    this.hostsReachedQuota = 0,
    this.hostsReachRate = 0,
    this.freeQuota = 0,
    this.paywallShown = 0,
    this.paywallPurchases = 0,
    this.paywallConversion = 0,
    this.byTrigger = const [],
    this.plansMonthly = 0,
    this.plansYearly = 0,
    this.plansLifetime = 0,
    this.nonMonthlyShare = 0,
    this.trialsStarted = 0,
    this.trialsConverted = 0,
    this.trialConversion = 0,
    this.quizzesCompleted = 0,
    this.firstQuizzesCompleted = 0,
    this.handoverClicks = 0,
    this.handoverShown = 0,
    this.handoverDismissals = 0,
    this.handoverCodeCopies = 0,
    this.handoverPerCompletion = 0,
    this.handoverBySurface = const {},
    this.retentionFree,
    this.retentionPremium,
  });

  final int windowDays;
  final int hostsStartedOne;
  final int hostsReachedQuota;
  final double hostsReachRate;
  final int freeQuota;
  final int paywallShown;
  final int paywallPurchases;
  final double paywallConversion;
  final List<AdminFunnelTrigger> byTrigger;
  final int plansMonthly;
  final int plansYearly;
  final int plansLifetime;
  final double nonMonthlyShare;
  final int trialsStarted;
  final int trialsConverted;
  final double trialConversion;
  final int quizzesCompleted;
  final int firstQuizzesCompleted;
  final int handoverClicks;
  final int handoverShown;
  final int handoverDismissals;
  final int handoverCodeCopies;
  final double handoverPerCompletion;
  final Map<String, int> handoverBySurface;
  final AdminRate? retentionFree;
  final AdminRate? retentionPremium;

  factory AdminFunnel.fromJson(Map<String, dynamic> json) {
    // The report may be nested under `report` or sent flat.
    final r = json['report'] is Map ? jMap(json['report']) : json;
    final hosts = jMap(r['hosts']);
    final paywall = jMap(r['paywall']);
    final plans = jMap(r['plans']);
    final trials = jMap(r['trials']);
    final activation = jMap(r['activation']);
    final handover = jMap(r['handover']);
    final retention = jMap(json['retention']);
    final surfaces = <String, int>{
      for (final m in jMapList(handover['bySurface']))
        jString(m['surface'], 'onbekend'): jInt(m['clicks']),
    };
    return AdminFunnel(
      windowDays: jInt(json['windowDays'] ?? r['windowDays'], 30),
      hostsStartedOne: jInt(hosts['startedOne']),
      hostsReachedQuota: jInt(hosts['reachedQuota']),
      hostsReachRate: jDouble(hosts['reachRate']),
      freeQuota: jInt(hosts['freeQuota']),
      paywallShown: jInt(paywall['shown']),
      paywallPurchases: jInt(paywall['purchases']),
      paywallConversion: jDouble(paywall['conversionRate']),
      byTrigger: jMapList(
        paywall['byTrigger'],
      ).map(AdminFunnelTrigger.fromJson).toList(),
      plansMonthly: jInt(plans['monthly']),
      plansYearly: jInt(plans['yearly']),
      plansLifetime: jInt(plans['lifetime']),
      nonMonthlyShare: jDouble(plans['nonMonthlyShare']),
      trialsStarted: jInt(trials['started']),
      trialsConverted: jInt(trials['converted']),
      trialConversion: jDouble(trials['conversionRate']),
      quizzesCompleted: jInt(activation['quizzesCompleted']),
      firstQuizzesCompleted: jInt(activation['firstQuizzesCompleted']),
      handoverClicks: jInt(handover['clicks']),
      handoverShown: jInt(handover['shown']),
      handoverDismissals: jInt(handover['dismissals']),
      handoverCodeCopies: jInt(handover['codeCopies']),
      handoverPerCompletion: jDouble(handover['perCompletion']),
      handoverBySurface: surfaces,
      retentionFree: retention['free'] is Map
          ? AdminRate.fromJson(retention['free'])
          : null,
      retentionPremium: retention['premium'] is Map
          ? AdminRate.fromJson(retention['premium'])
          : null,
    );
  }
}
