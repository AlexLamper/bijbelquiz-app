import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../auth/present/auth_controller.dart';
import '../domain/quiz_passage.dart';

/// One verse of a chapter.
class ChapterVerse {
  const ChapterVerse({required this.verse, required this.text});

  final int verse;
  final String text;
}

/// Fetches whole chapters for the "read the passage first" flow.
///
/// Goes through the website's `/api/bible/chapter`, which is the same door the
/// web reader uses: it holds the BijbelAPI key, sorts the verses, and caches
/// them for a day.
class BibleChapterRepository {
  BibleChapterRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ChapterVerse>> fetchChapter(QuizPassage passage) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '${AppConfig.baseUrl}/api/bible/chapter',
      queryParameters: {'book': passage.book, 'chapter': passage.chapter},
    );

    final raw = response.data?['verses'];
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map(
          (entry) => ChapterVerse(
            verse: (entry['verse'] as num?)?.toInt() ?? 0,
            text: entry['text']?.toString().trim() ?? '',
          ),
        )
        .where((verse) => verse.verse > 0 && verse.text.isNotEmpty)
        .toList();
  }
}

final bibleChapterRepositoryProvider = Provider<BibleChapterRepository>(
  (ref) => BibleChapterRepository(ref.watch(apiClientProvider)),
);

/// The chapter for one passage. Cached by Riverpod for the session, so stepping
/// back from the reader and starting again does not refetch.
final chapterVersesProvider = FutureProvider.family<List<ChapterVerse>, QuizPassage>(
  (ref, passage) => ref.watch(bibleChapterRepositoryProvider).fetchChapter(passage),
);
