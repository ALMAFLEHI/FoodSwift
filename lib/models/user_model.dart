class UserModel {
  final String email;
  final String role;
  final String? password;

  UserModel({required this.email, required this.role, this.password});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      if (password != null) 'password': password,
    };
  }
}
