// lib/models/purchase_state.dart

import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseState {
  final bool isAvailable;
  final List<ProductDetails> products;
  final List<PurchaseDetails> purchases;
  final List<String> notFoundIds;
  final bool purchasePending;
  final bool loading;
  final String? queryProductError;
  final String? errorMessage;

  const PurchaseState({
    required this.isAvailable,
    required this.products,
    required this.purchases,
    required this.notFoundIds,
    required this.purchasePending,
    required this.loading,
    this.queryProductError,
    this.errorMessage,
  });

  PurchaseState copyWith({
    bool? isAvailable,
    List<ProductDetails>? products,
    List<PurchaseDetails>? purchases,
    List<String>? notFoundIds,
    bool? purchasePending,
    bool? loading,
    String? queryProductError,
    String? errorMessage,
  }) {
    return PurchaseState(
      isAvailable: isAvailable ?? this.isAvailable,
      products: products ?? this.products,
      purchases: purchases ?? this.purchases,
      notFoundIds: notFoundIds ?? this.notFoundIds,
      purchasePending: purchasePending ?? this.purchasePending,
      loading: loading ?? this.loading,
      queryProductError: queryProductError,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    return 'PurchaseState(isAvailable: $isAvailable, '
        'productsCount: ${products.length}, '
        'purchasesCount: ${purchases.length}, '
        'notFoundIds: $notFoundIds, '
        'purchasePending: $purchasePending, '
        'loading: $loading, '
        'queryProductError: $queryProductError, '
        'errorMessage: $errorMessage)';
  }
}
