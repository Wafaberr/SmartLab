class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'].toString(),
    name: (json['username'] ?? json['name'] ?? '') as String,
    email: json['email'] as String? ?? '',
  );
  Map<String, dynamic> toJson() {
    return {'id': id,'name':name,'email':email};
  }
}
