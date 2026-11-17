import '../network/api_endpoints.dart';

/// Resolves product image URLs and local agricultural HD fallback photos.
class ProductImageResolver {
  static const String basmatiRiceAsset = 'assets/images/basmati_rice.jpg';
  static const String organicTomatoesAsset = 'assets/images/organic_tomatoes.jpg';
  static const String romaTomatoesAsset = 'assets/images/roma_tomatoes.jpg';
  static const String freshPotatoesAsset = 'assets/images/fresh_potatoes.jpg';
  static const String organicWheatAsset = 'assets/images/organic_wheat.jpg';
  static const String groundnutsAsset = 'assets/images/groundnuts.jpg';
  static const String whiteCottonAsset = 'assets/images/white_cotton.jpg';
  static const String freshProduceFallbackAsset =
      'assets/images/fresh_produce_fallback.jpg';
  static const String grainsFallbackAsset = 'assets/images/grains_fallback.jpg';

  /// Returns a valid network image URL when the backend stores an HTTP/HTTPS URL
  /// or a server-relative path (e.g. `/uploads/...`). Returns null for key tokens.
  static String? resolveNetworkUrl(String? rawImage) {
    if (rawImage == null) return null;
    final trimmed = rawImage.trim();
    if (trimmed.isEmpty) return null;

    final lower = trimmed.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return trimmed;
    }

    if (trimmed.startsWith('/') && trimmed.length > 1) {
      final base = ApiEndpoints.baseUrl;
      final origin = base.endsWith('/api')
          ? base.substring(0, base.length - 4)
          : base;
      return '$origin$trimmed';
    }

    return null;
  }

  /// Resolves the most accurate HD agricultural photograph asset path based on
  /// product name, image key/type, and category.
  static String resolveAssetPath({
    String? imageType,
    String? productName,
    String? category,
  }) {
    final name = (productName ?? '').toLowerCase();
    final type = (imageType ?? '').toLowerCase();
    final cat = (category ?? '').toLowerCase();

    // Check product name first so varieties (e.g. Hybrid Roma Tomatoes vs Organic Tomatoes)
    // display distinct photographs even when sharing a generic key ('tomatoes').
    final fromName = _matchSpecificToken(name);
    if (fromName != null) return fromName;

    final fromType = _matchSpecificToken(type);
    if (fromType != null) return fromType;

    final combined = '$name $type $cat';
    if (combined.contains('grain') ||
        combined.contains('pulse') ||
        combined.contains('lentil') ||
        combined.contains('dal') ||
        combined.contains('millet') ||
        combined.contains('corn') ||
        combined.contains('maize') ||
        combined.contains('barley') ||
        combined.contains('seed') ||
        combined.contains('spice')) {
      return grainsFallbackAsset;
    }

    return freshProduceFallbackAsset;
  }

  static String? _matchSpecificToken(String text) {
    if (text.isEmpty) return null;
    if (text.contains('roma') && text.contains('tomato')) {
      return romaTomatoesAsset;
    }
    if (text.contains('tomato')) {
      return organicTomatoesAsset;
    }
    if (text.contains('basmati') || text.contains('rice') || text.contains('paddy')) {
      return basmatiRiceAsset;
    }
    if (text.contains('potato')) {
      return freshPotatoesAsset;
    }
    if (text.contains('wheat') || text.contains('offer_wheat')) {
      return organicWheatAsset;
    }
    if (text.contains('groundnut') || text.contains('peanut')) {
      return groundnutsAsset;
    }
    if (text.contains('cotton')) {
      return whiteCottonAsset;
    }
    return null;
  }

  /// Derives a semantic `primaryImage` key when a farmer submits a new product.
  static String resolveKeyForNewProduct(String name, int categoryId) {
    final lower = name.toLowerCase();
    if (lower.contains('tomato')) return 'tomatoes';
    if (lower.contains('rice') || lower.contains('basmati')) return 'rice';
    if (lower.contains('potato')) return 'potatoes';
    if (lower.contains('wheat')) return 'wheat';
    if (lower.contains('groundnut') || lower.contains('peanut')) return 'groundnuts';
    if (lower.contains('cotton')) return 'cotton';
    if (categoryId == 3) return 'grains';
    return 'produce';
  }
}
