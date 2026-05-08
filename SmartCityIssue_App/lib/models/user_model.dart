class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.fcmToken,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? 'citizen',
    fcmToken: json['fcm_token'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'fcm_token': fcmToken,
    'created_at': createdAt.toIso8601String(),
  };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? fcmToken,
    DateTime? createdAt,
  }) => UserModel(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    role: role ?? this.role,
    fcmToken: fcmToken ?? this.fcmToken,
    createdAt: createdAt ?? this.createdAt,
  );
}
