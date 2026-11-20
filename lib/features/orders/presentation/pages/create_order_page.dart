import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/widgets/ui.dart';
import '../providers/orders_controller.dart';

class CreateOrderPage extends ConsumerStatefulWidget {
  const CreateOrderPage({super.key});

  @override
  ConsumerState<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends ConsumerState<CreateOrderPage> {
  final _title = TextEditingController();
  final _total = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _total.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await ref
        .read(createOrderControllerProvider.notifier)
        .submit(_title.text, double.tryParse(_total.text) ?? 0);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createOrderControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle commande')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShadowField(
            child: TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
          ),
          ShadowField(
            child: TextField(
              controller: _total,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total (Ar)'),
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
            child: ButtonLabel('Enregistrer', loading: state.isLoading),
          ),
        ],
      ),
    );
  }
}
