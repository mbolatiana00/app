import 'package:flutter/material.dart';

import '../../../payment/presentation/pages/payment_page.dart';
import '../../domain/entities/placed_order.dart';

class OrderConfirmationPage extends StatelessWidget {
  final PlacedOrder order;
  const OrderConfirmationPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commande enregistrée'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 72, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Commande n° ${order.id}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${order.total.toStringAsFixed(0)} Ar — en attente de paiement',
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PaymentPage(order: order)),
              ),
              child: const Text('Payer maintenant'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Text('Retour à l’accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
