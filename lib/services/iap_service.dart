// lib/services/iap_service.dart

import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import '../constants/product_ids.dart';
import '../models/purchase_state.dart';
import '../utils/consumable_store.dart';
import '../delegates/payment_queue_delegate.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  factory IAPService() => _instance;
  IAPService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final StreamController<PurchaseState> _purchaseStateController =
      StreamController<PurchaseState>.broadcast();

  Stream<PurchaseState> get purchaseStream => _purchaseStateController.stream;

  PurchaseState _currentState = PurchaseState(
    isAvailable: false,
    products: [],
    purchases: [],
    notFoundIds: [],
    purchasePending: false,
    loading: true,
  );

  PurchaseState get currentState => _currentState;

  Future<void> initialize() async {
    // Listen to purchase updates
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) => _handleError('Purchase stream error: $error'),
    );

    // Initialize store info
    await _initializeStoreInfo();
  }

  Future<void> _initializeStoreInfo() async {
    try {
      final bool isAvailable = await _inAppPurchase.isAvailable();

      if (!isAvailable) {
        _updateState(_currentState.copyWith(
          isAvailable: false,
          loading: false,
        ));
        return;
      }

      // Set iOS delegate if needed
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
      }

      // Query product details
      final ProductDetailsResponse productDetailResponse = await _inAppPurchase
          .queryProductDetails(ProductIds.allProductIds.toSet());

      if (productDetailResponse.error != null) {
        _updateState(_currentState.copyWith(
          queryProductError: productDetailResponse.error!.message,
          isAvailable: isAvailable,
          products: productDetailResponse.productDetails,
          notFoundIds: productDetailResponse.notFoundIDs,
          loading: false,
        ));
        return;
      }

      // Restore previous purchases
      await _restorePurchases();

      _updateState(_currentState.copyWith(
        isAvailable: isAvailable,
        products: productDetailResponse.productDetails,
        notFoundIds: productDetailResponse.notFoundIDs,
        purchasePending: false,
        loading: false,
        queryProductError: null,
      ));
    } catch (e) {
      _handleError('Failed to initialize store: $e');
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final List<String> consumables = await ConsumableStore.load();
      final List<PurchaseDetails> consumablePurchases = consumables
          .map(
            (id) => PurchaseDetails(
              productID: id,
              purchaseID: id,
              verificationData: PurchaseVerificationData(
                localVerificationData: '',
                serverVerificationData: '',
                source: 'app_store',
              ),
              transactionDate: null,
              status: PurchaseStatus.purchased,
            ),
          )
          .toList();

      _updateState(_currentState.copyWith(
        purchases: consumablePurchases,
      ));
    } catch (e) {
      _handleError('Failed to restore purchases: $e');
    }
  }

  Future<void> buyProduct(ProductDetails productDetails) async {
    if (_currentState.purchasePending) return;

    _updateState(_currentState.copyWith(purchasePending: true));

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      bool success;
      if (ProductIds.consumableIds.contains(productDetails.id)) {
        success =
            await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } else {
        success =
            await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }

      if (!success) {
        _updateState(_currentState.copyWith(purchasePending: false));
        _handleError('Failed to initiate purchase');
      }
    } catch (e) {
      _updateState(_currentState.copyWith(purchasePending: false));
      _handleError('Purchase failed: $e');
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _handleError('Failed to restore purchases: $e');
    }
  }

  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _updateState(_currentState.copyWith(purchasePending: true));
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handlePurchaseError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await _deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // In a real app, verify the purchase with your backend server
    // For now, we'll just return true
    print('Verifying purchase: ${purchaseDetails.productID}');
    return true;
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    if (ProductIds.consumableIds.contains(purchaseDetails.productID)) {
      await ConsumableStore.save(purchaseDetails.purchaseID!);
      await _restorePurchases();
    } else {
      // Handle non-consumable or subscription delivery
      final updatedPurchases =
          List<PurchaseDetails>.from(_currentState.purchases);
      updatedPurchases.add(purchaseDetails);

      _updateState(_currentState.copyWith(
        purchases: updatedPurchases,
        purchasePending: false,
      ));
    }

    print('Product delivered: ${purchaseDetails.productID}');
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    _handleError('Invalid purchase: ${purchaseDetails.productID}');
  }

  void _handlePurchaseError(IAPError error) {
    _updateState(_currentState.copyWith(purchasePending: false));
    _handleError('Purchase failed: ${error.message}');
  }

  void _handleError(String message) {
    print('IAP Error: $message');
    _updateState(_currentState.copyWith(
      errorMessage: message,
      purchasePending: false,
    ));
  }

  void _updateState(PurchaseState newState) {
    _currentState = newState;
    _purchaseStateController.add(newState);
  }

  Future<void> consumeProduct(String productId) async {
    try {
      await ConsumableStore.consume(productId);
      await _restorePurchases();
    } catch (e) {
      _handleError('Failed to consume product: $e');
    }
  }

  Future<void> confirmPriceChange() async {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseStateController.close();

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
  }
}
