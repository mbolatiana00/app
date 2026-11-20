import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e is Failure ? e.message : 'Erreur inconnue'),
              TextButton(
                onPressed: () => ref.invalidate(profileProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (p) => _ProfileForm(profile: p),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  final Profile profile;
  const _ProfileForm({required this.profile});
  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final _name = TextEditingController(text: widget.profile.name);
  late final _phone = TextEditingController(text: widget.profile.phone ?? '');
  late final _address = TextEditingController(
    text: widget.profile.address ?? '',
  );

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = await ref
        .read(profileControllerProvider.notifier)
        .save(name: _name.text, phone: _phone.text, address: _address.text);
    if (ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profil enregistré')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: TextEditingController(text: widget.profile.email),
          enabled: false,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nom'),
        ),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Téléphone'),
        ),
        TextField(
          controller: _address,
          decoration: const InputDecoration(labelText: 'Adresse'),
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
          onPressed: state.isLoading ? null : _save,
          child: state.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}
