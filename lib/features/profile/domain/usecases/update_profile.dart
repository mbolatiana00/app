import 'package:app/core/error/failure.dart';
import 'package:app/core/result.dart';
import 'package:app/features/profile/domain/entities/profile.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository _profileRepository;
  const UpdateProfile(this._profileRepository);

  static final _phone = RegExp(r'^(032|033|034|037|038)\d{7}$');

  Future<Result<Profile>> call({
    required String name,
    required String phone,
    String? address,
  }){
 final cleanPhone = phone.replaceAll(' ', '');
    if (name.trim().isEmpty) {
      return Future.value(const Err(ValidationFailure('Nom obligatoire')));
    }
    if (!_phone.hasMatch(cleanPhone)) {
      return Future.value(const Err(ValidationFailure(
          'Téléphone invalide (ex : 034 12 345 67)')));
    }
    final addr = address?.trim();
    return _profileRepository.updateProfile(
      name: name.trim(),
      phone: cleanPhone,
      address: (addr == null || addr.isEmpty) ? null : addr,
    );
  }
}
