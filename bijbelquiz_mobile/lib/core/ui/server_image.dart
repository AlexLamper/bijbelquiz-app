import 'package:flutter/material.dart';
import '../api/api_client.dart'; // import wherever your baseUrl is defined

class ServerImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const ServerImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
  });

  static String getFullUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;

    // Grab your ApiClient baseUrl (e.g., "http://10.0.2.2:3000/api")
    // and strip the "/api" part off to get the root host.
    // Given the baseUrl typically has "/api/mobile", we can just replace what we know
    final String host = ApiClient.baseUrl.replaceAll(RegExp(r'/api.*$'), '');

    // Combine them safely
    final String cleanPath = imagePath.startsWith('/')
        ? imagePath
        : '/$imagePath';
    return '$host$cleanPath';
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
