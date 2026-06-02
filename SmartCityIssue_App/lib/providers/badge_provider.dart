import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/badge_data.dart';
import '../models/badge_model.dart';
import 'issue_provider.dart';

// ── BADGE PROVIDER ───────────────────────────────────────────────────────────
// Computes badge progress from the user's existing issues.
// Does NOT modify any existing provider or service — read-only derivation.

/// All badges with computed progress and unlock state
final badgesProvider = Provider<List<BadgeModel>>((ref) {
  final issuesAsync = ref.watch(myIssuesStreamProvider);
  final issues = issuesAsync.valueOrNull ?? [];

  final totalReported = issues.length;
  final totalResolved = issues.where((i) => i.status == 'Resolved').length;

  return BadgeData.allBadges.map((badge) {
    // Determine progress based on badge type
    int progress;
    switch (badge.id) {
      // Gold tier
      case 'city_hero':
        progress = totalReported;
        break;
      case 'civic_champion':
        progress = totalResolved;
        break;
      case 'community_legend':
        progress = totalReported; // total contributions = total reported
        break;
      case 'elite_problem_solver':
        progress = totalResolved;
        break;

      // Silver tier
      case 'community_guardian':
        progress = totalReported;
        break;
      case 'active_contributor':
        progress = totalReported;
        break;
      case 'neighborhood_helper':
        progress = totalResolved;
        break;
      case 'impact_maker':
        progress = totalReported;
        break;

      // Bronze tier
      case 'first_reporter':
        progress = totalReported;
        break;
      case 'rising_citizen':
        progress = totalReported;
        break;
      case 'active_user':
        progress = totalReported;
        break;
      case 'community_supporter':
        progress = totalReported;
        break;

      default:
        progress = 0;
    }

    final isUnlocked = progress >= badge.requiredCount;
    return badge.copyWith(
      currentProgress: progress,
      isUnlocked: isUnlocked,
      unlockedAt: isUnlocked ? DateTime.now() : null,
    );
  }).toList();
});

/// Count of earned badges
final earnedBadgesCountProvider = Provider<int>((ref) {
  final badges = ref.watch(badgesProvider);
  return badges.where((b) => b.isUnlocked).length;
});

/// Badges grouped by tier
final goldBadgesProvider = Provider<List<BadgeModel>>((ref) {
  return ref
      .watch(badgesProvider)
      .where((b) => b.tier == BadgeTier.gold)
      .toList();
});

final silverBadgesProvider = Provider<List<BadgeModel>>((ref) {
  return ref
      .watch(badgesProvider)
      .where((b) => b.tier == BadgeTier.silver)
      .toList();
});

final bronzeBadgesProvider = Provider<List<BadgeModel>>((ref) {
  return ref
      .watch(badgesProvider)
      .where((b) => b.tier == BadgeTier.bronze)
      .toList();
});

/// Total badge count
final totalBadgesCountProvider = Provider<int>((ref) {
  return ref.watch(badgesProvider).length;
});
