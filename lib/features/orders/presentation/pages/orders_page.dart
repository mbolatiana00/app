import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ui.dart';
import '../providers/orders_provider.dart';
import 'create_order_page.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const PageTitle('Mes commandes'),
            Expanded(
              child: orders.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => EmptyState(
                  icon: Icons.wifi_off_rounded,
                  message: error is Failure ? error.message : 'Erreur inconnue',
                  actionLabel: 'Réessayer',
                  onAction: () => ref.invalidate(ordersProvider),
                ),
                data: (items) => items.isEmpty
                    ? const EmptyState(
                        icon: Icons.receipt_long_outlined,
                        message: 'Aucune commande',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final order = items[index];
                          final d = order.createdAt.toLocal();
                          String two(int v) => v.toString().padLeft(2, '0');
                          return AppCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        order.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    Text(
                                      '${two(d.day)}/${two(d.month)}/${d.year}',
                                      style: const TextStyle(
                                        color: AppColors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text(
                                      'N° : ',
                                      style: TextStyle(color: AppColors.grey),
                                    ),
                                    Text('${order.id}'),
                                    const Spacer(),
                                    const Text(
                                      'Montant : ',
                                      style: TextStyle(color: AppColors.grey),
                                    ),
                                    Text(
                                      '${order.total.toStringAsFixed(0)} Ar',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${two(d.hour)}:${two(d.minute)}',
                                  style: const TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
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
