import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Logo de la boutique : sac blanc dans un cercle rouge.
class AppLogo extends StatelessWidget {
  final double size;
  final bool inverted;
  const AppLogo({super.key, this.size = 72, this.inverted = false});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: inverted ? AppColors.surface : AppColors.primary,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: (inverted ? Colors.black : AppColors.primary).withValues(
            alpha: 0.25,
          ),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Icon(
      Icons.shopping_bag_rounded,
      size: size * 0.5,
      color: inverted ? AppColors.primary : AppColors.surface,
    ),
  );
}

/// En-tête commun des écrans de connexion et d'inscription.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppLogo(size: 64),
      const SizedBox(height: 28),
      Text(title, style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: const TextStyle(color: AppColors.grey, height: 1.4),
      ),
      const SizedBox(height: 36),
    ],
  );
}

/// Lien du bas : « Pas encore de compte ? S'inscrire ».
class AuthSwitchLink extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onTap;
  const AuthSwitchLink({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(question, style: const TextStyle(color: AppColors.grey)),
      TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        child: Text(
          action,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

/// Champ mot de passe avec bouton afficher/masquer.
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Mot de passe',
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) => TextField(
    controller: widget.controller,
    obscureText: _hidden,
    textInputAction: widget.textInputAction,
    onSubmitted: widget.onSubmitted,
    decoration: InputDecoration(
      labelText: widget.label,
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: IconButton(
        tooltip: _hidden ? 'Afficher' : 'Masquer',
        icon: Icon(
          _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () => setState(() => _hidden = !_hidden),
      ),
    ),
  );
}
