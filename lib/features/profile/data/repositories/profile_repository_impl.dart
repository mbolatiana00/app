import 'package:app/core/error/failure.dart';
import 'package:app/core/result.dart';
import 'package:app/features/profile/data/models/datasource/profile_remote_datasource.dart';
import 'package:app/features/profile/domain/entities/profile.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:dio/dio.dart';

class ProfileRepositoryImpl implements ProfileRepository {

  final ProfileRemoteDatasource _profileRemoteDatasource;
  const ProfileRepositoryImpl(this._profileRemoteDatasource);
  Failure _map(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401) return const UnAuthorizeFailure();
    if (code == 409) {
      return const ValidationFailure('Ce numéro est déjà utilisé');
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    return const ServerFailure();
  }
  @override
  Future<Result<Profile>> getProfile() async   {
  try{
    final m = await _profileRemoteDatasource.fetch();
    return Ok(m.toEntity());
  } on DioException catch (e){
    return Err(_map(e));
  } catch (_){
    return const Err(ServerFailure());
  }
    
  }

  @override
  Future<Result<Profile>> updateProfile({
    required String name,
     required String phone, 
     String? address}) async {
      try{
        final m = await _profileRemoteDatasource.update(name: name, phone: phone, address: address);
        return Ok(m.toEntity());
      } on DioException catch (e){
        return Err(_map(e));
      } catch (_){
        return const Err(ServerFailure());
      }
   
  }
}
