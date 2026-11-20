import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsControllerProvider);
    final controller = ref.read(productsControllerProvider.notifier);

    Widget body;
    if (state.loading && state.items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.error != null && state.items.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.error!.message),
            TextButton(
              onPressed: controller.refresh,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    } else if (state.items.isEmpty) {
      body = const Center(child: Text('Aucun produit trouvé'));
    } else {
      final showFooter =
          state.hasMore || state.loadingMore || state.error != null;
      body = RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView.builder(
          controller: _scroll,
          itemCount: state.items.length + (showFooter ? 1 : 0),
          itemBuilder: (_, i) {
            if (i >= state.items.length) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: state.error != null
                      ? TextButton(
                          onPressed: controller.loadMore,
                          child: const Text('Réessayer'),
                        )
                      : const CircularProgressIndicator(),
                ),
              );
            }
            final p = state.items[i];
            return ListTile(
              leading: SizedBox(
                width: 48,
                height: 48,
                child: p.imageUrl == null
                    ? const Icon(Icons.image_not_supported)
                    : Image.network(
                        p.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.broken_image),
                      ),
              ),
              title: Text(p.name),
              trailing: Text('${p.price.toStringAsFixed(0)} Ar'),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: controller.search,
              decoration: const InputDecoration(
                hintText: 'Rechercher un produit',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: body,
    );
  }
}
