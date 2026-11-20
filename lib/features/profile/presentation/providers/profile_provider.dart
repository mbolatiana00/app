import 'package:app/core/result.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/profile/data/models/datasource/profile_remote_datasource.dart';
import 'package:app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:app/features/profile/domain/entities/profile.dart';
import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:app/features/profile/domain/usecases/get_profile.dart';
import 'package:app/features/profile/domain/usecases/update_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) =>
      ProfileRepositoryImpl(ProfileRemoteDatasource(ref.watch(dioProvider))),
);

final profileProvider = FutureProvider.autoDispose<Profile>((ref) async {
  final result = await GetProfile(ref.watch(profileRepositoryProvider)).call();

  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});


class ProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> save({
    required String name,
    required String phone,
    String? address,
  }) async {
    state = const AsyncLoading();
    final result = await UpdateProfile(ref.read(profileRepositoryProvider))
        .call(name: name, phone: phone, address: address);
    switch (result) {
      case Ok():
        ref.invalidate(profileProvider);
        state = const AsyncData(null);
        return true;
      case Err(:final failure):
        state = AsyncError(failure, StackTrace.current);
        return false;
    }
  }
}

final profileControllerProvider =
    AsyncNotifierProvider.autoDispose<ProfileController, void>(
        ProfileController.new);
