// lib/utils/consumable_store.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for managing consumable purchase storage.
///
/// In a production app, you should implement secure server-side storage
/// and verification for consumable products.
class ConsumableStore {
  static const String _kPrefKey = 'consumable_products';

  /// Load all stored consumable product IDs
  static Future<List<String>> load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? consumablesJson = prefs.getString(_kPrefKey);

      if (consumablesJson == null) {
        return <String>[];
      }

      final List<dynamic> consumablesList = json.decode(consumablesJson);
      return consumablesList.cast<String>();
    } catch (e) {
      print('Error loading consumables: $e');
      return <String>[];
    }
  }

  /// Save a consumable product ID
  static Future<void> save(String productId) async {
    try {
      final List<String> consumables = await load();
      consumables.add(productId);
      await _write(consumables);
    } catch (e) {
      print('Error saving consumable: $e');
    }
  }

  /// Consume (remove) a consumable product ID
  static Future<void> consume(String productId) async {
    try {
      final List<String> consumables = await load();
      consumables.remove(productId);
      await _write(consumables);
    } catch (e) {
      print('Error consuming product: $e');
    }
  }

  /// Clear all stored consumables
  static Future<void> clear() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kPrefKey);
    } catch (e) {
      print('Error clearing consumables: $e');
    }
  }

  /// Get count of a specific consumable product
  static Future<int> getCount(String productId) async {
    try {
      final List<String> consumables = await load();
      return consumables.where((id) => id == productId).length;
    } catch (e) {
      print('Error getting consumable count: $e');
      return 0;
    }
  }

  /// Private method to write consumables to storage
  static Future<void> _write(List<String> consumables) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String consumablesJson = json.encode(consumables);
      await prefs.setString(_kPrefKey, consumablesJson);
    } catch (e) {
      print('Error writing consumables: $e');
    }
  }
}
