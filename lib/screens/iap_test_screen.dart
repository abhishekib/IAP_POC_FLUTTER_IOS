// lib/screens/iap_test_screen.dart

import 'package:flutter/material.dart';
import 'package:iap_test_app/widgets/products_list_card.dart';
import '../services/iap_service.dart';
import '../models/purchase_state.dart';
import '../widgets/connection_status_card.dart';
import '../widgets/purchases_list_card.dart';
import '../widgets/loading_overlay.dart';

class IAPTestScreen extends StatefulWidget {
  const IAPTestScreen({super.key});

  @override
  State<IAPTestScreen> createState() => _IAPTestScreenState();
}

class _IAPTestScreenState extends State<IAPTestScreen> {
  final IAPService _iapService = IAPService();

  @override
  void initState() {
    super.initState();
    _initializeIAP();
  }

  Future<void> _initializeIAP() async {
    await _iapService.initialize();
  }

  @override
  void dispose() {
    _iapService.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  /* void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IAP Test App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _initializeIAP(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => _iapService.restorePurchases(),
            tooltip: 'Restore Purchases',
          ),
        ],
      ),
      body: StreamBuilder<PurchaseState>(
        stream: _iapService.purchaseStream,
        initialData: _iapService.currentState,
        builder: (context, snapshot) {
          final state = snapshot.data!;

          // Show error messages
          if (state.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showErrorSnackBar(state.errorMessage!);
            });
          }

          // Build main content
          final List<Widget> children = [];

          if (state.queryProductError != null) {
            children.add(
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Product Query Error',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.queryProductError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            children.addAll([
              ConnectionStatusCard(state: state),
              const SizedBox(height: 8),
              ProductsListCard(
                state: state,
                onBuyProduct: _iapService.buyProduct,
                onConfirmPriceChange: _iapService.confirmPriceChange,
              ),
              const SizedBox(height: 8),
              PurchasesListCard(
                state: state,
                onConsumeProduct: _iapService.consumeProduct,
              ),
            ]);
          }

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: children,
                ),
              ),
              if (state.purchasePending) const LoadingOverlay(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDebugInfo(),
        tooltip: 'Debug Info',
        child: const Icon(Icons.info),
      ),
    );
  }

  void _showDebugInfo() {
    final state = _iapService.currentState;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDebugRow('Store Available', state.isAvailable.toString()),
              _buildDebugRow(
                  'Products Found', state.products.length.toString()),
              _buildDebugRow('Purchases', state.purchases.length.toString()),
              _buildDebugRow('Not Found IDs', state.notFoundIds.join(', ')),
              _buildDebugRow(
                  'Purchase Pending', state.purchasePending.toString()),
              _buildDebugRow('Loading', state.loading.toString()),
              if (state.queryProductError != null)
                _buildDebugRow('Query Error', state.queryProductError!),
              if (state.errorMessage != null)
                _buildDebugRow('Last Error', state.errorMessage!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'None' : value),
          ),
        ],
      ),
    );
  }
}
