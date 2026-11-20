import 'package:app/core/result.dart';
import 'package:app/features/profile/domain/entities/profile.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository _profileRepository;
  const GetProfile(this._profileRepository);

  Future<Result<Profile>> call() => _profileRepository.getProfile();
}
