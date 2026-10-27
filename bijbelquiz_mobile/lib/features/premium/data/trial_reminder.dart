import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart' show PeriodUnit;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/notifications/streak_reminder.dart';
import '../domain/premium_plan.dart';

/// How many days before a free trial ends the player is reminded.
///
/// The paywall promises this reminder ("Herinnering op dag 5" for a 7-day
/// trial), so the number lives here, next to the code that keeps the promise.
const int kTrialReminderDaysBeforeEnd = 2;

/// Days into a trial of [trialDays] days on which the reminder fires, or null
/// when the trial is too short to remind anybody before it ends.
int? trialReminderDay(int trialDays) {
  final day = trialDays - kTrialReminderDaysBeforeEnd;
  return day >= 1 ? day : null;
}

/// Length of a store trial in days, for the reminder line on the paywall.
int trialLengthInDays(TrialOffer trial) {
  final perUnit = switch (trial.periodUnit) {
    PeriodUnit.day => 1,
    PeriodUnit.week => 7,
    PeriodUnit.month => 30,
    PeriodUnit.year => 365,
    PeriodUnit.unknown => 1,
  };
  return trial.periodCount * perUnit;
}

/// When the reminder for a trial ending at [trialEnd] fires, or null when no
/// reminder should be scheduled (not a trial, cancelled, or too late).
DateTime? trialReminderFireAt(StoreCustomer customer, DateTime now) {
  final trialEnd = customer.expiresAt;
  if (!customer.premiumActive ||
      !customer.isTrial ||
      !customer.willRenew ||
      trialEnd == null) {
    return null;
  }
  final fireAt = trialEnd.subtract(
    const Duration(days: kTrialReminderDaysBeforeEnd),
  );
  return fireAt.isAfter(now.add(const Duration(hours: 1))) ? fireAt : null;
}

/// Keeps the trial reminder in step with the store. A seam for tests.
abstract class TrialReminderScheduler {
  /// Schedule, move or cancel the reminder for [customer]. Never throws.
  Future<void> sync(StoreCustomer customer, {bool requestPermission = false});
}

final trialReminderProvider = Provider<TrialReminderScheduler>(
  (ref) => TrialReminder.instance,
);

/// A local notification shortly before a free trial turns into a paid
/// subscription.
///
/// On-device, like the streak reminder: RevenueCat already tells the phone
/// when the trial ends, so no server is needed. Scheduled only when the store
/// confirms the new entitlement really is a trial, and timed off the store's
/// own expiry date rather than our guess of it.
class TrialReminder implements TrialReminderScheduler {
  TrialReminder._();

  static final TrialReminder instance = TrialReminder._();

  static const int _notificationId = 4202;
  static const String _channelId = 'trial_reminder';

  // The plugin is a process-wide singleton; the streak reminder initialises
  // it at launch.
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Schedules the reminder while [customer] is in a trial that will renew,
  /// and cancels it once the trial is cancelled, converted or gone.
  ///
  /// [requestPermission] is true right after a purchase, the one moment the
  /// permission prompt makes sense; passive updates only schedule when the
  /// player already allowed notifications.
  ///
  /// Never throws: a refused permission or a missing expiry date simply means
  /// no reminder, and must not turn a successful purchase into an error.
  @override
  Future<void> sync(
    StoreCustomer customer, {
    bool requestPermission = false,
  }) async {
    if (kIsWeb) return;

    try {
      final fireAt = trialReminderFireAt(customer, DateTime.now());
      await StreakReminder.instance.init();
      if (fireAt == null) {
        await _plugin.cancel(_notificationId);
        return;
      }

      if (requestPermission && !await _requestPermission()) return;

      await _plugin.zonedSchedule(
        _notificationId,
        'Je proefperiode loopt bijna af',
        'Over $kTrialReminderDaysBeforeEnd dagen gaat je BijbelQuiz Premium '
            'in. Wil je niet verder? Zeg dan op in je store-instellingen.',
        tz.TZDateTime.from(fireAt.toUtc(), tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Herinnering proefperiode',
            channelDescription:
                'Een herinnering voordat je gratis proefperiode afloopt.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (error) {
      debugPrint('[TrialReminder] sync failed: $error');
    }
  }

  Future<bool> _requestPermission() async {
    try {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }

      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? true;
      }
    } catch (error) {
      debugPrint('[TrialReminder] permission request failed: $error');
    }
    return false;
  }
}
