import 'package:flutter_test/flutter_test.dart';

import 'package:bijbelquiz_mobile/core/errors/app_error.dart';
import 'package:bijbelquiz_mobile/features/multiplayer/data/multiplayer_api_exception.dart';

/// Guards the promise that a player never sees an API code or a stack trace.
void main() {
  test('typed room-not-found becomes a Dutch message', () {
    final error = AppError.from(
      const MultiplayerApiException(
        code: 'ROOM_NOT_FOUND',
        message: 'Room not found',
        statusCode: 404,
      ),
    );

    expect(error.title, 'Kamer niet gevonden');
    expect(error.message, contains('bestaat niet meer'));
  });

  test('code embedded in a raw string is recognised', () {
    final error = AppError.from(
      Exception('ROOM_NOT_FOUND (404): Room not found'),
    );

    expect(error.title, 'Kamer niet gevonden');
    expect(error.message, isNot(contains('404')));
  });

  test('premium code points at the subscription', () {
    final error = AppError.from(
      const MultiplayerApiException(
        code: 'PREMIUM_REQUIRED',
        message: 'Premium required',
      ),
    );

    expect(error.title, 'Premium vereist');
  });

  test('connection failures read as a network problem', () {
    expect(
      AppError.from(Exception('DioException: connection error')).title,
      'Geen verbinding',
    );
    expect(
      AppError.from(Exception('Failed host lookup: www.bijbelquiz.com')).title,
      'Geen verbinding',
    );
  });

  test('English repository messages are translated', () {
    expect(
      AppError.from(Exception('Failed to load leaderboard: 500')).message,
      contains('ranglijst'),
    );
    expect(
      AppError.from(Exception('Invalid credentials')).message,
      'Dit e-mailadres of wachtwoord klopt niet.',
    );
  });

  test('a written Dutch sentence is kept as-is', () {
    expect(
      AppError.from(Exception('Voer eerst een kamercode in.')).message,
      'Voer eerst een kamercode in.',
    );
  });

  test('unknown technical noise falls back to the generic message', () {
    final error = AppError.from(
      Exception("type 'Null' is not a subtype of type 'String'"),
    );

    expect(error, AppError.unknown);
    expect(error.message, isNot(contains('Null')));
  });

  test('no mapped message leaks an uppercase code', () {
    const codes = [
      'ROOM_NOT_FOUND',
      'ROOM_FULL',
      'PREMIUM_REQUIRED',
      'UNAUTHORIZED',
      'NETWORK_ERROR',
      'REQUEST_FAILED',
      'SOMETHING_WE_NEVER_DEFINED',
    ];

    for (final code in codes) {
      final error = AppError.from(
        MultiplayerApiException(code: code, message: code, statusCode: 400),
      );
      expect(error.message, isNot(contains('_')), reason: code);
      expect(error.message, isNot(contains(code)), reason: code);
    }
  });
}
