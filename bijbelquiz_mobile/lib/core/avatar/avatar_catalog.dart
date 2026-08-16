/// The player mascot.
///
/// A Dart port of `src/lib/avatar.ts` in the website repository. Both files
/// build the same list of primitives from the same four catalogue ids, so a
/// player's creature is identical on the site and in the app. Change one, change
/// the other.
///
/// Drawing locally rather than downloading an image matters here: the
/// leaderboard shows a hundred of them at once, and they have to appear
/// instantly, offline, at any size.
library;

import 'dart:math' as math;

class AvatarConfig {
  const AvatarConfig({
    required this.character,
    required this.color,
    required this.background,
    required this.accessory,
  });

  final String character;
  final String color;
  final String background;
  final String accessory;

  static const AvatarConfig fallback = AvatarConfig(
    character: 'lam',
    color: 'zand',
    background: 'perkament',
    accessory: 'geen',
  );

  /// Accepts anything the API might send, including a partly filled or
  /// entirely absent object, and always yields a drawable config.
  factory AvatarConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return fallback;

    String pick(List<String> ids, dynamic value, String fallbackId) {
      final text = value?.toString();
      return ids.contains(text) ? text! : fallbackId;
    }

    return AvatarConfig(
      character: pick(
        avatarCharacters.map((option) => option.id).toList(),
        json['character'],
        fallback.character,
      ),
      color: pick(
        avatarColors.map((option) => option.id).toList(),
        json['color'],
        fallback.color,
      ),
      background: pick(
        avatarBackgrounds.map((option) => option.id).toList(),
        json['background'],
        fallback.background,
      ),
      accessory: pick(
        avatarAccessories.map((option) => option.id).toList(),
        json['accessory'],
        fallback.accessory,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'character': character,
    'color': color,
    'background': background,
    'accessory': accessory,
  };

  AvatarConfig copyWith({
    String? character,
    String? color,
    String? background,
    String? accessory,
  }) {
    return AvatarConfig(
      character: character ?? this.character,
      color: color ?? this.color,
      background: background ?? this.background,
      accessory: accessory ?? this.accessory,
    );
  }

  /// A stable creature for an account that has never opened the customiser.
  ///
  /// Mirrors `avatarFromSeed` on the server, so a player who has not chosen
  /// yet sees the same face in the app that the website draws for them.
  factory AvatarConfig.fromSeed(String seed) {
    var hash = 0;
    for (var index = 0; index < seed.length; index += 1) {
      hash = (hash * 31 + seed.codeUnitAt(index)) & 0xFFFFFFFF;
    }

    return AvatarConfig(
      character: avatarCharacters[hash % avatarCharacters.length].id,
      color: avatarColors[(hash ~/ 7) % avatarColors.length].id,
      background: avatarBackgrounds[(hash ~/ 53) % avatarBackgrounds.length].id,
      accessory: 'geen',
    );
  }

  /// The stored config when the server sent one, a seeded one otherwise.
  static AvatarConfig resolve(Map<String, dynamic>? stored, String seed) {
    if (stored != null && stored['character'] != null) {
      return AvatarConfig.fromJson(stored);
    }
    return AvatarConfig.fromSeed(seed.isEmpty ? 'bijbelquiz' : seed);
  }

  @override
  bool operator ==(Object other) =>
      other is AvatarConfig &&
      other.character == character &&
      other.color == color &&
      other.background == background &&
      other.accessory == accessory;

  @override
  int get hashCode => Object.hash(character, color, background, accessory);
}

class AvatarOption {
  const AvatarOption(this.id, this.label);
  final String id;
  final String label;
}

class AvatarColorOption extends AvatarOption {
  const AvatarColorOption(
    super.id,
    super.label, {
    required this.base,
    required this.shade,
    required this.light,
  });

  final String base;
  final String shade;
  final String light;
}

class AvatarBackgroundOption extends AvatarOption {
  const AvatarBackgroundOption(super.id, super.label, {required this.fill});
  final String fill;
}

const List<AvatarOption> avatarCharacters = <AvatarOption>[
  AvatarOption('lam', 'Lam'),
  AvatarOption('leeuw', 'Leeuw'),
  AvatarOption('duif', 'Duif'),
  AvatarOption('uil', 'Uil'),
  AvatarOption('hert', 'Hert'),
  AvatarOption('os', 'Os'),
];

const List<AvatarColorOption> avatarColors = <AvatarColorOption>[
  AvatarColorOption(
    'zand',
    'Zand',
    base: '#E2C48D',
    shade: '#C4A268',
    light: '#F2E3C6',
  ),
  AvatarColorOption(
    'lapis',
    'Lapis',
    base: '#6A87C4',
    shade: '#4C68A2',
    light: '#CBD8EE',
  ),
  AvatarColorOption(
    'klei',
    'Klei',
    base: '#CE8163',
    shade: '#AC6446',
    light: '#F0CDBD',
  ),
  AvatarColorOption(
    'olijf',
    'Olijf',
    base: '#7E9A6B',
    shade: '#5F7A4E',
    light: '#D3E0C9',
  ),
  AvatarColorOption(
    'roos',
    'Roos',
    base: '#D18BA0',
    shade: '#B06B81',
    light: '#F1D3DC',
  ),
  AvatarColorOption(
    'leisteen',
    'Leisteen',
    base: '#8A93A6',
    shade: '#6A7386',
    light: '#D5DAE3',
  ),
];

const List<AvatarBackgroundOption> avatarBackgrounds =
    <AvatarBackgroundOption>[
      AvatarBackgroundOption('perkament', 'Perkament', fill: '#F1EFE9'),
      AvatarBackgroundOption('hemel', 'Hemel', fill: '#DCE6F5'),
      AvatarBackgroundOption('salie', 'Salie', fill: '#DFE9DC'),
      AvatarBackgroundOption('zonsopgang', 'Zonsopgang', fill: '#FAE3D2'),
      AvatarBackgroundOption('nacht', 'Nacht', fill: '#2A3242'),
      AvatarBackgroundOption('blos', 'Blos', fill: '#F6E0E6'),
    ];

const List<AvatarOption> avatarAccessories = <AvatarOption>[
  AvatarOption('geen', 'Geen'),
  AvatarOption('bril', 'Bril'),
  AvatarOption('pet', 'Pet'),
  AvatarOption('sjaal', 'Sjaal'),
  AvatarOption('kroon', 'Kroon'),
];

const String _ink = '#1B1A18';
const String _cream = '#F7F3EA';
const String _beak = '#E0A24B';
const String _gold = '#D9A441';
const String _cap = '#35548C';
const String _scarf = '#A04A2F';

AvatarColorOption _ramp(String id) {
  return avatarColors.firstWhere(
    (option) => option.id == id,
    orElse: () => avatarColors.first,
  );
}

String avatarBackgroundFill(String id) {
  return avatarBackgrounds
      .firstWhere(
        (option) => option.id == id,
        orElse: () => avatarBackgrounds.first,
      )
      .fill;
}

String describeAvatar(AvatarConfig config) {
  final character = avatarCharacters
      .firstWhere(
        (option) => option.id == config.character,
        orElse: () => avatarCharacters.first,
      )
      .label;

  if (config.accessory == 'geen') return character;

  final accessory = avatarAccessories
      .firstWhere(
        (option) => option.id == config.accessory,
        orElse: () => avatarAccessories.first,
      )
      .label
      .toLowerCase();

  return '$character met $accessory';
}

/// Trim the trailing zeros a raw `toString()` leaves on doubles, so the SVG
/// stays compact and byte-identical to what the TypeScript side emits.
String _n(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value
      .toStringAsFixed(3)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
}

/// Head centre and radii, shared by every species so faces always line up.
const double _headCx = 50;
const double _headCy = 56;
const double _headRx = 26;
const double _headRy = 24;

class _Svg {
  final StringBuffer _buffer = StringBuffer();

  void circle(double cx, double cy, double r, String fill) {
    _buffer.write(
      '<circle cx="${_n(cx)}" cy="${_n(cy)}" r="${_n(r)}" fill="$fill"/>',
    );
  }

  void ellipse(
    double cx,
    double cy,
    double rx,
    double ry,
    String fill, {
    double rotate = 0,
  }) {
    final transform = rotate == 0
        ? ''
        : ' transform="rotate(${_n(rotate)} ${_n(cx)} ${_n(cy)})"';
    _buffer.write(
      '<ellipse cx="${_n(cx)}" cy="${_n(cy)}" rx="${_n(rx)}" ry="${_n(ry)}" '
      'fill="$fill"$transform/>',
    );
  }

  void rect(
    double x,
    double y,
    double width,
    double height,
    double rx,
    String fill, {
    double rotate = 0,
  }) {
    final transform = rotate == 0
        ? ''
        : ' transform="rotate(${_n(rotate)} ${_n(x + width / 2)} '
              '${_n(y + height / 2)})"';
    _buffer.write(
      '<rect x="${_n(x)}" y="${_n(y)}" width="${_n(width)}" '
      'height="${_n(height)}" rx="${_n(rx)}" fill="$fill"$transform/>',
    );
  }

  void path(String d, {String? fill, String? stroke, double strokeWidth = 0}) {
    final strokeAttrs = stroke == null
        ? ''
        : ' stroke="$stroke" stroke-width="${_n(strokeWidth)}" '
              'stroke-linecap="round" stroke-linejoin="round"';
    _buffer.write('<path d="$d" fill="${fill ?? 'none'}"$strokeAttrs/>');
  }

  void ring(double cx, double cy, double r, String stroke, double strokeWidth) {
    _buffer.write(
      '<circle cx="${_n(cx)}" cy="${_n(cy)}" r="${_n(r)}" fill="none" '
      'stroke="$stroke" stroke-width="${_n(strokeWidth)}"/>',
    );
  }

  @override
  String toString() => _buffer.toString();
}

void _eyes(_Svg svg, {double offsetY = 0, double radius = 4.4}) {
  final y = 52 + offsetY;
  svg.circle(40.5, y, radius, _cream);
  svg.circle(59.5, y, radius, _cream);
  svg.circle(41.4, y + 0.4, radius * 0.55, _ink);
  svg.circle(60.4, y + 0.4, radius * 0.55, _ink);
  svg.circle(39.9, y - 1.1, radius * 0.2, _cream);
  svg.circle(58.9, y - 1.1, radius * 0.2, _cream);
}

void _smile(_Svg svg, double y) {
  svg.path(
    'M44 ${_n(y)} Q50 ${_n(y + 4.5)} 56 ${_n(y)}',
    stroke: _ink,
    strokeWidth: 2,
  );
}

/// The complete `<svg>` document for one mascot.
///
/// Everything is clipped to the backdrop circle, so a crown or a pair of
/// antlers reaching past the edge is trimmed rather than overlapping whatever
/// sits next to the avatar.
String buildAvatarSvg(AvatarConfig config) {
  final ramp = _ramp(config.color);
  final base = ramp.base;
  final shade = ramp.shade;
  final light = ramp.light;

  final svg = _Svg();
  svg.rect(0, 0, 100, 100, 50, avatarBackgroundFill(config.background));

  switch (config.character) {
    case 'leeuw':
      for (var index = 0; index < 12; index += 1) {
        final angle = (math.pi * 2 * index) / 12;
        svg.circle(
          50 + math.cos(angle) * 29,
          56 + math.sin(angle) * 27,
          9.5,
          shade,
        );
      }
      svg.circle(31, 39, 6.5, base);
      svg.circle(69, 39, 6.5, base);
      svg.ellipse(_headCx, _headCy, _headRx, _headRy, base);
      svg.ellipse(50, 65, 12, 8.5, light);
      _eyes(svg);
      svg.path('M46.5 61.5 L53.5 61.5 L50 65.5 Z', fill: _ink);
      _smile(svg, 67);
      break;

    case 'duif':
      svg.ellipse(19, 62, 10, 17, shade, rotate: -22);
      svg.ellipse(81, 62, 10, 17, shade, rotate: 22);
      svg.circle(44, 30, 4, light);
      svg.circle(52, 27, 4.5, light);
      svg.circle(60, 30, 4, light);
      svg.ellipse(_headCx, _headCy, _headRx, _headRy, base);
      _eyes(svg, offsetY: -2);
      svg.path('M43.5 61 L56.5 61 L50 71 Z', fill: _beak);
      svg.ellipse(30, 60, 5, 3.5, light);
      svg.ellipse(70, 60, 5, 3.5, light);
      break;

    case 'uil':
      svg.path('M27 44 L31 25 L44 36 Z', fill: shade);
      svg.path('M73 44 L69 25 L56 36 Z', fill: shade);
      svg.ellipse(_headCx, _headCy, _headRx, _headRy, base);
      svg.circle(39, 52, 12.5, light);
      svg.circle(61, 52, 12.5, light);
      svg.circle(39.8, 52.5, 5.6, _ink);
      svg.circle(60.2, 52.5, 5.6, _ink);
      svg.circle(37.6, 50.3, 1.9, _cream);
      svg.circle(58, 50.3, 1.9, _cream);
      svg.path('M45.5 62 L54.5 62 L50 70 Z', fill: _beak);
      svg.path('M34 72 Q50 79 66 72', stroke: shade, strokeWidth: 2.4);
      break;

    case 'hert':
      svg.path(
        'M38 38 L33 24 M33 24 L26 20 M33 24 L34 15',
        stroke: shade,
        strokeWidth: 3.4,
      );
      svg.path(
        'M62 38 L67 24 M67 24 L74 20 M67 24 L66 15',
        stroke: shade,
        strokeWidth: 3.4,
      );
      svg.ellipse(24, 47, 8, 5, shade, rotate: -35);
      svg.ellipse(76, 47, 8, 5, shade, rotate: 35);
      svg.ellipse(_headCx, _headCy, _headRx, _headRy, base);
      svg.ellipse(50, 66, 10, 7.5, light);
      _eyes(svg);
      svg.ellipse(50, 63.5, 3, 2.2, _ink);
      _smile(svg, 68);
      break;

    case 'os':
      svg.path('M30 40 Q14 38 12 24 Q22 30 32 30', fill: _cream);
      svg.path('M70 40 Q86 38 88 24 Q78 30 68 30', fill: _cream);
      svg.ellipse(22, 50, 8, 5.5, shade, rotate: -20);
      svg.ellipse(78, 50, 8, 5.5, shade, rotate: 20);
      svg.ellipse(_headCx, _headCy, _headRx, _headRy, base);
      svg.rect(37, 60, 26, 15, 7.5, light);
      _eyes(svg, offsetY: -2);
      svg.ellipse(44.5, 67, 2.2, 2.8, _ink);
      svg.ellipse(55.5, 67, 2.2, 2.8, _ink);
      break;

    case 'lam':
    default:
      svg.ellipse(22, 54, 9, 5.5, shade, rotate: -28);
      svg.ellipse(78, 54, 9, 5.5, shade, rotate: 28);
      svg.circle(33, 36, 11, light);
      svg.circle(50, 30, 12, light);
      svg.circle(67, 36, 11, light);
      svg.ellipse(_headCx, _headCy, _headRx, _headRy, base);
      svg.ellipse(50, 64, 11, 8, light);
      _eyes(svg);
      svg.ellipse(50, 62, 2.6, 2, _ink);
      _smile(svg, 66);
      break;
  }

  switch (config.accessory) {
    case 'bril':
      svg.ring(40.5, 52, 8.5, _ink, 2.2);
      svg.ring(59.5, 52, 8.5, _ink, 2.2);
      svg.path('M49 52 L51 52', stroke: _ink, strokeWidth: 2.2);
      break;

    case 'pet':
      svg.path('M25 40 Q50 18 75 40 Z', fill: _cap);
      svg.rect(22, 38, 56, 6, 3, '#2A4373');
      break;

    case 'sjaal':
      svg.rect(27, 76, 46, 10, 5, _scarf);
      svg.rect(60, 82, 10, 16, 4, '#883B23', rotate: 12);
      break;

    case 'kroon':
      svg.path('M30 34 L36 20 L43 30 L50 16 L57 30 L64 20 L70 34 Z', fill: _gold);
      svg.circle(36, 20, 2.4, _cream);
      svg.circle(50, 16, 2.8, _cream);
      svg.circle(64, 20, 2.4, _cream);
      break;

    default:
      break;
  }

  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">'
      '<defs><clipPath id="c"><circle cx="50" cy="50" r="50"/></clipPath></defs>'
      '<g clip-path="url(#c)">$svg</g>'
      '</svg>';
}
