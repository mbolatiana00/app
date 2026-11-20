// register.dart : même validation que Login + nom non vide
import 'package:app/core/error/failure.dart';
import 'package:app/core/result.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart'
    show AuthRepository;

class Register {
  final AuthRepository _repository;
  const Register(this._repository);

  Future<Result<User>> call({
    required String name,
    required String email,
    required String password,
  }) {
    if (name.trim().isEmpty) {
      return Future.value(const Err(ValidationFailure('Nom obligatoire')));
    }
    if (!email.contains('@') || password.length < 6) {
      return Future.value(const Err(ValidationFailure('Données invalides')));
    }
    return _repository.register(
      name: name.trim(),
      email: email.trim(),
      password: password,
    );
  }
}

// restore_session.dart
class RestoreSession {
  final AuthRepository _repository;
  const RestoreSession(this._repository);
  Future<Result<User?>> call() => _repository.restoreSession();
}

// logout.dart
class Logout {
  final AuthRepository _repository;
  const Logout(this._repository);
  Future<void> call() => _repository.logout();
}
