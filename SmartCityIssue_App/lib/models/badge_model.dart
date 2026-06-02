import 'package:flutter/material.dart';

// ── Badge Tier ───────────────────────────────────────────────────────────────
enum BadgeTier { gold, silver, bronze }

// ── Badge Rarity ─────────────────────────────────────────────────────────────
enum BadgeRarity { common, rare, epic, legendary }

// ── Badge Model ──────────────────────────────────────────────────────────────
class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String requirement;
  final IconData icon;
  final BadgeTier tier;
  final BadgeRarity rarity;
  final int requiredCount;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requirement,
    required this.icon,
    required this.tier,
    required this.rarity,
    required this.requiredCount,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progressPercent =>
      requiredCount > 0
          ? (currentProgress / requiredCount).clamp(0.0, 1.0)
          : 0.0;

  int get remaining =>
      (requiredCount - currentProgress).clamp(0, requiredCount);

  BadgeModel copyWith({
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) =>
      BadgeModel(
        id: id,
        title: title,
        description: description,
        requirement: requirement,
        icon: icon,
        tier: tier,
        rarity: rarity,
        requiredCount: requiredCount,
        currentProgress: currentProgress ?? this.currentProgress,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );

  // ── Tier Helpers ─────────────────────────────────────────────────────────

  List<Color> get tierGradient {
    switch (tier) {
      case BadgeTier.gold:
        return const [
          Color(0xFFFFD700),
          Color(0xFFFFA500),
          Color(0xFFFFD700),
          Color(0xFFDAA520),
        ];
      case BadgeTier.silver:
        return const [
          Color(0xFFC0C0C0),
          Color(0xFFE8E8E8),
          Color(0xFFB0B0B0),
          Color(0xFFD4D4D4),
        ];
      case BadgeTier.bronze:
        return const [
          Color(0xFFCD7F32),
          Color(0xFFB8860B),
          Color(0xFFD4A04A),
          Color(0xFFA0712B),
        ];
    }
  }

  Color get tierGlowColor {
    switch (tier) {
      case BadgeTier.gold:
        return const Color(0xFFFFD700);
      case BadgeTier.silver:
        return const Color(0xFFC0C0C0);
      case BadgeTier.bronze:
        return const Color(0xFFCD7F32);
    }
  }

  Color get tierAccentColor {
    switch (tier) {
      case BadgeTier.gold:
        return const Color(0xFF7B6100);
      case BadgeTier.silver:
        return const Color(0xFF5A5A5A);
      case BadgeTier.bronze:
        return const Color(0xFF5C3A1E);
    }
  }

  Color get rarityColor {
    switch (rarity) {
      case BadgeRarity.common:
        return const Color(0xFF6B7280);
      case BadgeRarity.rare:
        return const Color(0xFF3B82F6);
      case BadgeRarity.epic:
        return const Color(0xFF8B5CF6);
      case BadgeRarity.legendary:
        return const Color(0xFFEF4444);
    }
  }

  String get rarityLabel {
    switch (rarity) {
      case BadgeRarity.common:
        return 'Common';
      case BadgeRarity.rare:
        return 'Rare';
      case BadgeRarity.epic:
        return 'Epic';
      case BadgeRarity.legendary:
        return 'Legendary';
    }
  }

  String get tierLabel {
    switch (tier) {
      case BadgeTier.gold:
        return '🥇 Gold';
      case BadgeTier.silver:
        return '🥈 Silver';
      case BadgeTier.bronze:
        return '🥉 Bronze';
    }
  }
}
