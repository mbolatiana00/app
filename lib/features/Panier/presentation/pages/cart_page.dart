import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ui.dart';
import '../../../orders/presentation/pages/checkout_page.dart';
import '../providers/cart_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const PageTitle('Mon panier'),
            Expanded(
              child: cart.isEmpty
                  ? const EmptyState(
                      icon: Icons.shopping_bag_outlined,
                      message: 'Votre panier est vide',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        for (final item in cart.items)
                          AppCard(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.zero,
                            child: SizedBox(
                              height: 104,
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(8),
                                    ),
                                    child: SizedBox(
                                      width: 104,
                                      height: 104,
                                      child: ProductImage(
                                        item.product.imageUrl,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        10,
                                        12,
                                        8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          Text(
                                            '${item.product.price.toStringAsFixed(0)} Ar / unité',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              _QtyButton(
                                                icon: Icons.remove,
                                                onTap: () =>
                                                    controller.setQuantity(
                                                      item.product,
                                                      item.quantity - 1,
                                                    ),
                                              ),
                                              SizedBox(
                                                width: 36,
                                                child: Text(
                                                  '${item.quantity}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              _QtyButton(
                                                icon: Icons.add,
                                                onTap: () {
                                                  final f = controller
                                                      .setQuantity(
                                                        item.product,
                                                        item.quantity + 1,
                                                      );
                                                  if (f != null) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          f.message,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                              const Spacer(),
                                              Text(
                                                '${item.subtotal.toStringAsFixed(0)} Ar',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Montant total :',
                          style: TextStyle(color: AppColors.grey, fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          '${cart.total.toStringAsFixed(0)} Ar',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckoutPage()),
                      ),
                      child: const ButtonLabel('Commander'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    shape: const CircleBorder(),
    elevation: 2,
    shadowColor: Colors.black26,
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: AppColors.grey),
      ),
    ),
  );
}
