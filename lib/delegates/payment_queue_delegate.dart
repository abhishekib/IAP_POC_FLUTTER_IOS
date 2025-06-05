// lib/delegates/payment_queue_delegate.dart

import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

/// Example implementation of the
/// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
///
/// The payment queue delegate can be implemented to provide information
/// needed to complete transactions.
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    // Return true to continue the transaction in the current storefront.
    // Return false to hold the transaction and ask the user to choose a storefront.
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    // Return true to show price consent sheet when the price of a subscription
    // has increased and the user has not yet responded to a price increase.
    // Return false to proceed without showing the price consent sheet.
    return false;
  }
}
