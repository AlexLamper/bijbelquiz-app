class MultiplayerApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  const MultiplayerApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return '$code ($statusCode): $message';
    }
    return '$code: $message';
  }
}
