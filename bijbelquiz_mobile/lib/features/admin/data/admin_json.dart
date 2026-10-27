/// Forgiving JSON readers for the admin API.
///
/// The admin endpoints grow over time and older servers send less, so every
/// reader tolerates a missing key, a number sent as a string, or a map where
/// a list was expected, and falls back to an empty value instead of throwing.
library;

Map<String, dynamic> jMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
  return const {};
}

List<Map<String, dynamic>> jMapList(Object? value) {
  if (value is! List) return const [];
  return [
    for (final e in value)
      if (e is Map) jMap(e),
  ];
}

List<String> jStringList(Object? value) {
  if (value is! List) return const [];
  return [
    for (final e in value)
      if (e != null) e.toString(),
  ];
}

int jInt(Object? value, [int fallback = 0]) {
  if (value is num) return value.round();
  if (value is String) return num.tryParse(value)?.round() ?? fallback;
  return fallback;
}

int? jIntOrNull(Object? value) {
  if (value is num) return value.round();
  if (value is String) return num.tryParse(value)?.round();
  return null;
}

double jDouble(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

double? jDoubleOrNull(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String jString(Object? value, [String fallback = '']) {
  if (value == null) return fallback;
  final s = value.toString();
  return s.isEmpty ? fallback : s;
}

String? jStringOrNull(Object? value) {
  if (value == null) return null;
  final s = value.toString();
  return s.isEmpty ? null : s;
}

bool jBool(Object? value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == 'true' || value == '1';
  return fallback;
}

DateTime? jDate(Object? value) {
  if (value == null) return null;
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
  }
  return DateTime.tryParse(value.toString());
}

/// `{"ios": 3, "android": 2}` -> ordered map of ints. Also accepts a list of
/// `{key|platform|source|name: ..., count|value: ...}` objects.
Map<String, int> jCounts(Object? value) {
  if (value is Map) {
    final out = <String, int>{};
    jMap(value).forEach((k, v) {
      if (v is num || v is String) out[k] = jInt(v);
      if (v is Map) {
        final m = jMap(v);
        out[k] = jInt(m['count'] ?? m['value'] ?? m['total']);
      }
    });
    return out;
  }
  if (value is List) {
    final out = <String, int>{};
    for (final m in jMapList(value)) {
      final key = jString(
        m['key'] ?? m['platform'] ?? m['source'] ?? m['name'] ?? m['label'],
        'unknown',
      );
      out[key] = jInt(m['count'] ?? m['value'] ?? m['total']);
    }
    return out;
  }
  return const {};
}
