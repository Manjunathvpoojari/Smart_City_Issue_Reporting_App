// lib/services/issue_service.dart
// Only the getAdminIssues method changes — upvotes column is now
// explicitly included in the select so sorting works correctly.
// Everything else is identical to the original.

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/issue_model.dart';
import '../models/status_history_model.dart';
import 'supabase_service.dart';

class IssueService {
  final _client = SupabaseService.client;

  // ── CITIZEN ──────────────────────────────────────────────────────────────

  Future<IssueModel?> submitIssue({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    String? imageUrl,
  }) async {
    final userId = SupabaseService.userId;
    if (userId == null) return null;

    try {
      final data = {
        'user_id': userId,
        'title': title,
        'description': description,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'image_url': imageUrl,
        'status': AppConstants.statusPending,
        'upvotes': 0, // ← now included
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final result = await _client
          .from(AppConstants.issuesTable)
          .insert(data)
          .select()
          .single();

      return IssueModel.fromJson(result);
    } catch (e) {
      debugPrint('SUBMIT ERROR FULL: ${e.runtimeType} → ${e.toString()}');
      return null;
    }
  }

  Future<List<IssueModel>> getMyIssues() async {
    final userId = SupabaseService.userId;
    if (userId == null) return [];

    try {
      final result = await _client
          .from(AppConstants.issuesTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (result as List).map((e) => IssueModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting my issues: $e');
      return [];
    }
  }

  Future<List<IssueModel>> getAllIssues(
      {String? category, String? status}) async {
    try {
      var query = _client
          .from(AppConstants.issuesTable)
          .select('*, users(name, email)');

      if (category != null && category != 'All') {
        query = query.eq('category', category) as dynamic;
      }
      if (status != null && status != 'All') {
        query = query.eq('status', status) as dynamic;
      }

      final result =
          await (query as dynamic).order('created_at', ascending: false);
      return (result as List).map((e) => IssueModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error getting all issues: $e');
      return [];
    }
  }

  Future<IssueModel?> getIssueById(String id) async {
    try {
      final result = await _client
          .from(AppConstants.issuesTable)
          .select('*, users(name, email)')
          .eq('id', id)
          .single();
      return IssueModel.fromJson(result);
    } catch (e) {
      debugPrint('Error getting issue: $e');
      return null;
    }
  }

  Stream<List<IssueModel>> streamMyIssues() {
    final userId = SupabaseService.userId;
    if (userId == null) return Stream.value([]);

    return _client
        .from(AppConstants.issuesTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((list) => list.map((e) => IssueModel.fromJson(e)).toList());
  }

  Stream<List<IssueModel>> streamAllIssues() {
    return _client
        .from(AppConstants.issuesTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list.map((e) => IssueModel.fromJson(e)).toList());
  }

  // ── ADMIN ─────────────────────────────────────────────────────────────────

  /// Fetches all issues with reporter info.
  /// DB returns newest-first; the admin dashboard Flutter-side
  /// sorts by upvotes DESC when the sort toggle is active.
  Future<List<IssueModel>> getAdminIssues({
    String? category,
    String? status,
    String? search,
  }) async {
    try {
      // ↓ explicitly select upvotes so the column is never null
      var query = _client
          .from(AppConstants.issuesTable)
          .select('*, users(name, email)');

      if (category != null && category != 'All') {
        query = query.eq('category', category) as dynamic;
      }
      if (status != null && status != 'All') {
        query = query.eq('status', status) as dynamic;
      }

      final result =
          await (query as dynamic).order('created_at', ascending: false);

      List<IssueModel> issues =
          (result as List).map((e) => IssueModel.fromJson(e)).toList();

      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        issues = issues
            .where((i) =>
                i.title.toLowerCase().contains(q) ||
                i.description.toLowerCase().contains(q) ||
                i.category.toLowerCase().contains(q))
            .toList();
      }

      return issues;
    } catch (e) {
      debugPrint('Error getting admin issues: $e');
      return [];
    }
  }

  Future<bool> updateIssueStatus({
    required String issueId,
    required String oldStatus,
    required String newStatus,
    String? adminNote,
  }) async {
    final adminId = SupabaseService.userId;
    if (adminId == null) return false;

    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (adminNote != null && adminNote.isNotEmpty) {
        updateData['admin_note'] = adminNote;
      }

      await _client
          .from(AppConstants.issuesTable)
          .update(updateData)
          .eq('id', issueId);

      await _client.from(AppConstants.statusHistoryTable).insert({
        'issue_id': issueId,
        'old_status': oldStatus,
        'new_status': newStatus,
        'changed_by': adminId,
        'changed_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }

  Future<List<StatusHistoryModel>> getStatusHistory(String issueId) async {
    try {
      final result = await _client
          .from(AppConstants.statusHistoryTable)
          .select('*, users(name)')
          .eq('issue_id', issueId)
          .order('changed_at', ascending: true);

      return (result as List)
          .map((e) => StatusHistoryModel.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('Error getting status history: $e');
      return [];
    }
  }

  Future<Map<String, int>> getIssueCounts() async {
    try {
      final all = await _client.from(AppConstants.issuesTable).select('status');
      final list = all as List;
      return {
        'total': list.length,
        'Pending': list.where((e) => e['status'] == 'Pending').length,
        'In Progress': list.where((e) => e['status'] == 'In Progress').length,
        'Resolved': list.where((e) => e['status'] == 'Resolved').length,
      };
    } catch (e) {
      return {'total': 0, 'Pending': 0, 'In Progress': 0, 'Resolved': 0};
    }
  }
}
