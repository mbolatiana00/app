import 'package:app/core/network/dio.client.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/domain/usecases/register.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/result.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';

sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final tokenStorageProvider = Provider(
  (ref) => const TokenStorage(FlutterSecureStorage()),
);

/// Remplace le dioProvider précédent : même client, avec intercepteur.
final dioProvider = Provider<Dio>((ref) {
  final dio = createDio();
  dio.interceptors.add(
    AuthInterceptor(
      ref.read(tokenStorageProvider),
      createDio(),
      () => ref.read(authControllerProvider.notifier).sessionExpired(),
    ),
  );
  return dio;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    AuthRemoteDataSource(ref.read(dioProvider)),
    ref.read(tokenStorageProvider),
  ),
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(_restore);
    return const AuthUnknown();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> _restore() async {
    final result = await RestoreSession(_repo).call();
    state = switch (result) {
      Ok(:final value) when value != null => Authenticated(value),
      _ => const Unauthenticated(),
    };
  }

  /// Retourne null si la connexion réussit, sinon l'erreur à afficher.
  Future<Failure?> login(String email, String password) async {
    final result = await Login(_repo).call(email: email, password: password);
    switch (result) {
      case Ok(:final value):
        state = Authenticated(value);
        return null;
      case Err(:final failure):
        return failure;
    }
  }

  /// Retourne null si l'inscription réussit, sinon l'erreur à afficher.
  Future<Failure?> register(String name, String email, String password) async {
    final result = await Register(_repo)
        .call(name: name, email: email, password: password);
    switch (result) {
      case Ok(:final value):
        state = Authenticated(value);
        return null;
      case Err(:final failure):
        return failure;
    }
  }

  Future<void> logout() async {
    await Logout(_repo).call();
    state = const Unauthenticated();
  }

  void sessionExpired() => state = const Unauthenticated();
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
