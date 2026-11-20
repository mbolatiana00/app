import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/ui.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final failure = await ref
        .read(authControllerProvider.notifier)
        .register(_name.text, _email.text, _password.text);
    if (!mounted) return;
    if (failure == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    setState(() {
      _loading = false;
      _error = failure.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const AuthHeader(
              title: 'Inscription',
              subtitle: 'Créez votre compte pour commander en quelques clics.',
            ),
            ShadowField(
              child: TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
            ),
            ShadowField(
              child: TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
            ),
            ShadowField(
              child: PasswordField(
                controller: _password,
                label: 'Mot de passe (6 caractères min.)',
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _loading ? null : _submit(),
              ),
            ),
            if (_error != null) ErrorText(_error!),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: ButtonLabel('Créer mon compte', loading: _loading),
            ),
            const SizedBox(height: 16),
            AuthSwitchLink(
              question: 'Déjà un compte ?',
              action: 'Se connecter',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
