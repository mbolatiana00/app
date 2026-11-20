import '../../../../core/error/failure.dart';
import '../../../../core/result.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CreateOrder {
  final OrderRepository _repository;

  const CreateOrder(this._repository);

  Future<Result<Order>> call({required String title, required double total}) {
    if (title.trim().isEmpty) {
      return Future.value(const Err(ValidationFailure('Titre obligatoire')));
    }
    if (total <= 0) {
      return Future.value(
        const Err(ValidationFailure('Le total doit être positif')),
      );
    }
    return _repository.createOrder(title: title.trim(), total: total);
  }
}
