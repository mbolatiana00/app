import 'package:dio/dio.dart';
import '../models/user_model.dart';

typedef AuthPayload = ({UserModel user, String access, String refresh});

class AuthRemoteDataSource {
  final Dio _dio;
  const AuthRemoteDataSource(this._dio);

  AuthPayload _parse(Response response) {
    final data = response.data as Map<String, dynamic>;
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      access: data['access_token'] as String,
      refresh: data['refresh_token'] as String,
    );
  }

  Future<AuthPayload> login(String email, String password) async => _parse(
      await _dio.post('/auth/login',
          data: {'email': email, 'password': password}));

  Future<AuthPayload> register(String name, String email, String password) async =>
      _parse(await _dio.post('/auth/register',
          data: {'name': name, 'email': email, 'password': password}));

  Future<UserModel> me() async {
    final response = await _dio.get('/auth/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}