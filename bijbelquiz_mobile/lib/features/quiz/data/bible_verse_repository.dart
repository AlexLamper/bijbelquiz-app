import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../auth/present/auth_controller.dart';

/// One looked-up reference: the verse text, plus the reference as the server
/// normalised it ("Gen. 2:2-3" comes back as "Genesis 2:2-3").
class BibleVerse {
  const BibleVerse({
    required this.text,
    required this.reference,
    required this.version,
  });

  final String text;
  final String reference;
  final String version;
}

/// Resolves a written reference to the verse text behind it.
///
/// Goes through the website's `/api/bible/verse`, the same door the web quiz
/// player's reference block uses: it holds the BijbelAPI key, parses the Dutch
/// book names and abbreviations, and caches the answer for a day. Parsing
/// references in the app would mean a second copy of that book table.
class BibleVerseRepository {
  BibleVerseRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<BibleVerse?> fetchVerse(
    String reference, {
    String version = 'sv',
  }) async {
    final trimmed = reference.trim();
    if (trimmed.isEmpty || trimmed == '-') return null;

    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '${AppConfig.baseUrl}/api/bible/verse',
      queryParameters: {'ref': trimmed, 'version': version},
    );

    final text = response.data?['text']?.toString().trim() ?? '';
    if (text.isEmpty) return null;

    final resolved = response.data?['reference']?.toString().trim() ?? '';

    return BibleVerse(
      text: text,
      reference: resolved.isEmpty ? trimmed : resolved,
      version: response.data?['version']?.toString() ?? version,
    );
  }
}

final bibleVerseRepositoryProvider = Provider<BibleVerseRepository>(
  (ref) => BibleVerseRepository(ref.watch(apiClientProvider)),
);

/// The verse text for one reference, cached by Riverpod for the session.
///
/// Stepping back to a question whose passage was already opened, or meeting the
/// same reference twice in one quiz, costs nothing the second time.
final bibleVerseProvider = FutureProvider.family<BibleVerse?, String>(
  (ref, reference) =>
      ref.watch(bibleVerseRepositoryProvider).fetchVerse(reference),
);
