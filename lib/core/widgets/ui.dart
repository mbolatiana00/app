import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Carte blanche arrondie avec ombre douce.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      boxShadow: AppTheme.shadow,
    ),
    child: child,
  );
}

/// Grand titre de page, façon catalogue.
class PageTitle extends StatelessWidget {
  final String text;
  const PageTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    child: Text(text, style: Theme.of(context).textTheme.headlineLarge),
  );
}

/// Champ de saisie avec ombre légère.
class ShadowField extends StatelessWidget {
  final Widget child;
  const ShadowField({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      boxShadow: AppTheme.shadow,
    ),
    child: child,
  );
}

/// Image produit avec fond neutre et repli si absente.
class ProductImage extends StatelessWidget {
  final String? url;
  final double iconSize;
  const ProductImage(this.url, {super.key, this.iconSize = 32});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: const Color(0xFFF1F1F1),
      alignment: Alignment.center,
      child: Icon(
        url == null ? Icons.image_outlined : Icons.broken_image_outlined,
        size: iconSize,
        color: AppColors.grey,
      ),
    );
    if (url == null) return placeholder;
    return Image.network(
      url!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

/// Message centré (vide / erreur) avec action optionnelle.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: AppTheme.shadow,
            ),
            child: Icon(icon, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 180,
              child: OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Texte d'erreur en rouge.
class ErrorText extends StatelessWidget {
  final String message;
  const ErrorText(this.message, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 8),
    child: Row(
      children: [
        const Icon(Icons.error_outline, size: 16, color: AppColors.error),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: AppColors.error, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

/// Contenu d'un bouton principal avec état de chargement.
class ButtonLabel extends StatelessWidget {
  final String text;
  final bool loading;
  const ButtonLabel(this.text, {super.key, this.loading = false});

  @override
  Widget build(BuildContext context) => loading
      ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
      : Text(text.toUpperCase());
}

/// Écran de résultat (succès) avec grande icône.
class ResultIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const ResultIcon({
    super.key,
    this.icon = Icons.check_rounded,
    this.color = AppColors.success,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 96,
    height: 96,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, size: 56, color: color),
  );
}
