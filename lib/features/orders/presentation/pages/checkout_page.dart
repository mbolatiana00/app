import 'package:app/features/orders/presentation/pages/order_confirmation_page.dart';
import 'package:app/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ui.dart';
import '../../../Panier/presentation/providers/cart_provider.dart';
import '../providers/checkout_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});
  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _address = TextEditingController();
  final _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  /// Préremplit avec le profil, sans bloquer si le profil est indisponible.
  Future<void> _prefill() async {
    try {
      final p = await ref.read(profileProvider.future);
      if (!mounted) return;
      if (_address.text.isEmpty) _address.text = p.address ?? '';
      if (_phone.text.isEmpty) _phone.text = p.phone ?? '';
    } catch (_) {}
  }

  @override
  void dispose() {
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final order = await ref
        .read(checkoutControllerProvider.notifier)
        .submit(address: _address.text, phone: _phone.text);
    if (order != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderConfirmationPage(order: order)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final state = ref.watch(checkoutControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Finaliser la commande')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Récapitulatif'),
          AppCard(
            child: Column(
              children: [
                for (final i in cart.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(child: Text(i.product.name)),
                        Text(
                          '${i.quantity} × ${i.product.price.toStringAsFixed(0)} Ar',
                          style: const TextStyle(color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Text(
                      'Total :',
                      style: TextStyle(color: AppColors.grey, fontSize: 16),
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
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Livraison'),
          ShadowField(
            child: TextField(
              controller: _address,
              decoration: const InputDecoration(
                labelText: 'Adresse de livraison',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
          ),
          ShadowField(
            child: TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
          ),
          if (state.hasError)
            ErrorText(
              state.error is Failure
                  ? (state.error as Failure).message
                  : 'Erreur inconnue',
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: state.isLoading ? null : _submit,
            child: ButtonLabel(
              'Confirmer la commande',
              loading: state.isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
