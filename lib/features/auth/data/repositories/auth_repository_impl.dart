import 'package:app/features/auth/domain/entities/user.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final TokenStorage _tokens;
  const AuthRepositoryImpl(this._remote, this._tokens);

  Failure _map(DioException e) {
    if (e.response?.statusCode == 401) {
      return const UnAuthorizeFailure('Email ou mot de passe incorrect');
    }
    if (e.response?.statusCode == 409) {
      return const ValidationFailure('Cet email est déjà utilisé');
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    return const ServerFailure();
  }

  Future<Result<User>> _authenticate(
    Future<AuthPayload> Function() call,
  ) async {
    try {
      final p = await call();
      await _tokens.save(p.access, p.refresh);
      return Ok(p.user.toEntity());
    } on DioException catch (e) {
      return Err(_map(e));
    } catch (_) {
      return const Err(ServerFailure());
    }
  }

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) => _authenticate(() => _remote.login(email, password));

  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  }) => _authenticate(() => _remote.register(name, email, password));

  @override
  Future<Result<User?>> restoreSession() async {
    if (await _tokens.access == null) return const Ok(null);
    try {
      return Ok((await _remote.me()).toEntity());
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokens.clear();
        return const Ok(null);
      }
      return Err(_map(e));
    }
  }

  @override
  Future<void> logout() => _tokens.clear();
}
