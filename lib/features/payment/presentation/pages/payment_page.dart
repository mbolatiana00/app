import 'package:app/features/orders/domain/entities/placed_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/payment_provider.dart';
import '../providers/payment_provider.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final PlacedOrder order;
  const PaymentPage({super.key, required this.order});
  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final _phone = TextEditingController();
  PaymentProvider _provider = PaymentProvider.mvola;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentControllerProvider);
    final controller = ref.read(paymentControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Paiement — commande n° ${widget.order.id}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: switch (state.phase) {
          PaymentPhase.submitting => const Center(
            child: CircularProgressIndicator(),
          ),
          PaymentPhase.waiting => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text(
                  'Confirmez le paiement sur votre téléphone',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text('En attente de la confirmation de l\u2019opérateur…'),
              ],
            ),
          ),
          PaymentPhase.success => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 72, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Paiement réussi',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Terminer'),
                ),
              ],
            ),
          ),
          _ => ListView(
            children: [
              Text(
                'Montant : ${widget.order.total.toStringAsFixed(0)} Ar',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              RadioGroup<PaymentProvider>(
                groupValue: _provider,
                onChanged: (value) {
                  if (value != null) setState(() => _provider = value);
                },
                child: Column(
                  children: [
                    for (final p in PaymentProvider.values)
                      RadioListTile<PaymentProvider>(
                        value: p,
                        title: Text(p.label),
                      ),
                  ],
                ),
              ),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro ${_provider.label}',
                ),
              ),
              if (state.phase == PaymentPhase.failed)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    state.message ?? 'Paiement échoué',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => controller.pay(
                  orderId: widget.order.id,
                  provider: _provider,
                  phone: _phone.text,
                ),
                child: Text(
                  state.phase == PaymentPhase.failed ? 'Réessayer' : 'Payer',
                ),
              ),
            ],
          ),
        },
      ),
    );
  }
}
