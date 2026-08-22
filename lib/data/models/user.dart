class User {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String bio;
  final String role;
  final List<String> preferences;
  final int createdAt;
  final bool active;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.bio = '',
    this.role = ROLE_USER,
    this.preferences = const [],
    required this.createdAt,
    this.active = true,
  });

  bool get isAdmin => role == ROLE_ADMIN;
  bool get isAuthor => bio.isNotEmpty;
  bool get isActive => active;

  static const String ROLE_USER = 'user';
  static const String ROLE_ADMIN = 'admin';

  factory User.fromMap(Map<String, dynamic> map) {
    final prefsStr = map['preferences'] as String? ?? '';
    final prefs = prefsStr.isEmpty
        ? <String>[]
        : prefsStr.split(',').map((s) => s.trim()).toList();

    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      role: map['role'] as String? ?? ROLE_USER,
      preferences: prefs,
      createdAt: map['createdAt'] as int,
      active: (map['active'] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'role': role,
      'preferences': preferences.join(','),
      'createdAt': createdAt,
      'active': active ? 1 : 0,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? bio,
    String? role,
    List<String>? preferences,
    int? createdAt,
    bool? active,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
    );
  }
}
