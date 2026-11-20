import 'package:app/core/result.dart';
import 'package:app/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<Result<Profile>> getProfile();
  Future<Result<Profile>> updateProfile({
    required String name,
    required String phone,
    String? address,
  });
}
