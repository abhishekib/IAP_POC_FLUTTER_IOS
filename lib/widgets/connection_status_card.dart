// lib/widgets/connection_status_card.dart

import 'package:flutter/material.dart';
import '../models/purchase_state.dart';

class ConnectionStatusCard extends StatelessWidget {
  final PurchaseState state;

  const ConnectionStatusCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.loading) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Connecting to App Store...'),
          subtitle: Text('Please wait while we initialize the connection.'),
        ),
      );
    }

    final bool isConnected = state.isAvailable;
    final Color statusColor = isConnected ? Colors.green : Colors.red;
    final IconData statusIcon = isConnected ? Icons.check_circle : Icons.error;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              statusIcon,
              color: statusColor,
              size: 32,
            ),
            title: Text(
              'App Store Connection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            subtitle: Text(
              isConnected
                  ? 'Successfully connected to App Store'
                  : 'Unable to connect to App Store',
              style: TextStyle(color: statusColor),
            ),
          ),
          if (!isConnected) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Troubleshooting Tips:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTroubleshootingItem(
                    '• Ensure you\'re running on a physical device (not simulator)',
                  ),
                  _buildTroubleshootingItem(
                    '• Check your internet connection',
                  ),
                  _buildTroubleshootingItem(
                    '• Verify In-App Purchase capability is enabled in Xcode',
                  ),
                  _buildTroubleshootingItem(
                    '• Make sure your Apple ID is signed in to the App Store',
                  ),
                  _buildTroubleshootingItem(
                    '• Try restarting the app',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTroubleshootingItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
