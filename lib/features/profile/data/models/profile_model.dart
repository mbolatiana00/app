import 'package:app/features/profile/domain/entities/profile.dart';

class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.address,
    this.phone,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String?,
    address: json['address'] as String?,
  );
  Profile toEntity() => Profile(id: id, name: name, email: email, address: address, phone: phone);
}
