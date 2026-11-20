import 'package:app/core/result.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/login.dart';

class MockAuthRepo extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepo repo;
  late Login login;
  setUp(() {
    repo = MockAuthRepo();
    login = Login(repo);
  });

  test('refuse un email invalide sans appeler le repository', () async {
    final r = await login(email: 'abc', password: '123456');
    expect(r, isA<Err<User>>());
    verifyNever(
      () => repo.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  test('retourne l’utilisateur si les identifiants sont valides', () async {
    const user = User(id: 1, email: 'a@b.mg', name: 'Mbola');
    when(() => repo.login(email: 'a@b.mg', password: '123456'))
        .thenAnswer((_) async => const Ok(user));
    final r = await login(email: 'a@b.mg', password: '123456');
    expect(r, isA<Ok<User>>());
  });
}
