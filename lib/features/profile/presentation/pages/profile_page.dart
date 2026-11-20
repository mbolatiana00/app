import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ui.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/profile.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Se déconnecter',
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
              ),
            ),
            const PageTitle('Mon profil'),
            Expanded(
              child: profile.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => EmptyState(
                  icon: Icons.person_off_outlined,
                  message: e is Failure ? e.message : 'Erreur inconnue',
                  actionLabel: 'Réessayer',
                  onAction: () => ref.invalidate(profileProvider),
                ),
                data: (p) => _ProfileForm(profile: p),
              ),
            ),
          ],
        ),
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
    final initial = widget.profile.name.trim().isEmpty
        ? '?'
        : widget.profile.name.trim()[0].toUpperCase();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.profile.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.profile.email,
                    style: const TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Informations personnelles',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ShadowField(
          child: TextField(
            controller: TextEditingController(text: widget.profile.email),
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
        ),
        ShadowField(
          child: TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Nom',
              prefixIcon: Icon(Icons.person_outline),
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
        ShadowField(
          child: TextField(
            controller: _address,
            decoration: const InputDecoration(
              labelText: 'Adresse',
              prefixIcon: Icon(Icons.location_on_outlined),
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
          onPressed: state.isLoading ? null : _save,
          child: ButtonLabel('Enregistrer', loading: state.isLoading),
        ),
      ],
    );
  }
}
