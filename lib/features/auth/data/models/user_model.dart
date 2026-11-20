import 'package:app/features/auth/domain/entities/user.dart';

class UserModel {
  final int id;
  final String email;
  final String name;
  const UserModel({required this.id, required this.email, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int,
    email: json['email'] as String,
    name: json['name'] as String,
  );

  User toEntity() => User(id: id, email: email, name: name);
}
