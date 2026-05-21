import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/issue_model.dart';
import '../services/issue_service.dart';

final issueServiceProvider = Provider<IssueService>((ref) => IssueService());

// ── CITIZEN PROVIDERS ────────────────────────────────────────────────────────

/// Stream of current user's issues (realtime)
final myIssuesStreamProvider = StreamProvider<List<IssueModel>>((ref) {
  return ref.watch(issueServiceProvider).streamMyIssues();
});

/// Stream of ALL issues for map (realtime)
final allIssuesStreamProvider = StreamProvider<List<IssueModel>>((ref) {
  return ref.watch(issueServiceProvider).streamAllIssues();
});

// ── FILTER STATE ─────────────────────────────────────────────────────────────

class FilterState {
  final String category;
  final String status;
  final String search;

  const FilterState({
    this.category = 'All',
    this.status = 'All',
    this.search = '',
  });

  FilterState copyWith({String? category, String? status, String? search}) =>
      FilterState(
        category: category ?? this.category,
        status: status ?? this.status,
        search: search ?? this.search,
      );
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setCategory(String c) => state = state.copyWith(category: c);
  void setStatus(String s) => state = state.copyWith(status: s);
  void setSearch(String q) => state = state.copyWith(search: q);
  void reset() => state = const FilterState();
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (ref) => FilterNotifier(),
);

// ── ADMIN PROVIDERS ──────────────────────────────────────────────────────────

/// Admin: all issues with current filters
final adminIssuesProvider = FutureProvider.autoDispose<List<IssueModel>>((ref) async {
  final service = ref.watch(issueServiceProvider);
  final filter = ref.watch(filterProvider);
  return service.getAdminIssues(
    category: filter.category,
    status: filter.status,
    search: filter.search,
  );
});

/// Admin: issue counts per status
final issueCountsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) {
  return ref.watch(issueServiceProvider).getIssueCounts();
});
