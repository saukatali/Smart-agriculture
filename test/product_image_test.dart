import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrismart/core/utils/product_image_resolver.dart';
import 'package:agrismart/widgets/crop_visual_widget.dart';

void main() {
  group('ProductImageResolver Tests', () {
    test('Maps distinct product names and semantic keys accurately', () {
      expect(
        ProductImageResolver.resolveAssetPath(
          productName: 'Basmati Rice',
          imageType: 'rice',
        ),
        ProductImageResolver.basmatiRiceAsset,
      );
      expect(
        ProductImageResolver.resolveAssetPath(
          productName: 'Organic Tomatoes',
          imageType: 'tomatoes',
        ),
        ProductImageResolver.organicTomatoesAsset,
      );
      expect(
        ProductImageResolver.resolveAssetPath(
          productName: 'Hybrid Roma Tomatoes',
          imageType: 'tomatoes',
        ),
        ProductImageResolver.romaTomatoesAsset,
      );
      expect(
        ProductImageResolver.resolveAssetPath(
          productName: 'Fresh Potatoes',
          imageType: 'potatoes',
        ),
        ProductImageResolver.freshPotatoesAsset,
      );
      expect(
        ProductImageResolver.resolveAssetPath(
          productName: 'Premium Organic Wheat',
          imageType: 'wheat',
        ),
        ProductImageResolver.organicWheatAsset,
      );
      expect(
        ProductImageResolver.resolveAssetPath(
          productName: 'Groundnuts',
          imageType: 'groundnuts',
        ),
        ProductImageResolver.groundnutsAsset,
      );
      expect(
        ProductImageResolver.resolveAssetPath(
          productName: 'Desi White Cotton',
          imageType: 'cotton',
        ),
        ProductImageResolver.whiteCottonAsset,
      );
    });

    test('Falls back cleanly by category when product has no URL', () {
      expect(
        ProductImageResolver.resolveAssetPath(
          productName: 'Organic Bajra Millet',
          imageType: '',
          category: 'Grains',
        ),
        ProductImageResolver.grainsFallbackAsset,
      );
      expect(
        ProductImageResolver.resolveAssetPath(
          productName: 'Farm Spinach',
          imageType: null,
          category: 'Vegetables',
        ),
        ProductImageResolver.freshProduceFallbackAsset,
      );
    });

    test('Resolves backend HTTP/HTTPS URLs and server-relative paths', () {
      expect(
        ProductImageResolver.resolveNetworkUrl('https://cdn.example.com/rice.jpg'),
        'https://cdn.example.com/rice.jpg',
      );
      expect(
        ProductImageResolver.resolveNetworkUrl('/uploads/tomatoes.jpg'),
        'http://127.0.0.1:8000/uploads/tomatoes.jpg',
      );
      expect(ProductImageResolver.resolveNetworkUrl('tomatoes'), isNull);
      expect(ProductImageResolver.resolveNetworkUrl(''), isNull);
    });
  });

  group('CropVisualWidget Tests', () {
    testWidgets('Renders bundled HD asset photo with BoxFit.cover for key', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CropVisualWidget(
              cropType: 'rice',
              productName: 'Basmati Rice',
              width: 120,
              height: 80,
              borderRadius: 10,
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.fit, BoxFit.cover);
      expect(image.image, isA<AssetImage>());
      expect((image.image as AssetImage).assetName, ProductImageResolver.basmatiRiceAsset);
    });

    testWidgets('Uses CachedNetworkImage when backend returns an image URL', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CropVisualWidget(
              cropType: 'https://example.com/uploads/wheat.jpg',
              productName: 'Premium Organic Wheat',
              width: 120,
              height: 80,
            ),
          ),
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });
}

