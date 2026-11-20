import 'package:app/core/result.dart';
import 'package:app/features/profile/domain/entities/profile.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:app/features/profile/domain/usecases/update_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';


class MockProfileRepo extends Mock implements ProfileRepository {}

void main() {
  late MockProfileRepo repo;
  late UpdateProfile usecase;
  setUp(() {
    repo = MockProfileRepo();
    usecase = UpdateProfile(repo);
  });

  test('refuse un téléphone invalide', () async {
    final r = await usecase(name: 'Mbola', phone: '0612345678');
    expect(r, isA<Err<Profile>>());
  });

  test('accepte un numéro avec espaces et le nettoie', () async {
    const p = Profile(id: 1, name: 'Mbola', email: 'a@b.mg', phone: '0341234567');
    when(() => repo.updateProfile(
          name: 'Mbola',
          phone: '0341234567',
          address: null,
        )).thenAnswer((_) async => const Ok(p));
    final r = await usecase(name: 'Mbola', phone: '034 12 345 67');
    expect(r, isA<Ok<Profile>>());
  });
}