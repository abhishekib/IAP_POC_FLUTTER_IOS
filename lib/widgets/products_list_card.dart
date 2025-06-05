// lib/widgets/products_list_card.dart

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/purchase_state.dart';
import '../constants/product_ids.dart';

class ProductsListCard extends StatelessWidget {
  final PurchaseState state;
  final Function(ProductDetails) onBuyProduct;
  final VoidCallback onConfirmPriceChange;

  const ProductsListCard({
    super.key,
    required this.state,
    required this.onBuyProduct,
    required this.onConfirmPriceChange,
  });

  @override
  Widget build(BuildContext context) {
    if (state.loading) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Loading products...'),
          subtitle: Text('Fetching available products from App Store.'),
        ),
      );
    }

    if (!state.isAvailable) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.store_mall_directory, color: Colors.grey),
          title: Text('Products Unavailable'),
          subtitle: Text('Cannot load products. Store connection required.'),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Available Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (state.notFoundIds.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Products Not Found',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Product IDs: ${state.notFoundIds.join(", ")}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'These products are not configured in App Store Connect or may not be available in your region.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (state.products.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No Products Available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please check your product configuration in App Store Connect.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.products.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = state.products[index];
                return _buildProductTile(context, product, state);
              },
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildProductTile(
      BuildContext context, ProductDetails product, PurchaseState state) {
    final bool isPurchased =
        state.purchases.any((p) => p.productID == product.id);
    final bool isSubscription = ProductIds.subscriptionIds.contains(product.id);
    final bool isConsumable = ProductIds.consumableIds.contains(product.id);

    String productType = 'One-time Purchase';
    if (isSubscription) {
      productType = 'Subscription';
    } else if (isConsumable) {
      productType = 'Consumable';
    }

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: CircleAvatar(
        backgroundColor: _getProductTypeColor(isSubscription, isConsumable),
        child: Icon(
          _getProductTypeIcon(isSubscription, isConsumable),
          color: Colors.white,
        ),
      ),
      title: Text(
        product.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.description),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getProductTypeColor(isSubscription, isConsumable)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getProductTypeColor(isSubscription, isConsumable)
                        .withOpacity(0.3),
                  ),
                ),
                child: Text(
                  productType,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getProductTypeColor(isSubscription, isConsumable),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isPurchased) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'OWNED',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing:
          _buildActionButton(context, product, isPurchased, isSubscription),
    );
  }

  Widget _buildActionButton(BuildContext context, ProductDetails product,
      bool isPurchased, bool isSubscription) {
    if (isPurchased && isSubscription) {
      return ElevatedButton.icon(
        onPressed: onConfirmPriceChange,
        icon: const Icon(Icons.upgrade, size: 16),
        label: const Text('Manage'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    }

    return ElevatedButton(
      onPressed: state.purchasePending ? null : () => onBuyProduct(product),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPurchased ? Colors.green : Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        isPurchased ? 'Buy Again' : product.price,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getProductTypeColor(bool isSubscription, bool isConsumable) {
    if (isSubscription) return Colors.purple;
    if (isConsumable) return Colors.orange;
    return Colors.blue;
  }

  IconData _getProductTypeIcon(bool isSubscription, bool isConsumable) {
    if (isSubscription) return Icons.refresh;
    if (isConsumable) return Icons.local_fire_department;
    return Icons.shopping_bag;
  }
}
