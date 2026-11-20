import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/result.dart';
import '../../domain/usecases/create_order.dart';
import 'orders_provider.dart';

final createOrderProvider = Provider(
  (ref) => CreateOrder(ref.watch(orderRepositoryProvider)),
);

class CreateOrderController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> submit(String title, double total) async {
    state = const AsyncLoading();
    final result = await ref
        .read(createOrderProvider)
        .call(title: title, total: total);

    switch (result) {
      case Ok():
        ref.invalidate(ordersProvider);
        state = const AsyncData(null);
        return true;
      case Err(:final failure):
        state = AsyncError(failure, StackTrace.current);
        return false;
    }
  }
}

final createOrderControllerProvider =
    AsyncNotifierProvider.autoDispose<CreateOrderController, void>(
      CreateOrderController.new,
    );
