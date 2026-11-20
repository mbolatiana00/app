import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ui.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const ResultIcon(),
              const SizedBox(height: 32),
              Text(
                'Commande n° ${order.id}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${order.total.toStringAsFixed(0)} Ar — en attente de paiement',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grey, fontSize: 14),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PaymentPage(order: order)),
                ),
                child: const ButtonLabel('Payer maintenant'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                child: const Text('RETOUR À L’ACCUEIL'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
