import 'package:flutter/material.dart';

enum AppRole {
  farmer,
  customer,
  admin,
}

class RoleOption {
  final AppRole role;
  final String title;
  final String description;
  final List<String> tags;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  const RoleOption({
    required this.role,
    required this.title,
    required this.description,
    required this.tags,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}

class TrendingCropItem {
  final String title;
  final String badgeText;
  final String subBadgeText;
  final String priceInfo;
  final String imageType;

  const TrendingCropItem({
    required this.title,
    required this.badgeText,
    required this.subBadgeText,
    required this.priceInfo,
    required this.imageType,
  });
}

class CategoryItem {
  final String label;
  final IconData icon;
  final Color bgColor;

  const CategoryItem({
    required this.label,
    required this.icon,
    required this.bgColor,
  });
}

class CatalogProduct {
  final String name;
  final String farmer;
  final String price;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final String imageType;

  const CatalogProduct({
    required this.name,
    required this.farmer,
    required this.price,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.imageType,
  });
}

class FarmerProfile {
  final String name;
  final String initials;
  final double rating;
  final int reviewsCount;
  final String distance;

  const FarmerProfile({
    required this.name,
    required this.initials,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
  });
}

class SmartRecommendation {
  final String title;
  final String confidence;
  final String description;
  final String profitIncrease;
  final String actionLabel;
  final IconData icon;

  const SmartRecommendation({
    required this.title,
    required this.confidence,
    required this.description,
    required this.profitIncrease,
    required this.actionLabel,
    required this.icon,
  });
}

class HighDemandCrop {
  final String name;
  final String tag;
  final bool isHighDemand;
  final String projectedPrice;
  final String imageType;

  const HighDemandCrop({
    required this.name,
    required this.tag,
    required this.isHighDemand,
    required this.projectedPrice,
    required this.imageType,
  });
}

class AdminMetric {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;
  final bool isPositive;

  const AdminMetric({
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
    this.isPositive = true,
  });
}
