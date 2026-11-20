import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../providers/orders_provider.dart';
import 'create_order_page.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error is Failure ? error.message : 'Erreur inconnue'),
              TextButton(
                onPressed: () => ref.invalidate(ordersProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Aucune commande'))
            : ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final order = items[index];
                  return ListTile(
                    title: Text(order.title),
                    subtitle: Text(order.createdAt.toLocal().toString()),
                    trailing: Text('${order.total.toStringAsFixed(0)} Ar'),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateOrderPage()),
        ),
        tooltip: 'Nouvelle commande',
        child: const Icon(Icons.add),
      ),
    );
  }
}
