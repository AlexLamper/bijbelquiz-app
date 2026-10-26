import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../core/notifications/streak_reminder.dart';
import 'purchase_service.dart';

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

/// A local notification shortly before a free trial turns into a paid
/// subscription.
///
/// On-device, like the streak reminder: RevenueCat already tells the phone
/// when the trial ends, so no server is needed. Scheduled only when the store
/// confirms the new entitlement really is a trial, and timed off the store's
/// own expiry date rather than our guess of it.
class TrialReminder {
  TrialReminder._();

  static final TrialReminder instance = TrialReminder._();

  static const int _notificationId = 4202;
  static const String _channelId = 'trial_reminder';

  // The plugin is a process-wide singleton; the streak reminder initialises
  // it at launch.
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Schedules the reminder when [info] shows a fresh Premium trial.
  ///
  /// Never throws: a refused permission or a missing expiry date simply means
  /// no reminder, and must not turn a successful purchase into an error.
  Future<void> scheduleIfTrial(CustomerInfo info) async {
    if (kIsWeb) return;

    try {
      final entitlement = info.entitlements.active[kRcPremiumEntitlement];
      if (entitlement == null || entitlement.periodType != PeriodType.trial) {
        return;
      }

      final rawEnd = entitlement.expirationDate;
      final trialEnd = rawEnd == null ? null : DateTime.tryParse(rawEnd);
      if (trialEnd == null) return;

      final fireAt = trialEnd.subtract(
        const Duration(days: kTrialReminderDaysBeforeEnd),
      );
      if (!fireAt.isAfter(DateTime.now().add(const Duration(hours: 1)))) {
        return;
      }

      await StreakReminder.instance.init();
      if (!await _requestPermission()) return;

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
      debugPrint('[TrialReminder] schedule failed: $error');
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
