import 'package:bijbelquiz_mobile/core/avatar/avatar_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unknown catalogue ids fall back instead of throwing', () {
    final avatar = AvatarConfig.fromJson({
      'character': 'draak',
      'color': 'neon',
      'background': 'perkament',
      'accessory': null,
    });

    // A client built against a newer catalogue must never write a mascot an
    // older build refuses to draw.
    expect(avatar.character, AvatarConfig.fallback.character);
    expect(avatar.color, AvatarConfig.fallback.color);
    expect(avatar.background, 'perkament');
    expect(avatar.accessory, AvatarConfig.fallback.accessory);
  });

  test('a missing avatar resolves to a stable seeded one', () {
    final first = AvatarConfig.resolve(null, '507f1f77bcf86cd799439011');
    final second = AvatarConfig.resolve(null, '507f1f77bcf86cd799439011');

    expect(first, second);
    expect(
      avatarCharacters.map((option) => option.id),
      contains(first.character),
    );
  });

  test('different accounts get different seeded mascots', () {
    final seeds = ['user-a', 'user-b', 'user-c', 'user-d', 'user-e'];
    final drawn = seeds.map(AvatarConfig.fromSeed).toSet();

    // The whole point of seeding is that a fresh leaderboard is not forty
    // identical figures.
    expect(drawn.length, greaterThan(1));
  });

  test('a stored avatar wins over the seed', () {
    final stored = AvatarConfig.resolve(
      {'character': 'uil', 'color': 'lapis', 'background': 'nacht', 'accessory': 'kroon'},
      'ignored-seed',
    );

    expect(stored.character, 'uil');
    expect(stored.accessory, 'kroon');
  });

  test('every combination produces a closed svg document', () {
    for (final character in avatarCharacters) {
      for (final accessory in avatarAccessories) {
        final svg = buildAvatarSvg(
          AvatarConfig(
            character: character.id,
            color: 'zand',
            background: 'perkament',
            accessory: accessory.id,
          ),
        );

        expect(svg, startsWith('<svg '));
        expect(svg, endsWith('</svg>'));
        expect(svg, contains('viewBox="0 0 100 100"'));
        // Anything reaching past the backdrop has to be trimmed, or a crown
        // overlaps whatever sits beside the avatar in a list.
        expect(svg, contains('clip-path="url(#c)"'));
      }
    }
  });

  test('colour and background ids reach the drawing', () {
    final svg = buildAvatarSvg(
      const AvatarConfig(
        character: 'lam',
        color: 'klei',
        background: 'nacht',
        accessory: 'geen',
      ),
    );

    expect(svg, contains('#CE8163'));
    expect(svg, contains('#2A3242'));
  });

  test('describeAvatar names the accessory only when there is one', () {
    expect(
      describeAvatar(
        const AvatarConfig(
          character: 'leeuw',
          color: 'zand',
          background: 'hemel',
          accessory: 'geen',
        ),
      ),
      'Leeuw',
    );

    expect(
      describeAvatar(
        const AvatarConfig(
          character: 'leeuw',
          color: 'zand',
          background: 'hemel',
          accessory: 'kroon',
        ),
      ),
      'Leeuw met kroon',
    );
  });

  test('round trips through json', () {
    const original = AvatarConfig(
      character: 'hert',
      color: 'olijf',
      background: 'salie',
      accessory: 'sjaal',
    );

    expect(AvatarConfig.fromJson(original.toJson()), original);
  });
}
