import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';
import 'brand.dart';

/// Environment-based configuration for API endpoints
/// Automatically switches between development and production based on build mode
class AppConfig {
  // Production API endpoints
  // BijbelQuiz: www.bijbelquiz.com. Bible Quizzes: the site of the app's
  // language (biblequizzes.app, biblequizzes.app/de, ...), each with its own
  // accounts, so the language decides which API the app talks to.
  static String get _productionBaseUrl => '${Brand.siteUrl}/api/mobile';

  // Development API endpoints (localhost)
  static const String _developmentBaseUrl = 'http://localhost:3000/api/mobile';

  // Optional dart-define overrides:
  // --dart-define=API_BASE_URL=https://www.bijbelquiz.com/api/mobile
  static const String _apiBaseUrlFromDefine = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  // Optional convenience toggle:
  // --dart-define=USE_PRODUCTION_API=true
  static const bool _useProductionApiFromDefine = bool.fromEnvironment(
    'USE_PRODUCTION_API',
    defaultValue: false,
  );

  // Legal links used in subscription and account flows.
  // Override per environment via dart-define if needed.
  static const String _privacyPolicyUrlFromDefine = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: '',
  );
  static String get privacyPolicyUrl => _privacyPolicyUrlFromDefine.isNotEmpty
      ? _privacyPolicyUrlFromDefine
      : '${Brand.siteUrl}/privacy-policy';
  static const String termsOfUseUrl = String.fromEnvironment(
    'TERMS_OF_USE_URL',
    defaultValue:
        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
  );

  /// Get the appropriate API base URL based on build mode
  /// Debug builds use localhost for local development
  /// Release builds use production URL
  static String get apiBaseUrl {
    if (_apiBaseUrlFromDefine.isNotEmpty) {
      return _apiBaseUrlFromDefine;
    }

    if (kDebugMode) {
      if (_useProductionApiFromDefine) {
        return _productionBaseUrl;
      }

      // Development mode - use localhost by default
      return _developmentBaseUrl;
    } else {
      // Production/Release mode - use production URL
      return _productionBaseUrl;
    }
  }

  /// Get the base URL without /api/mobile suffix
  /// Used for constructing image URLs and other resources
  static String get baseUrl {
    final apiUri = Uri.parse(effectiveApiBaseUrl);
    final authority = apiUri.hasPort
        ? '${apiUri.host}:${apiUri.port}'
        : apiUri.host;
    // Bible Quizzes languages live under a path prefix (/de); keep it, or
    // images and links would land on the English site.
    final path = apiUri.path.endsWith('/api/mobile')
        ? apiUri.path.substring(0, apiUri.path.length - '/api/mobile'.length)
        : '';
    return '${apiUri.scheme}://$authority$path';
  }

  /// Returns whether app is in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Returns whether app is in production/release mode
  static bool get isProduction => !kDebugMode;

  /// For testing purposes: override the API URL
  static String? _customApiBaseUrl;

  /// Set a custom API base URL (useful for testing against different servers)
  static void setCustomApiBaseUrl(String? url) {
    _customApiBaseUrl = url;
  }

  /// Get the actual API URL to use (respects custom override)
  static String get effectiveApiBaseUrl => _customApiBaseUrl ?? apiBaseUrl;

  /// Marks a join that arrived through a shared link, for the funnel.
  ///
  /// Mirrors `INVITE_SOURCE_PARAM` / `INVITE_SOURCE_VALUE` in
  /// `src/lib/multiplayer/invite.ts` on the website. The server reads these off
  /// the join request, so the spellings have to match exactly.
  static const String inviteSourceParam = 'bron';
  static const String inviteSourceValue = 'uitnodiging';

  /// The URL to share for a room.
  ///
  /// Points at the web lobby rather than the app: a link that only works for
  /// people who already have the app installed is useless as an invite, and
  /// the website hands them a download prompt. Once the deep-link files are
  /// hosted this same URL will open the app for those who do have it.
  static String roomInviteUrl(String roomCode) {
    final code = roomCode.trim().toUpperCase();
    // The website's localized path (see src/config/route-map.ts there).
    final lobby = Brand.isBijbelQuiz ? 'samen-spelen' : 'play-together';
    return '$baseUrl/$lobby/$code/lobby'
        '?$inviteSourceParam=$inviteSourceValue';
  }

  /// The message that goes with it.
  ///
  /// Kept line for line in step with `buildRoomInviteMessage` on the website so
  /// an invite reads the same whichever half of the product sent it. The code
  /// stays visible for clients that strip links.
  static String roomInviteMessage(String roomCode, String quizTitle) {
    final code = roomCode.trim().toUpperCase();
    final l = lookupAppLocalizations(Brand.locale);
    final title = quizTitle.trim().isEmpty ? l.inviteFallbackTitle : quizTitle.trim();
    // BijbelQuiz keeps its own spelling of the name in the invite.
    final brand = Brand.isBijbelQuiz ? 'BijbelQuiz' : Brand.name;

    return [
      l.inviteJoin(title, brand),
      '',
      roomInviteUrl(code),
      '',
      l.inviteCode(code),
    ].join('\n');
  }
}
