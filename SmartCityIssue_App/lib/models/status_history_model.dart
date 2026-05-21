class StatusHistoryModel {
  final String id;
  final String issueId;
  final String oldStatus;
  final String newStatus;
  final String changedBy;
  final DateTime changedAt;

  // Joined
  final String? adminName;

  const StatusHistoryModel({
    required this.id,
    required this.issueId,
    required this.oldStatus,
    required this.newStatus,
    required this.changedBy,
    required this.changedAt,
    this.adminName,
  });

  factory StatusHistoryModel.fromJson(Map<String, dynamic> json) => StatusHistoryModel(
    id: json['id'] as String,
    issueId: json['issue_id'] as String,
    oldStatus: json['old_status'] as String? ?? '',
    newStatus: json['new_status'] as String? ?? '',
    changedBy: json['changed_by'] as String? ?? '',
    changedAt: DateTime.parse(json['changed_at'] as String),
    adminName: json['users']?['name'] as String?,
  );
}
