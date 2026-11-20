import 'dart:async';

import 'package:app/core/error/failure.dart';
import 'package:app/core/result.dart';
import 'package:app/features/auth/presentation/providers/auth_provider.dart';
import 'package:app/features/catalog/data/datasources/product_remote_datasource.dart';
import 'package:app/features/catalog/data/repositories/product_repository_impl.dart';
import 'package:app/features/catalog/domain/entities/product.dart';
import 'package:app/features/catalog/domain/repositories/product_repository.dart';
import 'package:app/features/catalog/domain/usecases/get_products.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) =>
      ProductRepositoryImpl(ProductRemoteDataSource(ref.watch(dioProvider))),
);

class ProductsState {
  final List<Product> items;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final String query;
  final Failure? error;

  const ProductsState({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.loading = false,
    this.loadingMore = false,
    this.query = '',
    this.error,
  });

  ProductsState copyWith({
    List<Product>? items,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    String? query,
    Failure? error,
    bool clearError = false,
  }) => ProductsState(
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    query: query ?? this.query,
    error: clearError ? null : (error ?? this.error),
  );
}
class ProductsController extends Notifier<ProductsState> {
  Timer? _debounce;
  int _requestId = 0;

  @override
  ProductsState build() {
    ref.onDispose(() => _debounce?.cancel());
    Future.microtask(refresh);
    return const ProductsState(loading: true);
  }

  GetProducts get _get => GetProducts(ref.read(productRepositoryProvider));

  Future<void> refresh() => _load(page: 1, reset: true);

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    await _load(page: state.page + 1, reset: false);
  }

  void search(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      state = state.copyWith(query: text.trim());
      refresh();
    });
  }

  Future<void> _load({required int page, required bool reset}) async {
    final id = ++_requestId;
    state = reset
        ? state.copyWith(loading: true, clearError: true)
        : state.copyWith(loadingMore: true, clearError: true);

    final result = await _get(page: page, query: state.query);
    if (id != _requestId) return; // réponse périmée : on l'ignore

    switch (result) {
      case Ok(:final value):
        state = state.copyWith(
          items: reset ? value.items : [...state.items, ...value.items],
          page: value.page,
          hasMore: value.hasMore,
          loading: false,
          loadingMore: false,
        );
      case Err(:final failure):
        state = state.copyWith(
          loading: false,
          loadingMore: false,
          error: failure,
        );
    }
  }
}

final productsControllerProvider =
    NotifierProvider.autoDispose<ProductsController, ProductsState>(
        ProductsController.new);