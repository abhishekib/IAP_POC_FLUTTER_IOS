// lib/constants/product_ids.dart

class ProductIds {
  // Replace these with your actual product IDs from App Store Connect
  static const List<String> subscriptionIds = [
    'your_monthly_subscription_id',
    'your_yearly_subscription_id',
    // Add more subscription product IDs as needed
  ];

  static const List<String> consumableIds = [
    'your_consumable_product_id',
    // Add more consumable product IDs as needed
  ];

  static const List<String> nonConsumableIds = [
    'your_non_consumable_product_id',
    // Add more non-consumable product IDs as needed
  ];

  // Get all product IDs
  static List<String> get allProductIds => [
    ...subscriptionIds,
    ...consumableIds,
    ...nonConsumableIds,
  ];
}