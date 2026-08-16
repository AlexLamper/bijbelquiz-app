import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// The evening streak reminder.
///
/// On-device only. There is no Firebase project, no APNs certificate and no
/// server involved: the phone already knows the streak and the clock, so
/// pushing this from a backend would be infrastructure bought for nothing.
///
/// Three rules keep it from becoming nagging:
///  - Off by default. Turned on from the profile screen, never by us.
///  - Only asked for after a first finished quiz, so the permission prompt
///    lands on somebody who has seen what the app is.
///  - Only fires at a streak of two or more. A player with nothing to lose does
///    not need to be told they are about to lose it.
class StreakReminder {
  StreakReminder._();

  static final StreakReminder instance = StreakReminder._();

  /// One id, reused. Scheduling again replaces the pending notification, which
  /// is what keeps this idempotent across refreshes.
  static const int _notificationId = 4201;

  static const String _enabledKey = 'streak_reminder_enabled';
  static const String _offeredKey = 'streak_reminder_offered';
  static const String _channelId = 'streak_reminder';

  /// The app's audience is Dutch, and a reminder that arrives at 19:00 local
  /// time everywhere is the point of pinning the zone rather than using the
  /// device's.
  static const String _timezoneName = 'Europe/Amsterdam';

  /// After dinner, before the evening is over. Late enough that most people
  /// have not played yet, early enough to still act on it.
  static const int _hour = 19;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _initialized = false;
  tz.Location? _location;

  /// Prepares the plugin and the timezone database.
  ///
  /// Cheap and safe to call more than once. Never throws: a device that
  /// refuses notifications outright must not take the app down with it.
  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    try {
      tzdata.initializeTimeZones();
      _location = tz.getLocation(_timezoneName);

      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Permission is asked for later, on our own terms, rather than at
          // first launch where it reads as a shakedown.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );

      _initialized = true;
    } catch (error) {
      debugPrint('[StreakReminder] init failed: $error');
    }
  }

  Future<bool> isEnabled() async {
    try {
      return await _storage.read(key: _enabledKey) == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Whether the in-app offer has already been made.
  ///
  /// Asked exactly once, after a finished quiz. A second ask from something
  /// the user already declined is how an app earns its notifications being
  /// switched off at the OS level.
  Future<bool> hasBeenOffered() async {
    try {
      return await _storage.read(key: _offeredKey) == 'true';
    } catch (_) {
      // Unreadable storage is treated as "already asked": a repeated prompt is
      // worse than a missed one.
      return true;
    }
  }

  Future<void> markOffered() async {
    try {
      await _storage.write(key: _offeredKey, value: 'true');
    } catch (error) {
      debugPrint('[StreakReminder] could not persist offer state: $error');
    }
  }

  /// Turns the reminder on or off.
  ///
  /// Switching it on is the moment we ask for permission - the user just
  /// asked for the thing the permission is for, which is the only time a
  /// prompt is worth spending.
  ///
  /// Returns whether it is actually on afterwards: a denied permission means
  /// the switch goes back to off rather than lying to the user.
  Future<bool> setEnabled(bool enabled, {int streak = 0, DateTime? lastPlayedAt}) async {
    await init();

    if (!enabled) {
      await _write(false);
      await cancel();
      return false;
    }

    final granted = await _requestPermission();
    if (!granted) {
      await _write(false);
      return false;
    }

    await _write(true);
    await sync(streak: streak, lastPlayedAt: lastPlayedAt);
    return true;
  }

  /// Brings the scheduled reminder in line with the current profile.
  ///
  /// The single entry point: call it after a finished quiz and after any
  /// profile refresh, and the pending notification is always correct. Cheaper
  /// than reasoning about which events should cancel and which should
  /// reschedule.
  Future<void> sync({required int streak, DateTime? lastPlayedAt}) async {
    if (kIsWeb) return;
    await init();
    if (!_initialized) return;

    if (!await isEnabled()) {
      await cancel();
      return;
    }

    // A streak of 0 or 1 has nothing at stake tonight.
    if (streak < 2) {
      await cancel();
      return;
    }

    final when = _nextFireTime(lastPlayedAt);

    try {
      await _plugin.zonedSchedule(
        _notificationId,
        'Je reeks staat op het spel',
        _body(streak),
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Reeksherinnering',
            channelDescription:
                'Een herinnering op de avond dat je reeks dreigt te verlopen.',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        // Inexact on purpose. An exact alarm needs SCHEDULE_EXACT_ALARM, which
        // Google Play only grants to alarm clocks and calendars, and nobody
        // cares whether this lands at 19:00 or 19:07.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (error) {
      debugPrint('[StreakReminder] schedule failed: $error');
    }
  }

  Future<void> cancel() async {
    if (kIsWeb) return;
    await init();
    if (!_initialized) return;

    try {
      await _plugin.cancel(_notificationId);
    } catch (error) {
      debugPrint('[StreakReminder] cancel failed: $error');
    }
  }

  /// The copy. Names the number, because "je reeks" alone is abstract and the
  /// number is the whole reason anybody cares.
  String _body(int streak) {
    return 'Je reeks van $streak dagen loopt vanavond af. '
        'Eén quiz is genoeg om hem te houden.';
  }

  /// The next 19:00 that is not already covered.
  ///
  /// Played today, or past 19:00 already, means tomorrow. Anything else means
  /// tonight.
  tz.TZDateTime _nextFireTime(DateTime? lastPlayedAt) {
    final location = _location!;
    final now = tz.TZDateTime.now(location);

    var target = tz.TZDateTime(location, now.year, now.month, now.day, _hour);

    final playedToday =
        lastPlayedAt != null && _isSameDay(tz.TZDateTime.from(lastPlayedAt, location), now);

    if (playedToday || !target.isAfter(now)) {
      target = target.add(const Duration(days: 1));
    }

    return target;
  }

  bool _isSameDay(tz.TZDateTime a, tz.TZDateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
        // Returns null below Android 13, where the permission does not exist
        // and notifications are allowed by default.
        return await android.requestNotificationsPermission() ?? true;
      }
    } catch (error) {
      debugPrint('[StreakReminder] permission request failed: $error');
    }

    return false;
  }

  Future<void> _write(bool enabled) async {
    try {
      await _storage.write(key: _enabledKey, value: enabled ? 'true' : 'false');
    } catch (error) {
      debugPrint('[StreakReminder] could not persist setting: $error');
    }
  }
}

/// Whether the reminder is currently on. Read by the profile toggle.
final streakReminderEnabledProvider = FutureProvider<bool>((ref) async {
  return StreakReminder.instance.isEnabled();
});
