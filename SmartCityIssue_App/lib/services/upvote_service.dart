import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class UpvoteService {
  final _client = SupabaseService.client;
  static const _table = 'issue_upvotes';

  /// Toggle upvote for the current user on [issueId].
  /// Returns true if now upvoted, false if un-voted.
  /// Throws if user tries to vote on their own issue.
  Future<bool> toggleUpvote({
    required String issueId,
    required String issueOwnerId,
  }) async {
    final userId = SupabaseService.userId;
    if (userId == null) throw Exception('Not logged in');

    // Guard: cannot upvote own issue
    if (userId == issueOwnerId) {
      throw Exception('Cannot upvote your own issue');
    }

    final alreadyVoted = await hasUpvoted(issueId);

    if (alreadyVoted) {
      // ── Remove vote ──────────────────────────────────
      await _client
          .from(_table)
          .delete()
          .eq('issue_id', issueId)
          .eq('user_id', userId);

      // Atomic decrement via RPC
      await _client.rpc(
        'decrement_upvote',
        params: {'issue_id': issueId},
      );

      debugPrint('✅ Upvote removed: $issueId');
      return false;
    } else {
      // ── Add vote ─────────────────────────────────────
      await _client.from(_table).insert({
        'issue_id': issueId,
        'user_id': userId,
      });

      // Atomic increment via RPC
      await _client.rpc(
        'increment_upvote',
        params: {'issue_id': issueId},
      );

      debugPrint('✅ Upvote added: $issueId');
      return true;
    }
  }

  /// Check if the current user has upvoted [issueId].
  Future<bool> hasUpvoted(String issueId) async {
    final userId = SupabaseService.userId;
    if (userId == null) return false;

    try {
      final result = await _client
          .from(_table)
          .select('id')
          .eq('issue_id', issueId)
          .eq('user_id', userId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      debugPrint('hasUpvoted error: $e');
      return false;
    }
  }

  /// Fetch the set of issue IDs the current user has upvoted.
  /// Used to bulk-load vote state for a list of issues.
  Future<Set<String>> getMyUpvotedIssueIds() async {
    final userId = SupabaseService.userId;
    if (userId == null) return {};

    try {
      final result = await _client
          .from(_table)
          .select('issue_id')
          .eq('user_id', userId);

      return (result as List)
          .map((row) => row['issue_id'] as String)
          .toSet();
    } catch (e) {
      debugPrint('getMyUpvotedIssueIds error: $e');
      return {};
    }
  }
}
