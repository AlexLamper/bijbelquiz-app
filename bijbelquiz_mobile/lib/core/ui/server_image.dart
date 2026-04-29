import 'package:flutter/material.dart';
import '../config/app_config.dart';

class ServerImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const ServerImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
  });

  static final RegExp _httpUrlPattern = RegExp(
    r'^https?://',
    caseSensitive: false,
  );

  static final RegExp _fileExtensionPattern = RegExp(
    r'\.[a-z0-9]+$',
    caseSensitive: false,
  );

  // A session-scoped version value helps bypass stale in-memory/browser image cache.
  static final String _quizImageSessionVersion = DateTime.now()
      .millisecondsSinceEpoch
      .toString();

  /// Supports multiple backend formats:
  /// - /images/quizzes/img8.png
  /// - images/quizzes/img8.png
  /// - public/images/quizzes/img8.png
  /// - img8.png
  static String normalizePath(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') {
      return '';
    }

    if (_httpUrlPattern.hasMatch(trimmed)) {
      return trimmed;
    }

    final withForwardSlashes = trimmed.replaceAll('\\', '/');
    final withoutPublicPrefix = withForwardSlashes.replaceFirst(
      RegExp(r'^/?public/'),
      '/',
    );

    String ensureQuizPngExtension(String path) {
      if (!path.toLowerCase().startsWith('/images/quizzes/')) {
        return path;
      }

      return _fileExtensionPattern.hasMatch(path) ? path : '$path.png';
    }

    if (withoutPublicPrefix.startsWith('/')) {
      return ensureQuizPngExtension(withoutPublicPrefix);
    }

    if (withoutPublicPrefix.startsWith('images/')) {
      return ensureQuizPngExtension('/$withoutPublicPrefix');
    }

    if (withoutPublicPrefix.contains('/')) {
      return ensureQuizPngExtension('/$withoutPublicPrefix');
    }

    // If only a file name is provided, default to the quizzes image folder.
    return ensureQuizPngExtension('/images/quizzes/$withoutPublicPrefix');
  }

  static bool _isQuizImagePath(String path) {
    return path.toLowerCase().contains('/images/quizzes/');
  }

  static String _appendSessionVersion(String url) {
    final uri = Uri.parse(url);

    // Keep explicit URL versioning untouched.
    if (uri.queryParameters.containsKey('v')) {
      return url;
    }

    final query = Map<String, String>.from(uri.queryParameters)
      ..['sv'] = _quizImageSessionVersion;

    return uri.replace(queryParameters: query).toString();
  }

  static String getFullUrl(String imagePath) {
    final String normalizedPath = normalizePath(imagePath);
    if (normalizedPath.isEmpty) return '';

    if (_httpUrlPattern.hasMatch(normalizedPath)) {
      return _isQuizImagePath(normalizedPath)
          ? _appendSessionVersion(normalizedPath)
          : normalizedPath;
    }

    // Get the base host URL (without /api/mobile)
    final String host = AppConfig.baseUrl;

    // Combine them safely
    final fullUrl = '$host$normalizedPath';
    return _isQuizImagePath(normalizedPath)
        ? _appendSessionVersion(fullUrl)
        : fullUrl;
  }

  String _buildFullUrl() {
    return getFullUrl(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _buildFullUrl(),
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
      },
    );
  }
}
