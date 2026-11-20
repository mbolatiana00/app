import 'package:app/features/orders/domain/entities/placed_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ui.dart';

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
        padding: const EdgeInsets.all(16),
        child: switch (state.phase) {
          PaymentPhase.submitting => const Center(
            child: CircularProgressIndicator(),
          ),
          PaymentPhase.waiting => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                ResultIcon(
                  icon: Icons.phone_iphone_rounded,
                  color: AppColors.primary,
                ),
                SizedBox(height: 32),
                Text(
                  'Confirmez le paiement sur votre téléphone',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'En attente de la confirmation de l\u2019opérateur…',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey),
                ),
                SizedBox(height: 32),
                CircularProgressIndicator(),
              ],
            ),
          ),
          PaymentPhase.success => Column(
            children: [
              const Spacer(),
              const ResultIcon(),
              const SizedBox(height: 32),
              const Text(
                'Paiement réussi',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
                child: const ButtonLabel('Terminer'),
              ),
              const SizedBox(height: 16),
            ],
          ),
          _ => ListView(
            children: [
              AppCard(
                child: Row(
                  children: [
                    const Text(
                      'Montant',
                      style: TextStyle(color: AppColors.grey, fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.order.total.toStringAsFixed(0)} Ar',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Moyen de paiement',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              RadioGroup<PaymentProvider>(
                groupValue: _provider,
                onChanged: (value) {
                  if (value != null) setState(() => _provider = value);
                },
                child: Column(
                  children: [
                    for (final p in PaymentProvider.values)
                      AppCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.zero,
                        child: RadioListTile<PaymentProvider>(
                          value: p,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: p == _provider
                                ? const BorderSide(color: AppColors.primary)
                                : BorderSide.none,
                          ),
                          title: Text(
                            p.label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            p.prefixes.join(' · '),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                          secondary: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ShadowField(
                child: TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Numéro ${_provider.label}',
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
              ),
              if (state.phase == PaymentPhase.failed)
                ErrorText(state.message ?? 'Paiement échoué'),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => controller.pay(
                  orderId: widget.order.id,
                  provider: _provider,
                  phone: _phone.text,
                ),
                child: ButtonLabel(
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
