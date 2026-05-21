class IssueModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final String status;
  final String? adminNote;
  final int upvotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? reporterName;
  final String? reporterEmail;

  const IssueModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.adminNote,
    this.upvotes = 0,
    required this.createdAt,
    required this.updatedAt,
    this.reporterName,
    this.reporterEmail,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) => IssueModel(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    category: json['category'] as String? ?? 'Other',
    imageUrl: json['image_url'] as String?,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    status: json['status'] as String? ?? 'Pending',
    adminNote: json['admin_note'] as String?,
    upvotes: json['upvotes'] as int? ?? 0,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    reporterName: json['users']?['name'] as String?,
    reporterEmail: json['users']?['email'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'description': description,
    'category': category,
    'image_url': imageUrl,
    'latitude': latitude,
    'longitude': longitude,
    'status': status,
    'admin_note': adminNote,
    'upvotes': upvotes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  IssueModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? status,
    String? adminNote,
    int? upvotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? reporterName,
    String? reporterEmail,
  }) => IssueModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    imageUrl: imageUrl ?? this.imageUrl,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    status: status ?? this.status,
    adminNote: adminNote ?? this.adminNote,
    upvotes: upvotes ?? this.upvotes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    reporterName: reporterName ?? this.reporterName,
    reporterEmail: reporterEmail ?? this.reporterEmail,
  );
}
