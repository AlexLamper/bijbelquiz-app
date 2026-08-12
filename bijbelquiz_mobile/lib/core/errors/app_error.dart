import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../features/multiplayer/data/multiplayer_api_exception.dart';

/// A user-facing error, in Dutch.
///
/// Everything the app throws — API codes like `ROOM_NOT_FOUND (404)`, Dio
/// failures, raw English repository messages — is funnelled through
/// [AppError.from] so the UI never shows a code or a stack trace to a player.
@immutable
class AppError {
  const AppError({
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
  });

  /// Short heading, e.g. `Kamer niet gevonden`.
  final String title;

  /// One or two sentences telling the player what to do next.
  final String message;

  final IconData icon;

  /// Generic last resort — used whenever the underlying error carries nothing
  /// a player could act on.
  static const AppError unknown = AppError(
    title: 'Er ging iets mis',
    message:
        'We konden dit niet afronden. Probeer het zo nog een keer.',
  );

  static const AppError _network = AppError(
    title: 'Geen verbinding',
    message:
        'Controleer je internetverbinding en probeer het opnieuw.',
    icon: Icons.wifi_off_outlined,
  );

  static const AppError _signedOut = AppError(
    title: 'Opnieuw inloggen',
    message: 'Je sessie is verlopen. Log opnieuw in om verder te spelen.',
    icon: Icons.lock_outline,
  );

  /// Translates any thrown object into something worth showing.
  static AppError from(Object? error) {
    if (error == null) return unknown;

    if (error is AppError) return error;

    if (error is MultiplayerApiException) {
      return _forCode(error.code) ?? _fromText(error.message);
    }

    if (error is SocketException ||
        error is HttpException ||
        error is TimeoutException) {
      return _network;
    }

    return _fromText(error.toString());
  }

  /// Convenience for snackbars, which only have room for one line.
  static String messageOf(Object? error) => from(error).message;

  /// Known API/error codes. Kept separate so both the typed multiplayer
  /// exception and codes embedded in a raw string resolve the same way.
  static AppError? _forCode(String rawCode) {
    switch (rawCode.trim().toUpperCase()) {
      case 'ROOM_NOT_FOUND':
        return const AppError(
          title: 'Kamer niet gevonden',
          message:
              'Deze kamer bestaat niet meer of is gesloten. Controleer de '
              'code, of start zelf een nieuwe kamer.',
          icon: Icons.meeting_room_outlined,
        );
      case 'ROOM_FULL':
        return const AppError(
          title: 'Kamer is vol',
          message:
              'Er passen geen spelers meer bij in deze kamer. Vraag de host om '
              'een nieuwe kamer te openen.',
          icon: Icons.groups_outlined,
        );
      case 'ROOM_ALREADY_STARTED':
      case 'GAME_ALREADY_STARTED':
      case 'ROOM_IN_PROGRESS':
        return const AppError(
          title: 'Spel is al begonnen',
          message:
              'Deze quiz loopt al. Wacht tot de ronde klaar is of start een '
              'nieuwe kamer.',
          icon: Icons.timer_outlined,
        );
      case 'ROOM_FINISHED':
        return const AppError(
          title: 'Spel is afgelopen',
          message: 'Deze kamer is gesloten. Start een nieuwe kamer om verder '
              'te spelen.',
          icon: Icons.flag_outlined,
        );
      case 'INVALID_ROOM_CODE':
      case 'INVALID_CODE':
        return const AppError(
          title: 'Ongeldige kamercode',
          message:
              'Deze code klopt niet. Een kamercode bestaat uit 6 tekens.',
          icon: Icons.pin_outlined,
        );
      case 'ALREADY_IN_ROOM':
      case 'ALREADY_JOINED':
        return const AppError(
          title: 'Je zit al in deze kamer',
          message: 'Ga terug naar de kamer om verder te spelen.',
          icon: Icons.groups_outlined,
        );
      case 'PREMIUM_REQUIRED':
        return const AppError(
          title: 'Premium vereist',
          message:
              'Zelf een kamer hosten hoort bij Bijbelquiz Premium. Meespelen '
              'kan altijd gratis.',
          icon: Icons.workspace_premium_outlined,
        );
      case 'NOT_HOST':
      case 'FORBIDDEN':
        return const AppError(
          title: 'Geen toegang',
          message: 'Alleen de host kan dit doen.',
          icon: Icons.lock_outline,
        );
      case 'UNAUTHORIZED':
      case 'TOKEN_EXPIRED':
      case 'NO_TOKEN':
        return _signedOut;
      case 'NETWORK_ERROR':
      case 'TIMEOUT':
        return _network;
      case 'RATE_LIMITED':
        return const AppError(
          title: 'Even wachten',
          message: 'Je probeerde het te vaak achter elkaar. Wacht een moment '
              'en probeer het opnieuw.',
          icon: Icons.hourglass_empty,
        );
      case 'NOT_FOUND':
        return const AppError(
          title: 'Niet gevonden',
          message: 'We konden dit niet vinden. Ga terug en probeer het opnieuw.',
          icon: Icons.search_off_outlined,
        );
      case 'CONFLICT':
        return const AppError(
          title: 'Dat kan nu niet',
          message:
              'Deze actie past niet bij de huidige stand van het spel. Ververs '
              'en probeer het opnieuw.',
        );
      case 'SERVER_ERROR':
      case 'INTERNAL_SERVER_ERROR':
      case 'REQUEST_FAILED':
        return const AppError(
          title: 'Server reageert niet',
          message:
              'Er ging iets mis aan onze kant. Probeer het over een paar '
              'seconden nog eens.',
          icon: Icons.cloud_off_outlined,
        );
      default:
        return null;
    }
  }

  /// Codes as they appear inside a raw string, e.g.
  /// `Exception: ROOM_NOT_FOUND (404): Room not found`.
  static final RegExp _codePattern = RegExp(r'\b[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)+\b');

  /// Anything that betrays a technical message rather than a written one.
  static final RegExp _technicalPattern = RegExp(
    r'exception|dioerror|dioexception|statuscode|status code|\(\d{3}\)|'
    r'http[s]?://|socket|handshake|formatexception|null check|type \x27',
    caseSensitive: false,
  );

  static AppError _fromText(String raw) {
    var text = raw.trim();
    for (final prefix in const ['Exception: ', 'Error: ', 'DioException ']) {
      if (text.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
      }
    }

    final lower = text.toLowerCase();

    // 1. A known code hiding in the text wins — that is the precise answer.
    final codeMatch = _codePattern.firstMatch(text);
    if (codeMatch != null) {
      final mapped = _forCode(codeMatch.group(0)!);
      if (mapped != null) return mapped;
    }

    // 2. Connection-shaped failures.
    if (lower.contains('socket') ||
        lower.contains('connection') ||
        lower.contains('timeout') ||
        lower.contains('network') ||
        lower.contains('failed host lookup') ||
        lower.contains('geen internet')) {
      return _network;
    }

    if (lower.contains('websocket')) {
      return const AppError(
        title: 'Live verbinding weg',
        message:
            'De live verbinding viel weg. We halen de stand nu automatisch op.',
        icon: Icons.sync_problem_outlined,
      );
    }

    // 3. English repository/auth messages, mapped to Dutch.
    final mapped = _forEnglishMessage(lower);
    if (mapped != null) return mapped;

    // 4. Already a written Dutch sentence? Show it as-is.
    if (text.isNotEmpty && !_technicalPattern.hasMatch(text) && !_looksLikeCode(text)) {
      return AppError(title: 'Er ging iets mis', message: text);
    }

    return unknown;
  }

  static bool _looksLikeCode(String text) {
    final match = _codePattern.firstMatch(text);
    return match != null && match.group(0)!.length > 3;
  }

  static AppError? _forEnglishMessage(String lower) {
    if (lower.contains('invalid credentials') ||
        lower.contains('wrong password') ||
        lower.contains('invalid email or password')) {
      return const AppError(
        title: 'Inloggen mislukt',
        message: 'Dit e-mailadres of wachtwoord klopt niet.',
        icon: Icons.lock_outline,
      );
    }
    if (lower.contains('already exists') || lower.contains('already registered')) {
      return const AppError(
        title: 'Account bestaat al',
        message: 'Er bestaat al een account met dit e-mailadres. Log in.',
        icon: Icons.person_outline,
      );
    }
    if (lower.contains('registration failed') || lower.contains('failed to register')) {
      return const AppError(
        title: 'Registreren mislukt',
        message: 'We konden je account niet aanmaken. Probeer het opnieuw.',
        icon: Icons.person_outline,
      );
    }
    if (lower.contains('failed to login')) {
      return const AppError(
        title: 'Inloggen mislukt',
        message: 'We konden je niet inloggen. Probeer het opnieuw.',
        icon: Icons.lock_outline,
      );
    }
    if (lower.contains('leaderboard')) {
      return const AppError(
        title: 'Ranglijst niet geladen',
        message: 'We konden de ranglijst niet ophalen. Probeer het opnieuw.',
        icon: Icons.leaderboard_outlined,
      );
    }
    if (lower.contains('quiz') || lower.contains('categor')) {
      return const AppError(
        title: 'Quizzen niet geladen',
        message: 'We konden de quizzen niet ophalen. Probeer het opnieuw.',
        icon: Icons.menu_book_outlined,
      );
    }
    if (lower.contains('profiel') || lower.contains('profile')) {
      return const AppError(
        title: 'Profiel niet geladen',
        message: 'We konden je profiel niet ophalen. Probeer het opnieuw.',
        icon: Icons.person_outline,
      );
    }
    if (lower.contains('purchase') || lower.contains('aankoop')) {
      return const AppError(
        title: 'Aankoop mislukt',
        message:
            'De aankoop is niet afgerond. Er is niets in rekening gebracht.',
        icon: Icons.workspace_premium_outlined,
      );
    }
    return null;
  }
}
