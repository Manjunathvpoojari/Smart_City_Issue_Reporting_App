import 'package:flutter/material.dart';
import 'badge_model.dart';

/// All 12 badge definitions for the Smart City app.
/// Progress & unlock state is computed at runtime by the provider.
class BadgeData {
  BadgeData._();

  static const List<BadgeModel> allBadges = [
    // ── 🥇 GOLD TIER ───────────────────────────────────────────────────────
    BadgeModel(
      id: 'city_hero',
      title: 'City Hero',
      description:
          'You\'ve reported 50 city issues and made a massive impact on improving urban life.',
      requirement: 'Report 50 issues',
      icon: Icons.military_tech_rounded,
      tier: BadgeTier.gold,
      rarity: BadgeRarity.legendary,
      requiredCount: 50,
    ),
    BadgeModel(
      id: 'civic_champion',
      title: 'Civic Champion',
      description:
          'An extraordinary civic leader — 40 of your reported issues have been resolved.',
      requirement: '40 issues resolved',
      icon: Icons.emoji_events_rounded,
      tier: BadgeTier.gold,
      rarity: BadgeRarity.legendary,
      requiredCount: 40,
    ),
    BadgeModel(
      id: 'community_legend',
      title: 'Community Legend',
      description:
          'A legendary contributor with 100 total civic interactions. You are the backbone of this community.',
      requirement: '100 total contributions',
      icon: Icons.auto_awesome_rounded,
      tier: BadgeTier.gold,
      rarity: BadgeRarity.epic,
      requiredCount: 100,
    ),
    BadgeModel(
      id: 'elite_problem_solver',
      title: 'Elite Problem Solver',
      description:
          'An elite resolver — 30 issues resolved prove your dedication to making the city better.',
      requirement: '30 issues resolved',
      icon: Icons.workspace_premium_rounded,
      tier: BadgeTier.gold,
      rarity: BadgeRarity.legendary,
      requiredCount: 30,
    ),

    // ── 🥈 SILVER TIER ──────────────────────────────────────────────────────
    BadgeModel(
      id: 'community_guardian',
      title: 'Community Guardian',
      description:
          'A vigilant guardian who keeps an eye on 25 neighborhood issues.',
      requirement: 'Report 25 issues',
      icon: Icons.shield_rounded,
      tier: BadgeTier.silver,
      rarity: BadgeRarity.epic,
      requiredCount: 25,
    ),
    BadgeModel(
      id: 'active_contributor',
      title: 'Active Contributor',
      description:
          'Consistently contributing with 20 reported issues. Your voice matters.',
      requirement: 'Report 20 issues',
      icon: Icons.trending_up_rounded,
      tier: BadgeTier.silver,
      rarity: BadgeRarity.rare,
      requiredCount: 20,
    ),
    BadgeModel(
      id: 'neighborhood_helper',
      title: 'Neighborhood Helper',
      description:
          '15 resolved issues — you\'re the helper everyone wishes they had.',
      requirement: '15 issues resolved',
      icon: Icons.handshake_rounded,
      tier: BadgeTier.silver,
      rarity: BadgeRarity.rare,
      requiredCount: 15,
    ),
    BadgeModel(
      id: 'impact_maker',
      title: 'Impact Maker',
      description:
          'Your reports create real impact — 10 high-priority issues addressed.',
      requirement: 'Report 10 issues',
      icon: Icons.bolt_rounded,
      tier: BadgeTier.silver,
      rarity: BadgeRarity.epic,
      requiredCount: 10,
    ),

    // ── 🥉 BRONZE TIER ──────────────────────────────────────────────────────
    BadgeModel(
      id: 'first_reporter',
      title: 'First Reporter',
      description:
          'You took the first step! Your very first issue report makes you a civic contributor.',
      requirement: 'Report your first issue',
      icon: Icons.flag_rounded,
      tier: BadgeTier.bronze,
      rarity: BadgeRarity.common,
      requiredCount: 1,
    ),
    BadgeModel(
      id: 'rising_citizen',
      title: 'Rising Citizen',
      description:
          'A rising star in civic engagement — 5 issues reported and counting.',
      requirement: 'Report 5 issues',
      icon: Icons.rocket_launch_rounded,
      tier: BadgeTier.bronze,
      rarity: BadgeRarity.common,
      requiredCount: 5,
    ),
    BadgeModel(
      id: 'active_user',
      title: 'Active User',
      description:
          'You\'re an active member of the community with 3 reported issues.',
      requirement: 'Report 3 issues',
      icon: Icons.local_fire_department_rounded,
      tier: BadgeTier.bronze,
      rarity: BadgeRarity.rare,
      requiredCount: 3,
    ),
    BadgeModel(
      id: 'community_supporter',
      title: 'Community Supporter',
      description:
          'A reliable supporter with 10 issues reported. Your dedication shines.',
      requirement: 'Report 10 issues',
      icon: Icons.volunteer_activism_rounded,
      tier: BadgeTier.bronze,
      rarity: BadgeRarity.common,
      requiredCount: 10,
    ),
  ];

  static List<BadgeModel> get goldBadges =>
      allBadges.where((b) => b.tier == BadgeTier.gold).toList();

  static List<BadgeModel> get silverBadges =>
      allBadges.where((b) => b.tier == BadgeTier.silver).toList();

  static List<BadgeModel> get bronzeBadges =>
      allBadges.where((b) => b.tier == BadgeTier.bronze).toList();
}
