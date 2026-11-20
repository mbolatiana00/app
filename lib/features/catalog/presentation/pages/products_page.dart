import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ui.dart';
import '../../../Panier/presentation/providers/cart_provider.dart';
import '../../domain/entities/product.dart';
import '../providers/products_provider.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});
  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        ref.read(productsControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _addToCart(Product p) {
    final f = ref.read(cartControllerProvider.notifier).add(p);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(f?.message ?? '${p.name} ajouté au panier')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsControllerProvider);
    final controller = ref.read(productsControllerProvider.notifier);

    final List<Widget> content;
    if (state.loading && state.items.isEmpty) {
      content = const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    } else if (state.error != null && state.items.isEmpty) {
      content = [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.wifi_off_rounded,
            message: state.error!.message,
            actionLabel: 'Réessayer',
            onAction: controller.refresh,
          ),
        ),
      ];
    } else if (state.items.isEmpty) {
      content = const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.search_off_rounded,
            message: 'Aucun produit trouvé',
          ),
        ),
      ];
    } else {
      final showFooter =
          state.hasMore || state.loadingMore || state.error != null;
      content = [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemCount: state.items.length,
            itemBuilder: (_, i) => _ProductCard(
              product: state.items[i],
              onAdd: () => _addToCart(state.items[i]),
            ),
          ),
        ),
        if (showFooter)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: state.error != null
                    ? TextButton(
                        onPressed: controller.loadMore,
                        child: const Text('Réessayer'),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ];
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const PageTitle('Catalogue'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ShadowField(
                          child: TextField(
                            onChanged: controller.search,
                            decoration: InputDecoration(
                              hintText: 'Rechercher un produit',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.grey,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: AppColors.grey,
                                  width: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.grid_view_rounded,
                              size: 18,
                              color: AppColors.dark,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.query.isEmpty
                                    ? 'Tous les produits'
                                    : 'Résultats pour « ${state.query} »',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.dark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${state.items.length} articles',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...content,
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  const _ProductCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 18,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProductImage(product.imageUrl, iconSize: 40),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: AppColors.surface,
                  shape: const CircleBorder(),
                  elevation: 3,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onAdd,
                    child: const Padding(
                      padding: EdgeInsets.all(9),
                      child: Icon(
                        Icons.add_shopping_cart_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(right: 40),
          child: Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${product.price.toStringAsFixed(0)} Ar',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }
}
