import 'package:flutter_test/flutter_test.dart';

import 'package:bijbelquiz_mobile/core/config/app_config.dart';
import 'package:bijbelquiz_mobile/core/config/brand.dart';

// Default build (no APP_BRAND): BijbelQuiz must behave exactly as before.
void main() {
  test('default build is BijbelQuiz in Dutch', () {
    expect(Brand.current, AppBrand.bijbelquiz);
    expect(Brand.language, 'nl');
    expect(Brand.siteUrl, 'https://www.bijbelquiz.com');
    expect(AppConfig.privacyPolicyUrl, 'https://www.bijbelquiz.com/privacy-policy');
  });

  test('BijbelQuiz invite text and link are unchanged', () {
    AppConfig.setCustomApiBaseUrl('https://www.bijbelquiz.com/api/mobile');
    addTearDown(() => AppConfig.setCustomApiBaseUrl(null));
    expect(
      AppConfig.roomInviteMessage('ab12', 'Genesis 1'),
      'Doe je mee met Genesis 1 op BijbelQuiz?\n\n'
      'https://www.bijbelquiz.com/samen-spelen/AB12/lobby?bron=uitnodiging\n\n'
      'Of vul de code in: AB12',
    );
    expect(AppConfig.roomInviteMessage('ab12', ' '), startsWith('Doe je mee met een bijbelquiz op BijbelQuiz?'));
  });

  test('base URL keeps a language prefix', () {
    AppConfig.setCustomApiBaseUrl('https://biblequizzes.app/de/api/mobile');
    addTearDown(() => AppConfig.setCustomApiBaseUrl(null));
    expect(AppConfig.baseUrl, 'https://biblequizzes.app/de');
  });
}
