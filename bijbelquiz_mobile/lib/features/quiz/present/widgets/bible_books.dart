import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// What the redesigned screens need to know about a Bible book: its place in
/// the canon (for ordering), which testament it belongs to (for the green /
/// lapis tint) and a short label for the small book tiles.
///
/// The server sends the book name as a Dutch string ("Daniël", "1 Samuël",
/// "Matteüs"), spelled after whichever translation the quiz was written from,
/// so lookups ignore case, spaces and diacritics and know the common variant
/// spellings.
class BibleBookInfo {
  const BibleBookInfo({
    required this.order,
    required this.abbreviation,
    required this.oldTestament,
  });

  /// 1..66 in canonical order; 999 for a name we do not recognise.
  final int order;
  final String abbreviation;

  /// Null when the book is unknown.
  final bool? oldTestament;
}

/// Tint used for a book, a quiz about it, or a card in its testament.
class BookTint {
  const BookTint(this.background, this.foreground, this.mutedText);

  final Color background;
  final Color foreground;
  final Color mutedText;

  static const BookTint oldTestament = BookTint(
    AppTheme.positiveTint,
    AppTheme.positive,
    AppTheme.positiveMutedText,
  );
  static const BookTint newTestament = BookTint(
    AppTheme.lapisTint,
    AppTheme.lapis,
    AppTheme.lapisMutedText,
  );
  static const BookTint general = BookTint(
    AppTheme.goldTint,
    AppTheme.goldText,
    AppTheme.goldText,
  );
}

class BibleBooks {
  const BibleBooks._();

  static const int otCount = 39;

  // (normalised key, abbreviation) in canonical order. Variant spellings share
  // an order number through [_aliases].
  static const List<(String, String)> _canon = [
    ('genesis', 'Gen'),
    ('exodus', 'Ex'),
    ('leviticus', 'Lev'),
    ('numeri', 'Num'),
    ('deuteronomium', 'Deut'),
    ('jozua', 'Joz'),
    ('rechters', 'Re'),
    ('ruth', 'Ruth'),
    ('1samuel', '1Sam'),
    ('2samuel', '2Sam'),
    ('1koningen', '1Kon'),
    ('2koningen', '2Kon'),
    ('1kronieken', '1Kr'),
    ('2kronieken', '2Kr'),
    ('ezra', 'Ezra'),
    ('nehemia', 'Neh'),
    ('ester', 'Est'),
    ('job', 'Job'),
    ('psalmen', 'Ps'),
    ('spreuken', 'Spr'),
    ('prediker', 'Pred'),
    ('hooglied', 'Hgl'),
    ('jesaja', 'Jes'),
    ('jeremia', 'Jer'),
    ('klaagliederen', 'Kla'),
    ('ezechiel', 'Ez'),
    ('daniel', 'Dan'),
    ('hosea', 'Hos'),
    ('joel', 'Joël'),
    ('amos', 'Am'),
    ('obadja', 'Ob'),
    ('jona', 'Jona'),
    ('micha', 'Mi'),
    ('nahum', 'Nah'),
    ('habakuk', 'Hab'),
    ('sefanja', 'Sef'),
    ('haggai', 'Hag'),
    ('zacharia', 'Zach'),
    ('maleachi', 'Mal'),
    // New Testament.
    ('matteus', 'Mat'),
    ('marcus', 'Mar'),
    ('lucas', 'Luc'),
    ('johannes', 'Joh'),
    ('handelingen', 'Hand'),
    ('romeinen', 'Rom'),
    ('1korintiers', '1Kor'),
    ('2korintiers', '2Kor'),
    ('galaten', 'Gal'),
    ('efeziers', 'Ef'),
    ('filippenzen', 'Fil'),
    ('kolossenzen', 'Kol'),
    ('1tessalonicenzen', '1Tes'),
    ('2tessalonicenzen', '2Tes'),
    ('1timoteus', '1Tim'),
    ('2timoteus', '2Tim'),
    ('titus', 'Tit'),
    ('filemon', 'Flm'),
    ('hebreeen', 'Heb'),
    ('jakobus', 'Jak'),
    ('1petrus', '1Pet'),
    ('2petrus', '2Pet'),
    ('1johannes', '1Joh'),
    ('2johannes', '2Joh'),
    ('3johannes', '3Joh'),
    ('judas', 'Jud'),
    ('openbaring', 'Opb'),
  ];

  static const Map<String, String> _aliases = {
    'richteren': 'rechters',
    'richters': 'rechters',
    'esther': 'ester',
    'psalm': 'psalmen',
    'psalms': 'psalmen',
    'mattheus': 'matteus',
    'markus': 'marcus',
    'lukas': 'lucas',
    'handelingenderapostelen': 'handelingen',
    '1korinthiers': '1korintiers',
    '2korinthiers': '2korintiers',
    '1korinthe': '1korintiers',
    '2korinthe': '2korintiers',
    '1thessalonicenzen': '1tessalonicenzen',
    '2thessalonicenzen': '2tessalonicenzen',
    '1timotheus': '1timoteus',
    '2timotheus': '2timoteus',
    'hebreen': 'hebreeen',
    'jacobus': 'jakobus',
    'openbaringen': 'openbaring',
  };

  static final Map<String, int> _index = {
    for (var i = 0; i < _canon.length; i++) _canon[i].$1: i,
  };

  static final RegExp _keep = RegExp(r'[a-z0-9]');

  static String _normalise(String raw) {
    const from = 'àáâäãèéêëìíîïòóôöõùúûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    final buffer = StringBuffer();
    for (final rune in raw.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      final i = from.indexOf(char);
      final mapped = i >= 0 ? to[i] : char;
      if (_keep.hasMatch(mapped)) buffer.write(mapped);
    }
    return buffer.toString();
  }

  static BibleBookInfo info(String rawName) {
    final key = _normalise(rawName);
    final resolved = _aliases[key] ?? key;
    final i = _index[resolved];
    if (i == null) {
      final trimmed = rawName.trim();
      return BibleBookInfo(
        order: 999,
        abbreviation: trimmed.length <= 4 ? trimmed : trimmed.substring(0, 3),
        oldTestament: null,
      );
    }
    return BibleBookInfo(
      order: i + 1,
      abbreviation: _canon[i].$2,
      oldTestament: i < otCount,
    );
  }

  /// Green for the Old Testament, lapis for the New (and for unknown names).
  static BookTint tintFor(String? bookName) {
    if (bookName == null || bookName.trim().isEmpty) {
      return BookTint.newTestament;
    }
    final ot = info(bookName).oldTestament;
    return ot == true ? BookTint.oldTestament : BookTint.newTestament;
  }
}
