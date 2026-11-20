import 'package:app/core/result.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/core/error/failure.dart';

class Login {
  final AuthRepository _authRepository;
  const Login(this._authRepository);

  Future<Result<User>> call({required String email, required String password}) {
    final e = email.trim();
    if (!e.contains('@') || !e.contains('.')) {
      return Future.value(const Err(ValidationFailure('email invalide')));
    }
    if (password.length < 6) {
      return Future.value(
        const Err(ValidationFailure('Mot de passe : 6 caracteres minimum')),
      );
    }
    return _authRepository.login(email: e, password: password);
  }
}
