// lib/widgets/purchases_list_card.dart

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/purchase_state.dart';
import '../constants/product_ids.dart';

class PurchasesListCard extends StatelessWidget {
  final PurchaseState state;
  final Function(String) onConsumeProduct;

  const PurchasesListCard({
    super.key,
    required this.state,
    required this.onConsumeProduct,
  });

  @override
  Widget build(BuildContext context) {
    if (state.loading) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Loading purchases...'),
          subtitle: Text('Fetching your purchase history.'),
        ),
      );
    }

    if (!state.isAvailable) {
      return const SizedBox.shrink();
    }

    final consumablePurchases = state.purchases
        .where(
            (purchase) => ProductIds.consumableIds.contains(purchase.productID))
        .toList();

    final nonConsumablePurchases = state.purchases
        .where((purchase) =>
            !ProductIds.consumableIds.contains(purchase.productID))
        .toList();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Your Purchases',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (state.purchases.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No Purchases Yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your purchased items will appear here.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            if (consumablePurchases.isNotEmpty) ...[
              _buildConsumableSection(context, consumablePurchases),
              if (nonConsumablePurchases.isNotEmpty) const Divider(),
            ],
            if (nonConsumablePurchases.isNotEmpty) ...[
              _buildNonConsumableSection(context, nonConsumablePurchases),
            ],
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildConsumableSection(
      BuildContext context, List<PurchaseDetails> purchases) {
    // Group consumables by product ID and count them
    final Map<String, int> consumableCounts = {};
    for (final purchase in purchases) {
      consumableCounts[purchase.productID] =
          (consumableCounts[purchase.productID] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Consumable Items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: consumableCounts.entries.length,
            itemBuilder: (context, index) {
              final entry = consumableCounts.entries.elementAt(index);
              return _buildConsumableItem(context, entry.key, entry.value);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildConsumableItem(
      BuildContext context, String productId, int count) {
    return GestureDetector(
      onTap: () => _showConsumeDialog(context, productId),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 32,
                  color: Colors.orange,
                ),
                if (count > 1)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _getShortProductName(productId),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNonConsumableSection(
      BuildContext context, List<PurchaseDetails> purchases) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Owned Items & Subscriptions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: purchases.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, index) {
            final purchase = purchases[index];
            return _buildPurchaseItem(context, purchase);
          },
        ),
      ],
    );
  }

  Widget _buildPurchaseItem(BuildContext context, PurchaseDetails purchase) {
    final bool isSubscription =
        ProductIds.subscriptionIds.contains(purchase.productID);
    final IconData icon = isSubscription ? Icons.refresh : Icons.shopping_bag;
    final Color color = isSubscription ? Colors.purple : Colors.blue;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        _getShortProductName(purchase.productID),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Product ID: ${purchase.productID}'),
          if (purchase.transactionDate != null)
            Text('Purchased: ${_formatDate(purchase.transactionDate!)}'),
          Text('Status: ${_formatPurchaseStatus(purchase.status)}'),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: const Text(
          'ACTIVE',
          style: TextStyle(
            fontSize: 10,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showConsumeDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consume Item'),
        content: Text(
            'Do you want to consume one ${_getShortProductName(productId)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConsumeProduct(productId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Consume'),
          ),
        ],
      ),
    );
  }

  String _getShortProductName(String productId) {
    // Extract a readable name from product ID
    // You can customize this based on your product ID naming convention
    return productId
        .replaceAll('_', ' ')
        .split('.')
        .last
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatPurchaseStatus(PurchaseStatus status) {
    switch (status) {
      case PurchaseStatus.purchased:
        return 'Purchased';
      case PurchaseStatus.restored:
        return 'Restored';
      case PurchaseStatus.pending:
        return 'Pending';
      case PurchaseStatus.error:
        return 'Error';
      case PurchaseStatus.canceled:
        return 'Canceled';
    }
  }
}
