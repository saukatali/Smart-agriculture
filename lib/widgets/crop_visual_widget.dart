import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/utils/product_image_resolver.dart';
import '../theme/app_colors.dart';

class CropVisualWidget extends StatelessWidget {
  final String cropType;
  final String? productName;
  final String? imageUrl;
  final String? category;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const CropVisualWidget({
    super.key,
    required this.cropType,
    this.productName,
    this.imageUrl,
    this.category,
    this.width = 60,
    this.height = 60,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedNetworkUrl =
        ProductImageResolver.resolveNetworkUrl(imageUrl ?? cropType);
    final fallbackAsset = ProductImageResolver.resolveAssetPath(
      imageType: cropType,
      productName: productName,
      category: category,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: AppColors.primarySurface,
        child: resolvedNetworkUrl != null
            ? CachedNetworkImage(
                imageUrl: resolvedNetworkUrl,
                width: width,
                height: height,
                fit: fit,
                fadeInDuration: const Duration(milliseconds: 220),
                placeholder: (context, url) => Container(
                  width: width,
                  height: height,
                  color: AppColors.primarySurface,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: width < 52 ? 16 : 22,
                    height: width < 52 ? 16 : 22,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildAssetImage(fallbackAsset),
              )
            : _buildAssetImage(fallbackAsset),
      ),
    );
  }

  Widget _buildAssetImage(String assetPath) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: AppColors.primaryContainer,
          alignment: Alignment.center,
          child: const Icon(
            Icons.eco_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        );
      },
    );
  }
}
