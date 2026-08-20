class User {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? image;
  final bool isActive;
  final bool? isStaff;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.image,
    required this.isActive,
     this.isStaff,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',

      username: json['username'] ?? '',

      email: json['email'] ?? '',

      firstName: json['first_name'] ?? '',

      lastName: json['last_name'] ?? '',

      role: json['role'] ?? 'tech',

      image: json['image'],

      isActive: json['is_active'] ?? true,

      isStaff: json['is_staff'] ?? false,

      createdAt: json['created_at'],

      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'image': image,
      'is_active': isActive,
      'is_staff': isStaff,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get fullName {
    final name = '$firstName $lastName'.trim();

    if (name.isEmpty) {
      return username;
    }

    return name;
  }

  bool get isAdmin => role == 'admin';

  bool get isTechnician => role == 'tech';
}