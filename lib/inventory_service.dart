import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/inventory_model.dart';
import 'api_service.dart';

class InventoryService {
  static Future<List<Inventory>> getInventories() async {
    final response = await ApiService.get('inventories');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Inventory.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load inventories');
    }
  }

  static Future<Inventory> addInventory(Inventory inventory) async {
    final response = await ApiService.post('inventories', inventory.toJson());
    if (response.statusCode == 201) {
      return Inventory.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add inventory');
    }
  }

  static Future<Inventory> updateInventory(Inventory inventory) async {
    final response = await ApiService.put('inventories/${inventory.id}', inventory.toJson());
    if (response.statusCode == 200) {
      return Inventory.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update inventory');
    }
  }

  static Future<void> deleteInventory(int id) async {
    final response = await ApiService.delete('inventories/$id');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete inventory');
    }
  }
}