# Flutter iOS In-App Purchase Test App - Setup Guide

## Project Structure
```
lib/
├── main.dart                           # App entry point
├── constants/
│   └── product_ids.dart               # Product ID configuration
├── models/
│   └── purchase_state.dart            # Purchase state model
├── services/
│   └── iap_service.dart               # In-app purchase service
├── delegates/
│   └── payment_queue_delegate.dart    # iOS payment queue delegate
├── utils/
│   └── consumable_store.dart          # Consumable products storage
├── screens/
│   └── iap_test_screen.dart           # Main test screen
└── widgets/
    ├── connection_status_card.dart    # Connection status widget
    ├── products_list_card.dart        # Products list widget
    ├── purchases_list_card.dart       # Purchases list widget
    └── loading_overlay.dart           # Loading overlay widget
```

## Step 1: Create Flutter Project
```bash
flutter create iap_test_app
cd iap_test_app
```

## Step 2: Replace Files
Replace the contents of each file with the provided code from the artifacts above.

## Step 3: Configure Product IDs
1. Open `lib/constants/product_ids.dart`
2. Replace the placeholder product IDs with your actual product IDs from App Store Connect:
   ```dart
   static const List<String> subscriptionIds = [
     'com.yourapp.monthly_subscription',    // Replace with your actual subscription ID
     'com.yourapp.yearly_subscription',     // Replace with your actual subscription ID
   ];
   ```

## Step 4: Install Dependencies
```bash
flutter pub get
```

## Step 5: iOS Configuration

### 5.1 Configure Bundle ID and Signing
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project → Runner target → General
3. Change Bundle Identifier to match your main app's Bundle ID
4. Configure signing with your development team
5. Set minimum deployment target to iOS 12.0+

### 5.2 Add In-App Purchase Capability
1. In Xcode, go to Runner target → Signing & Capabilities
2. Click "+ Capability" and add "In-App Purchase"

### 5.3 Update Info.plist (Optional)
Add to `ios/Runner/Info.plist` if you want to include StoreKit Ad Network support:
```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
</array>
```

## Step 6: App Store Connect Configuration

### 6.1 Create/Configure App
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Ensure your app is created with the same Bundle ID
3. Go to Features → In-App Purchases

### 6.2 Create Test Products
Create test products that match your Product IDs:
- **Subscriptions**: Auto-renewable subscriptions
- **Consumables**: Products that can be purchased multiple times
- **Non-Consumables**: One-time purchases

### 6.3 Create Sandbox Test Account
1. Go to Users and Access → Sandbox Testers
2. Create a new test account (use different email than your developer account)

## Step 7: Device Configuration

### 7.1 Sign Out of App Store
1. On your test device: Settings → App Store
2. Sign out of your regular Apple ID
3. Do NOT sign in with sandbox account yet (you'll be prompted during testing)

### 7.2 Enable Test Mode
Make sure you're testing on a physical device (not simulator)

## Step 8: Build and Test

### 8.1 Build for Release
```bash
flutter build ios --release
```

### 8.2 Run on Device
```bash
flutter run --release
```

**Important**: In-app purchases only work on physical devices in release mode.

## Step 9: Testing Flow

1. Launch app on physical device
2. Check connection status (should show "Successfully connected")
3. Verify products are loaded
4. Tap on a product to purchase
5. When prompted, sign in with your sandbox test account
6. Complete the purchase flow
7. Verify the purchase appears in the "Your Purchases" section

## Step 10: Debugging Common Issues

### Products Not Loading
- Check product IDs match exactly with App Store Connect
- Ensure products are "Ready for Sale" in App Store Connect
- Verify Bundle ID matches exactly

### Purchase Fails
- Use sandbox test account, not your developer account
- Ensure device is signed out of regular App Store account
- Check network connection
- Verify In-App Purchase capability is enabled

### Store Connection Issues
- Must run on physical device (not simulator)
- Must be in release mode for purchases
- Check iOS deployment target (iOS 12.0+)

## Step 11: Compare with Main App

Once this test app works, compare with your main app:

1. **Bundle ID**: Ensure exact match
2. **Product IDs**: Check for typos or mismatches
3. **Capabilities**: Verify In-App Purchase is enabled
4. **Signing**: Check provisioning profiles
5. **Code Implementation**: Compare purchase flow logic

## Debug Features

The test app includes:
- Connection status monitoring
- Product loading status
- Purchase state tracking
- Error message display
- Debug information dialog (tap the info button)

## Troubleshooting Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build ios --release

# View logs
flutter logs

# Check for iOS build issues
cd ios && pod install && cd ..
```

## Production Considerations

When moving to production:
1. Replace test product IDs with production IDs
2. Implement proper receipt validation on your backend
3. Add proper error handling and user feedback
4. Consider using a state management solution (Provider, Riverpod, etc.)
5. Add analytics tracking for purchase events
6. Implement proper subscription management

## Support

If you encounter issues:
1. Check the debug information in the app
2. Review console logs for error messages
3. Verify App Store Connect configuration
4. Test with different sandbox accounts
5. Compare working test app with your main app configuration

This modular structure makes it easy to identify and fix issues in your main application by comparing component by component.