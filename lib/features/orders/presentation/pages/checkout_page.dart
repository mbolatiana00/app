import 'package:app/features/orders/presentation/pages/order_confirmation_page.dart';
import 'package:app/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
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
        MaterialPageRoute(
            builder: (_) => OrderConfirmationPage(order: order)),
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
          for (final i in cart.items)
            ListTile(
              dense: true,
              title: Text(i.product.name),
              trailing: Text('${i.quantity} × ${i.product.price.toStringAsFixed(0)} Ar'),
            ),
          const Divider(),
          Text('Total : ${cart.total.toStringAsFixed(0)} Ar',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _address,
            decoration:
                const InputDecoration(labelText: 'Adresse de livraison'),
          ),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Téléphone'),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                state.error is Failure
                    ? (state.error as Failure).message
                    : 'Erreur inconnue',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: state.isLoading ? null : _submit,
            child: state.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Confirmer la commande'),
          ),
        ],
      ),
    );
  }
}