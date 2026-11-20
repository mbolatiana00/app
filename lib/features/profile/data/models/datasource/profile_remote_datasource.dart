import 'package:app/features/profile/data/models/profile_model.dart';
import 'package:dio/dio.dart';

class ProfileRemoteDatasource {
  final Dio _dio;
  const ProfileRemoteDatasource(this._dio);

  Future<ProfileModel> fetch() async {
    final r = await _dio.get('/users/me');
    return ProfileModel.fromJson(r.data as Map<String, dynamic>);
  }

  Future<ProfileModel> update({
    required String name,
    required String phone,
    String? address,
  })async {
    final r = await _dio.put('/users/me', data: {
      'name': name,
      'phone': phone,
      'address': address,
    });
    return ProfileModel.fromJson(r.data as Map<String, dynamic>);
  }
}
