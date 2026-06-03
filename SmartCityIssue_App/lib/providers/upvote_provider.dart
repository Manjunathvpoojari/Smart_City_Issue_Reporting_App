import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/upvote_service.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final upvoteServiceProvider =
    Provider<UpvoteService>((ref) => UpvoteService());

// ── Bulk voted-set provider ───────────────────────────────────────────────────
// Loads ALL issue IDs the current user has voted on in one query.
// This is the efficient approach — one DB call for the whole list,
// rather than N calls (one per issue card).

final myUpvotedIssueIdsProvider =
    FutureProvider<Set<String>>((ref) async {
  return ref.read(upvoteServiceProvider).getMyUpvotedIssueIds();
});

// ── Per-issue upvote notifier ─────────────────────────────────────────────────
// Manages optimistic UI state for a single issue's upvote button.
// Optimistic = UI updates instantly, DB call happens in background.

class UpvoteNotifier extends StateNotifier<UpvoteState> {
  final UpvoteService _service;
  final String issueId;
  final String issueOwnerId;
  final Ref _ref;

  UpvoteNotifier({
    required UpvoteService service,
    required this.issueId,
    required this.issueOwnerId,
    required Ref ref,
    required bool initiallyVoted,
    required int initialCount,
  })  : _service = service,
        _ref = ref,
        super(UpvoteState(
          isVoted: initiallyVoted,
          count: initialCount,
          isLoading: false,
          error: null,
        ));

  Future<void> toggle() async {
    if (state.isLoading) return;

    // ── Optimistic update: flip state immediately ──────────────
    final wasVoted = state.isVoted;
    final prevCount = state.count;
    state = state.copyWith(
      isVoted: !wasVoted,
      count: wasVoted ? prevCount - 1 : prevCount + 1,
      isLoading: true,
      error: null,
    );

    try {
      await _service.toggleUpvote(
        issueId: issueId,
        issueOwnerId: issueOwnerId,
      );
      // Confirm optimistic state, clear loading
      state = state.copyWith(isLoading: false);

      // Invalidate the bulk set so other screens stay in sync
      _ref.invalidate(myUpvotedIssueIdsProvider);
    } catch (e) {
      // ── Rollback on failure ────────────────────────────────
      state = state.copyWith(
        isVoted: wasVoted,
        count: prevCount,
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

class UpvoteState {
  final bool isVoted;
  final int count;
  final bool isLoading;
  final String? error;

  const UpvoteState({
    required this.isVoted,
    required this.count,
    required this.isLoading,
    this.error,
  });

  UpvoteState copyWith({
    bool? isVoted,
    int? count,
    bool? isLoading,
    String? error,
  }) =>
      UpvoteState(
        isVoted: isVoted ?? this.isVoted,
        count: count ?? this.count,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// Factory: creates a notifier for a specific issue
// Key = issueId so each issue gets its own independent state

final upvoteNotifierProvider = StateNotifierProvider.family<
    UpvoteNotifier, UpvoteState, UpvoteProviderParams>(
  (ref, params) {
    // Check if the user already voted (from the bulk-loaded set)
    final votedIds =
        ref.watch(myUpvotedIssueIdsProvider).valueOrNull ?? {};
    final alreadyVoted = votedIds.contains(params.issueId);

    return UpvoteNotifier(
      service: ref.read(upvoteServiceProvider),
      issueId: params.issueId,
      issueOwnerId: params.issueOwnerId,
      ref: ref,
      initiallyVoted: alreadyVoted,
      initialCount: params.initialCount,
    );
  },
);

// Parameter class for the family provider
class UpvoteProviderParams {
  final String issueId;
  final String issueOwnerId;
  final int initialCount;

  const UpvoteProviderParams({
    required this.issueId,
    required this.issueOwnerId,
    required this.initialCount,
  });

  @override
  bool operator ==(Object other) =>
      other is UpvoteProviderParams &&
      other.issueId == issueId &&
      other.issueOwnerId == issueOwnerId;

  @override
  int get hashCode => Object.hash(issueId, issueOwnerId);
}
