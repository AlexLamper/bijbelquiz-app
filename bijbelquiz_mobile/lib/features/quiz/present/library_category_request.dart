import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A category the Quizzen tab should open on.
///
/// The Home "Kies een onderwerp" tiles switch to the Quizzen tab with a filter
/// already chosen. `/quizzes` takes no parameters, so the choice is handed over
/// here: Home sets it, the library applies it once and clears it.
class LibraryCategoryRequest extends Notifier<String?> {
  @override
  String? build() => null;

  void request(String categoryId) => state = categoryId;

  void clear() => state = null;
}

final libraryCategoryRequestProvider =
    NotifierProvider<LibraryCategoryRequest, String?>(
      LibraryCategoryRequest.new,
    );
