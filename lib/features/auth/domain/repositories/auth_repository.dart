import 'package:app/core/result.dart';
import 'package:app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login({required String email, required String password});
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Result<User?>> restoreSession();
  Future<void> logout();
}
